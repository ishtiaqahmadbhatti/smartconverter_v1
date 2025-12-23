import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/api_config.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class PdfToImagePage extends StatefulWidget {
  final String? initialFormat;

  const PdfToImagePage({super.key, this.initialFormat});

  @override
  State<PdfToImagePage> createState() => _PdfToImagePageState();
}

class _PdfToImagePageState extends State<PdfToImagePage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  // We might get a single ZIP file or a single image file depending on pages
  File? _convertedFile;
  List<File>? _extractedImages; // If extracted from ZIP
  
  String? _downloadUrl;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a PDF file to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;
  late String _selectedFormat;
  final List<String> _formats = ['JPG', 'PNG', 'TIFF', 'SVG'];

  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.initialFormat ?? 'JPG';
    _fileNameController.addListener(_handleFileNameChange);
    _admobService.preloadAd();
    _loadBannerAd();
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  void _loadBannerAd() {
    if (!AdMobService.adsEnabled) return;
    final ad = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isBannerReady = false;
          });
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  Future<void> _pickPdfFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['pdf'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) {
          setState(() => _statusMessage = 'No file selected.');
        }
        return;
      }

      final extension = p.extension(file.path).toLowerCase();
      if (extension != '.pdf') {
        if (mounted) {
          setState(
            () => _statusMessage = 'Please select a PDF file.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only PDF files are supported.'),
              backgroundColor: AppColors.warning,
            ),
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
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select PDF file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  String _getEndpointForFormat(String format) {
    switch (format) {
      case 'JPG':
        return ApiConfig.pdfToJpgEndpoint;
      case 'PNG':
        return ApiConfig.pdfToPngEndpoint;
      case 'TIFF':
        return ApiConfig.pdfToTiffEndpoint;
      case 'SVG':
        return ApiConfig.pdfToSvgEndpoint;
      default:
        return ApiConfig.pdfToJpgEndpoint;
    }
  }

  Future<void> _convertPdfToImage() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a PDF file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting PDF to $_selectedFormat...';
      _convertedFile = null;
      _extractedImages = null;
      _downloadUrl = null;
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

        // Download to temp
        final tempDir = await FileManager.getTempDirectory();
        final savePath = p.join(tempDir.path, outputFilename);
        
        String fullDownloadUrl = downloadUrl;
        if (!downloadUrl.startsWith('http')) {
             if (downloadUrl.startsWith('/')) {
                  fullDownloadUrl = '$apiBaseUrl$downloadUrl';
             } else {
                  fullDownloadUrl = '$apiBaseUrl/$downloadUrl';
             }
        }
        
        await dio.download(fullDownloadUrl, savePath);

        final resultFile = File(savePath);
        
        // Check if it is a ZIP file
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion complete: $outputFilename'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Conversion failed');
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

  Future<List<File>> _extractZip(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final tempDir = await FileManager.getTempDirectory();
    final extractName = p.basenameWithoutExtension(zipFile.path);
    final extractDir = Directory('${tempDir.path}/$extractName');
    
    if (!await extractDir.exists()) {
      await extractDir.create(recursive: true);
    }

    List<File> extractedFiles = [];
    for (final file in archive) {
      if (file.isFile) {
        final data = file.content as List<int>;
        final f = File('${extractDir.path}/${file.name}');
        await f.create(recursive: true);
        await f.writeAsBytes(data);
        extractedFiles.add(f);
      }
    }
    return extractedFiles;
  }

  Future<void> _saveConvertedFile() async {
    if (_convertedFile == null) return;

    setState(() => _isSaving = true);

    try {
      final root = await FileManager.getSmartConverterDirectory();
      final imageRoot = Directory('${root.path}/ImageConversions');
      if (!await imageRoot.exists()) {
        await imageRoot.create(recursive: true);
      }
      final toolDir = Directory('${imageRoot.path}/pdf-to-${_selectedFormat.toLowerCase()}');
      if (!await toolDir.exists()) {
        await toolDir.create(recursive: true);
      }

      // If we have extracted images, save them all
      if (_extractedImages != null && _extractedImages!.isNotEmpty) {
          // Create a subdirectory for this batch if extracting multiple images
          final batchName = p.basenameWithoutExtension(_convertedFile!.path);
          final batchDir = Directory('${toolDir.path}/$batchName');
          if (!await batchDir.exists()) {
              await batchDir.create(recursive: true);
          }
          
          for (var img in _extractedImages!) {
             final targetName = p.basename(img.path);
             final dest = File('${batchDir.path}/$targetName');
             await img.copy(dest.path);
          }
          
          setState(() => _savedFilePath = batchDir.path);
          
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved images to: ${batchDir.path}'),
              backgroundColor: AppColors.success,
            ),
          );

      } else {
        // Just the single file (maybe a ZIP or single image)
        String targetFileName = p.basename(_convertedFile!.path);
        File destinationFile = File(p.join(toolDir.path, targetFileName));

        if (await destinationFile.exists()) {
            final fallbackName = FileManager.generateTimestampFilename(
            p.basenameWithoutExtension(targetFileName),
            p.extension(targetFileName).replaceAll('.', ''),
            );
            targetFileName = fallbackName;
            destinationFile = File(p.join(toolDir.path, targetFileName));
        }

        await _convertedFile!.copy(destinationFile.path);
        setState(() => _savedFilePath = destinationFile.path);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Saved to: ${destinationFile.path}'),
            backgroundColor: AppColors.success,
            ),
        );
      }

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

  Future<void> _shareConvertedFile() async {
    if (_convertedFile == null) return;
    
    if (_extractedImages != null && _extractedImages!.isNotEmpty) {
        // Share images
        final files = _extractedImages!.map((f) => XFile(f.path)).toList();
        await Share.shareXFiles(files, text: 'Converted Images from PDF');
    } else {
        final pathToShare = _savedFilePath ?? _convertedFile!.path;
        await Share.shareXFiles([
        XFile(pathToShare),
        ], text: 'Converted File from PDF');
    }
  }

  void _updateSuggestedFileName() {
    if (_selectedFile == null) {
      setState(() {
        _suggestedBaseName = null;
        if (!_fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    final baseName = p.basenameWithoutExtension(_selectedFile!.path);
    final sanitized = _sanitizeBaseName(baseName);

    setState(() {
      _suggestedBaseName = sanitized;
      if (!_fileNameEdited) {
        _fileNameController.text = sanitized;
      }
    });
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.pdf')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
     if (base.isEmpty) {
      base = 'converted_from_pdf';
    }
    return base.substring(0, min(base.length, 80));
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _convertedFile = null;
      _extractedImages = null;
      _downloadUrl = null;
      _isConverting = false;
      _isSaving = false;
      _fileNameEdited = false;
      _suggestedBaseName = null;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _fileNameController.clear();
    });
    _admobService.preloadAd();
  }

  String _formatBytes(int bytes) {
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
          'PDF to Image',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildFormatDropdown(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildSelectedFileCard(),
                const SizedBox(height: 16),
                _buildFileNameField(),
                const SizedBox(height: 20),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_convertedFile != null) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isBannerReady && _bannerAd != null
          ? Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

   Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.image,
              size: 32,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PDF to Image',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Convert PDF pages to JPG, PNG, TIFF, or SVG.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatDropdown() {
      return Container(
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
      );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConverting ? null : _pickPdfFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select PDF File' : 'Change File',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: _isConverting ? null : _resetForNewConversion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ],
    );
  }
  
  // Reuse FileCard, FileNameField, StatusMessage, ResultCard from standard
  
    Widget _buildSelectedFileCard() {
    if (_selectedFile == null) {
      return const SizedBox.shrink();
    }

    final file = _selectedFile!;
    final fileName = p.basename(file.path);
    
    String fileSize;
    try {
      if (file.existsSync()) {
        fileSize = _formatBytes(file.lengthSync());
      } else {
        fileSize = 'File no longer available';
      }
    } catch (e) {
      fileSize = 'Unknown size';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileSize,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNameField() {
    if (_selectedFile == null) {
      return const SizedBox.shrink();
    }

    final hintText = _suggestedBaseName ?? 'converted_page';

    return TextField(
      controller: _fileNameController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Output file name',
        hintText: hintText,
        prefixIcon: const Icon(Icons.edit_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        helperText: 'Extension is added automatically based on format',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildConvertButton() {
    final canConvert = _selectedFile != null && !_isConverting;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConvert ? _convertPdfToImage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isConverting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : const Text(
                'Convert PDF to Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isConverting
                ? Icons.hourglass_empty
                : _convertedFile != null
                ? Icons.check_circle
                : Icons.info_outline,
            color: _isConverting
                ? AppColors.warning
                : _convertedFile != null
                ? AppColors.success
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isConverting
                    ? AppColors.warning
                    : _convertedFile != null
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedFormat} Ready',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _convertedFile != null ? p.basename(_convertedFile!.path) : '',
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveConvertedFile,
                  icon: const Icon(Icons.save_alt),
                  label: Text(_isSaving ? 'Saving...' : 'Save File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareConvertedFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface.withOpacity(0.3),
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
