import 'dart:math';
import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';

class PdfToTiffImagePage extends StatefulWidget {
  final bool useImageCategoryStorage;

  const PdfToTiffImagePage({super.key, this.useImageCategoryStorage = false});

  @override
  State<PdfToTiffImagePage> createState() => _PdfToTiffImagePageState();
}

class _PdfToTiffImagePageState extends State<PdfToTiffImagePage> with AdHelper<PdfToTiffImagePage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _convertedFile;
  List<File>? _extractedImages;
  String? _downloadUrl;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a PDF file to begin.';
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

  Future<void> _pickPdfFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['pdf'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) setState(() => _statusMessage = 'No file selected.');
        return;
      }

      final extension = p.extension(file.path).toLowerCase();
      if (extension != '.pdf') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only PDF files are supported.'), backgroundColor: AppColors.warning),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _convertedFile = null;
        _extractedImages = null;
        _downloadUrl = null;
        _savedFilePath = null;
        _statusMessage = 'PDF file selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });
      _updateSuggestedFileName();

    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Failed to select PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _convertPdfToTiff() async {
    if (_selectedFile == null) return;
    
    final adWatched = await showRewardedAdGate(toolName: 'PDF-to-TIFF');
    if (!adWatched) {
       setState(() => _statusMessage = 'Conversion cancelled (Ad required).');
       return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting to TIFF...';
      _convertedFile = null;
      _extractedImages = null;
      _savedFilePath = null;
    });

    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ));

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: p.basename(_selectedFile!.path),
        ),
        if (_fileNameController.text.trim().isNotEmpty)
          'filename': _fileNameController.text.trim(),
      });

      final response = await dio.post(
        ApiConfig.pdfToTiffEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final outputFilename = response.data['output_filename'] as String;
        final downloadUrl = response.data['download_url'] as String;

        final tempDir = await FileManager.getTempDirectory();
        final savePath = p.join(tempDir.path, outputFilename);
        
        String fullDownloadUrl = downloadUrl.startsWith('http') 
            ? downloadUrl 
            : '$apiBaseUrl${downloadUrl.startsWith('/') ? '' : '/'}$downloadUrl';
            
        await dio.download(fullDownloadUrl, savePath);
        final resultFile = File(savePath);

        List<File>? images;
        if (outputFilename.toLowerCase().endsWith('.zip')) {
           images = await _extractZip(resultFile);
        }

        setState(() {
          _convertedFile = resultFile;
          _extractedImages = images;
          _downloadUrl = fullDownloadUrl;
          _statusMessage = 'Converted to TIFF successfully!';
        });

      } else {
        throw Exception(response.data['message'] ?? 'Conversion failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Conversion failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  Future<List<File>> _extractZip(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final tempDir = await FileManager.getTempDirectory();
    final extractName = p.basenameWithoutExtension(zipFile.path);
    final extractDir = Directory('${tempDir.path}/$extractName');
    if (!await extractDir.exists()) await extractDir.create(recursive: true);

    List<File> extractedFiles = [];
    for (final file in archive) {
      if (file.isFile) {
        // Ensure no directory traversal
        if (file.name.contains('..')) continue;
        
        final f = File('${extractDir.path}/${file.name}');
        await f.parent.create(recursive: true);
        await f.writeAsBytes(file.content as List<int>);
        extractedFiles.add(f);
      }
    }
    return extractedFiles;
  }

  Future<void> _saveConvertedFile() async {
    if (_convertedFile == null) return;
    await showInterstitialAd();
    setState(() => _isSaving = true);

    try {
      final root = await FileManager.getSmartConverterDirectory();
      final imageRoot = Directory('${root.path}/ImageConversion');
      if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
      
      final toolDir = Directory('${imageRoot.path}/pdf-to-tiff');
      if (!await toolDir.exists()) await toolDir.create(recursive: true);

      if (_extractedImages != null && _extractedImages!.isNotEmpty) {
         final batchName = p.basenameWithoutExtension(_convertedFile!.path);
         final batchDir = Directory('${toolDir.path}/$batchName');
         if (!await batchDir.exists()) await batchDir.create(recursive: true);

         for (var img in _extractedImages!) {
            final dest = File('${batchDir.path}/${p.basename(img.path)}');
            await img.copy(dest.path);
         }
         setState(() => _savedFilePath = batchDir.path);
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved images to: ${batchDir.path}'), backgroundColor: AppColors.success),
            );
         }
      } else {
         String targetFileName = p.basename(_convertedFile!.path);
         File dest = File(p.join(toolDir.path, targetFileName));
         if (await dest.exists()) {
             final fallback = FileManager.generateTimestampFilename(
                 p.basenameWithoutExtension(targetFileName), 
                 p.extension(targetFileName).replaceAll('.', '')
             );
             dest = File(p.join(toolDir.path, fallback));
         }
         await _convertedFile!.copy(dest.path);
         setState(() => _savedFilePath = dest.path);
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Saved to: ${dest.path}'), backgroundColor: AppColors.success),
             );
         }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
         );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareConvertedFile() async {
    if (_convertedFile == null) return;
    try {
      if (_extractedImages != null && _extractedImages!.isNotEmpty) {
          final files = _extractedImages!.map((f) => XFile(f.path)).toList();
          await Share.shareXFiles(files, text: 'Converted TIFF Images from PDF');
      } else {
          final path = _savedFilePath ?? _convertedFile!.path;
          await Share.shareXFiles([XFile(path)], text: 'Converted TIFF File from PDF');
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Share failed: $e'), backgroundColor: AppColors.error),
       );
    }
  }

  void _updateSuggestedFileName() {
    if (_selectedFile == null) {
      setState(() {
        _suggestedBaseName = null;
        if (!_fileNameEdited) _fileNameController.clear();
      });
      return;
    }
    final baseName = p.basenameWithoutExtension(_selectedFile!.path);
    final sanitized = baseName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    setState(() {
      _suggestedBaseName = sanitized;
      if (!_fileNameEdited) _fileNameController.text = sanitized;
    });
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _convertedFile = null;
      _extractedImages = null;
      _downloadUrl = null;
      _isConverting = false;
      _isSaving = false;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
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
          'Convert PDF to TIFF',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        leading: BackButton(color: AppColors.textPrimary),
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
                  title: 'PDF to TIFF Images', 
                  description: 'Convert PDF pages to TIFF images.',
                  iconTarget: Icons.image,
                  iconSource: Icons.picture_as_pdf,
                ),
                
                const SizedBox(height: 20),
                
                ConversionActionButtonWidget(
                  onPickFile: () => _pickPdfFile(),
                  isFileSelected: _selectedFile != null,
                  isConverting: _isConverting,
                  onReset: _resetForNewConversion,
                  buttonText: 'Select PDF File',
                ),

                const SizedBox(height: 16),

                if (_selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: p.basename(_selectedFile!.path),
                    fileSize: formatBytes(_selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: _resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: _suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: 'Extension added automatically',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ConversionConvertButtonWidget(
                    onConvert: _convertPdfToTiff,
                    isConverting: _isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to TIFF',
                  ),
                ],

                const SizedBox(height: 16),
                
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                        children: [
                            Icon(
                                _isConverting ? Icons.hourglass_empty : _convertedFile != null ? Icons.check_circle : Icons.info_outline,
                                color: _isConverting ? AppColors.warning : _convertedFile != null ? AppColors.success : AppColors.textSecondary,
                                size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_statusMessage, style: TextStyle(color: _isConverting ? AppColors.warning : _convertedFile != null ? AppColors.success : AppColors.textSecondary, fontSize: 13))),
                        ],
                    ),
                ),
                
                if (_convertedFile != null) ...[
                  const SizedBox(height: 20),
                  if (_savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: _extractedImages != null && _extractedImages!.isNotEmpty 
                          ? '${_extractedImages!.length} files generated' 
                          : p.basename(_convertedFile!.path),
                      title: 'TIFF Images Ready',
                      isSaving: _isSaving,
                      onSave: _saveConvertedFile,
                      buttonLabel: _extractedImages != null && _extractedImages!.isNotEmpty ? 'Save All' : 'Save File',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: _savedFilePath!,
                      onShare: _shareConvertedFile,
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