
import '../../../app_modules/imports_module.dart';


class ImageToPdfPage extends StatefulWidget {
  const ImageToPdfPage({super.key});

  @override
  State<ImageToPdfPage> createState() => _ImageToPdfPageState();
}

class _ImageToPdfPageState extends State<ImageToPdfPage> with AdHelper<ImageToPdfPage>, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(statusMessage: 'Select image files (JPG, PNG) to begin.');

  // Local state for multiple files (not handled by mixin's single file model)
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(handleFileNameChange);
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController.removeListener(handleFileNameChange);
    _fileNameController.dispose();
    super.dispose();
  }

  // Mixin Overrides
  @override
  ConversionModel get model => _model;
  @override
  TextEditingController get fileNameController => _fileNameController;
  @override
  ConversionService get service => _service;
  @override
  String get conversionToolName => 'Images to PDF';
  @override
  String get fileTypeLabel => 'Images';
  @override
  String get targetExtension => 'pdf';
  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png'];
  @override
  bool get requiresInputFile => false; // We handle selection manually

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
    
    final targetDir = Directory('${imageRoot.path}/image-to-pdf');
    if (!await targetDir.exists()) await targetDir.create(recursive: true);
    return targetDir;
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (_selectedFiles.isEmpty) {
      throw Exception('Please select at least one image file.');
    }

    // Ad check
    final adWatched = await showRewardedAdGate(toolName: 'Images-to-PDF');
    if (!adWatched) {
       throw Exception('Ad required to proceed.');
    }
    
    // We ignore the 'file' argument because we use _selectedFiles
    final resultFile = await _service.convertImageToPdf(_selectedFiles);
    
    if (resultFile == null) return null;

    return ImageToPdfResult(
        file: resultFile, 
        fileName: basename(resultFile.path), 
        downloadUrl: ''
    );
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
          setState(() => model.statusMessage = 'No files selected.');
        }
        return;
      }

      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        _selectedFiles = files;
        // Reset mixin state
        model.conversionResult = null;
        model.savedFilePath = null;
        model.statusMessage = '${files.length} images selected';
        resetAdStatus(null);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select files: $e';
      if (mounted) {
        setState(() => model.statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  void _updateSuggestedFileName() {
    if (_selectedFiles.isEmpty) {
      setState(() {
        model.suggestedBaseName = null;
        if (!model.fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    if (_selectedFiles.length == 1) {
        final baseName = basenameWithoutExtension(_selectedFiles.first.path);
        final sanitized = sanitizeBaseName(baseName);
         setState(() {
            model.suggestedBaseName = sanitized;
            if (!model.fileNameEdited) {
                _fileNameController.text = sanitized;
            }
        });
    } else {
        setState(() {
            model.suggestedBaseName = 'merged_images';
            if (!model.fileNameEdited) {
                _fileNameController.text = 'merged_images';
            }
        });
    }
  }
  
  void _resetLocal() {
      setState(() {
          _selectedFiles = [];
      });
      resetForNewConversion(customStatus: 'Select image files (JPG, PNG) to begin.');
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
                  isConverting: model.isConverting,
                  onReset: _resetLocal,
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
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.pdf extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to PDF',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                     ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'PDF File Ready',
                    )
                  else
                     ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
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
