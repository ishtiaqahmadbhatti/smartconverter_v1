import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

import 'package:archive/archive.dart'; // Keep for extraction logic

class PdfToImagePage extends StatefulWidget {
  final String? initialFormat;

  const PdfToImagePage({super.key, this.initialFormat});

  @override
  State<PdfToImagePage> createState() => _PdfToImagePageState();
}

class _PdfToImagePageState extends State<PdfToImagePage> with AdHelper<PdfToImagePage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  
  // Custom state because this page logic is slightly more complex than standard 1:1 conversion
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
  late String _selectedFormat;
  final List<String> _formats = ['JPG', 'PNG', 'TIFF', 'SVG'];

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.initialFormat ?? 'JPG';
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
    // Shared pickFile logic is usually cleaner, but we need PDF specific error handling
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['pdf'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) setState(() => _statusMessage = 'No file selected.');
        return;
      }

       // Strict PDF check
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
         // Reset outputs
        _convertedFile = null;
        _extractedImages = null;
        _downloadUrl = null;
        _savedFilePath = null;
        _statusMessage = 'PDF file selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });
      _updateSuggestedFileName();

    } catch (e) {
      // Error handling
      if (mounted) {
        setState(() => _statusMessage = 'Failed to select PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _getEndpointForFormat(String format) {
    switch (format) {
      case 'JPG': return ApiConfig.pdfToJpgEndpoint;
      case 'PNG': return ApiConfig.pdfToPngEndpoint;
      case 'TIFF': return ApiConfig.pdfToTiffEndpoint;
      case 'SVG': return ApiConfig.pdfToSvgEndpoint;
      default: return ApiConfig.pdfToJpgEndpoint;
    }
  }

  Future<void> _convertPdfToImage() async {
    if (_selectedFile == null) return;
    
    // Ad Gate
    final adWatched = await showRewardedAdGate(toolName: 'PDF-to-Image');
    if (!adWatched) {
       setState(() => _statusMessage = 'Conversion cancelled (Ad required).');
       return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting to $_selectedFormat...';
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
        _getEndpointForFormat(_selectedFormat),
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final outputFilename = response.data['output_filename'] as String;
        final downloadUrl = response.data['download_url'] as String;

        // Download
        final tempDir = await FileManager.getTempDirectory();
        final savePath = p.join(tempDir.path, outputFilename);
        
        String fullDownloadUrl = downloadUrl.startsWith('http') 
            ? downloadUrl 
            : '$apiBaseUrl${downloadUrl.startsWith('/') ? '' : '/'}$downloadUrl';
            
        await dio.download(fullDownloadUrl, savePath);
        final resultFile = File(savePath);

        // ZIP Extract logic
        List<File>? images;
        if (outputFilename.toLowerCase().endsWith('.zip')) {
           images = await _extractZip(resultFile);
        }

        setState(() {
          _convertedFile = resultFile;
          _extractedImages = images;
          _downloadUrl = fullDownloadUrl;
          _statusMessage = 'Converted to $_selectedFormat successfully!';
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
        final f = File('${extractDir.path}/${file.name}');
        await f.parent.create(recursive: true); // safer
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
      final imageRoot = Directory('${root.path}/ImageConversion'); // Standardized folder name
      if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
      
      final subFolder = 'pdf-to-${_selectedFormat.toLowerCase()}';
      final toolDir = Directory('${imageRoot.path}/$subFolder');
      if (!await toolDir.exists()) await toolDir.create(recursive: true);

      if (_extractedImages != null && _extractedImages!.isNotEmpty) {
         // Batch save
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
         // Single file
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
          await Share.shareXFiles(files, text: 'Converted Images from PDF');
      } else {
          final path = _savedFilePath ?? _convertedFile!.path;
          await Share.shareXFiles([XFile(path)], text: 'Converted File from PDF');
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
    // basic sanitize
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
      // Standard App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PDF to Image',
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
                // Standard Header Widget
                const ConversionHeaderCardWidget(
                  title: 'PDF to Image', 
                  description: 'Convert PDF pages to JPG, PNG, TIFF, or SVG.',
                  iconTarget: Icons.image,
                  iconSource: Icons.picture_as_pdf,
                ),
                
                const SizedBox(height: 20),
                
                // Format Dropdown (Custom to this page)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                      children: [
                          const Text(
                              'Output Format:',
                              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      value: _selectedFormat,
                                      dropdownColor: AppColors.backgroundSurface,
                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                                      onChanged: (String? newValue) {
                                          if (newValue != null && !_isConverting) {
                                              setState(() {
                                                  _selectedFormat = newValue;
                                              });
                                          }
                                      },
                                      items: _formats.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                          );
                                      }).toList(),
                                  ),
                              ),
                          ),
                      ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Standard Action Button (Using Shared Widget Logic)
                ConversionActionButtonWidget(
                  onPickFile: () => _pickPdfFile(),
                  isFileSelected: _selectedFile != null,
                  isConverting: _isConverting,
                  onReset: _resetForNewConversion,
                  buttonText: 'Select PDF File',
                ),

                const SizedBox(height: 16),

                // Selected File Card
                if (_selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(_selectedFile!.path),
                    fileSize: formatBytes(_selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: _resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  
                  // File Name Field
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: _suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: 'Extension added automatically based on format',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Convert Button
                  ConversionConvertButtonWidget(
                    onConvert: _convertPdfToImage,
                    isConverting: _isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to $_selectedFormat',
                  ),
                ],

                const SizedBox(height: 16),
                
                // Status Widget
                // We're constructing a temporary ConversionResult object to pass to the widget, 
                // or we could use the simpler ConversionStatusWidget options if we updated it.
                // For now, let's just make a simple custom status row since we managed state manually.
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
                
                // Results Card
                if (_convertedFile != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                            BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 12, spreadRadius: 1),
                        ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.backgroundSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.check_circle_outline, color: AppColors.textPrimary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('$_selectedFormat Ready', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(_convertedFile!.path.split(Platform.pathSeparator).last, style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 12)),
                                ])),
                            ]),
                            const SizedBox(height: 20),
                            Row(children: [
                                Expanded(child: ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _saveConvertedFile,
                                    icon: const Icon(Icons.save_alt),
                                    label: Text(_isSaving ? 'Saving...' : 'Save File'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: ElevatedButton.icon(
                                    onPressed: _shareConvertedFile,
                                    icon: const Icon(Icons.share),
                                    label: const Text('Share'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.backgroundSurface.withOpacity(0.3), foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                )),
                            ]),
                        ],
                    ),
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
