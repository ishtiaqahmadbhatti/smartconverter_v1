
import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

class ImageToPdfPage extends StatefulWidget {
  const ImageToPdfPage({super.key});

  @override
  State<ImageToPdfPage> createState() => _ImageToPdfPageState();
}

class _ImageToPdfPageState extends State<ImageToPdfPage> with AdHelper<ImageToPdfPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  List<File> _selectedFiles = [];
  File? _convertedFile;
  String? _downloadUrl;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select image files (JPG, PNG) to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController.removeListener(_handleFileNameChange);
    _fileNameController.dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted && _selectedFiles.isEmpty) {
          setState(() => _statusMessage = 'No files selected.');
        }
        return;
      }

      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        _selectedFiles = files;
        _convertedFile = null;
        _downloadUrl = null;
        _savedFilePath = null;
        _statusMessage = '${files.length} images selected';
        resetAdStatus(null);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select files: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convertImagesToPdf() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image file.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting ${_selectedFiles.length} images to PDF...';
      _convertedFile = null;
      _downloadUrl = null;
      _savedFilePath = null;
    });

    final adWatched = await showRewardedAdGate(toolName: 'Images-to-PDF');
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    try {
      final result = await _service.convertImageToPdf(_selectedFiles);

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _convertedFile = result;
          _statusMessage = 'Converted to PDF successfully!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('PDF file ready: ${basename(result.path)}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception('Conversion returned null');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Conversion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isConverting = false);
      }
    }
  }

  Future<void> _savePdfFile() async {
    if (_convertedFile == null) return;

    await showInterstitialAd();

    setState(() => _isSaving = true);

    try {
      final root = await FileManager.getSmartConverterDirectory();
      final imageRoot = Directory('${root.path}/ImageConversion');
      if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
      
      final targetDir = Directory('${imageRoot.path}/image-to-pdf');
      if (!await targetDir.exists()) await targetDir.create(recursive: true);

      String targetFileName = _fileNameController.text.trim();
      if (targetFileName.isEmpty) {
         targetFileName = basename(_convertedFile!.path);
      } else {
         if (!targetFileName.toLowerCase().endsWith('.pdf')) {
            targetFileName += '.pdf';
         }
      }

      File destinationFile = File(p.join(targetDir.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          basenameWithoutExtension(targetFileName),
          'pdf',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(targetDir.path, targetFileName));
      }

      await _convertedFile!.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _savedFilePath = destinationFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to: ${destinationFile.path}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sharePdfFile() async {
    if (_convertedFile == null) return;
    final pathToShare = _savedFilePath ?? _convertedFile!.path;
    await Share.shareXFiles([
      XFile(pathToShare),
    ], text: 'Converted PDF file');
  }

  void _updateSuggestedFileName() {
    if (_selectedFiles.isEmpty) {
      setState(() {
        _suggestedBaseName = null;
        if (!_fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    if (_selectedFiles.length == 1) {
        final baseName = basenameWithoutExtension(_selectedFiles.first.path);
        final sanitized = _sanitizeBaseName(baseName);
         setState(() {
            _suggestedBaseName = sanitized;
            if (!_fileNameEdited) {
                _fileNameController.text = sanitized;
            }
        });
    } else {
        setState(() {
            _suggestedBaseName = 'merged_images';
            if (!_fileNameEdited) {
                _fileNameController.text = 'merged_images';
            }
        });
    }
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().contains('.')) {
        base = base.substring(0, base.lastIndexOf('.'));
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
     if (base.isEmpty) {
      base = 'converted_pdf';
    }
    return base.substring(0, min(base.length, 80));
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFiles = [];
      _convertedFile = null;
      _downloadUrl = null;
      _isConverting = false;
      _isSaving = false;
      _fileNameEdited = false;
      _suggestedBaseName = null;
      _savedFilePath = null;
      _statusMessage = 'Select image files (JPG, PNG) to begin.';
      _fileNameController.clear();
      resetAdStatus(null);
    });
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Image to PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Images to PDF',
                  description: 'Combine multiple images into a single PDF document.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.collections_bookmark,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: _pickFiles,
                  isFileSelected: _selectedFiles.isNotEmpty,
                  isConverting: _isConverting,
                  onReset: _resetForNewConversion,
                  buttonText: _selectedFiles.isEmpty ? 'Select Images' : 'Change Images',
                  icon: Icons.collections,
                ),
                const SizedBox(height: 16),
                if (_selectedFiles.isNotEmpty) 
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                          child: Text(
                            'Selected Files (${_selectedFiles.length})',
                             style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _selectedFiles.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final file = _selectedFiles[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.image, size: 20, color: AppColors.primaryBlue),
                                title: Text(
                                  basename(file.path),
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  formatBytes(file.lengthSync()),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (_selectedFiles.isNotEmpty) ...[
                   ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: _suggestedBaseName,
                    extensionLabel: '.pdf extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: _convertImagesToPdf,
                    isConverting: _isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to PDF',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: _statusMessage,
                  isConverting: _isConverting,
                  conversionResult: _convertedFile != null ? ImageToPdfResult(file: _convertedFile!, fileName: basename(_convertedFile!.path), downloadUrl: '') : null,
                ),
                if (_convertedFile != null) ...[
                  const SizedBox(height: 20),
                  if (_savedFilePath == null)
                     ConversionFileSaveCardWidget(
                      fileName: basename(_convertedFile!.path),
                      isSaving: _isSaving,
                      onSave: _savePdfFile,
                      title: 'PDF File Ready',
                    )
                  else
                     ConversionResultCardWidget(
                      savedFilePath: _savedFilePath!,
                      onShare: _sharePdfFile,
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
