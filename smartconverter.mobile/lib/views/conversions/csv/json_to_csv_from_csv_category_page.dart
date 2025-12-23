import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dio/dio.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/api_config.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class JsonToCsvFromCsvCategoryPage extends StatefulWidget {
  const JsonToCsvFromCsvCategoryPage({super.key});

  @override
  State<JsonToCsvFromCsvCategoryPage> createState() => _JsonToCsvFromCsvCategoryPageState();
}

class _JsonToCsvFromCsvCategoryPageState extends State<JsonToCsvFromCsvCategoryPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _convertedFile;
  String? _downloadUrl;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a JSON file to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickJsonFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['json'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) {
          setState(() => _statusMessage = 'No file selected.');
        }
        return;
      }

      final extension = p.extension(file.path).toLowerCase();
      if (extension != '.json') {
        if (mounted) {
          setState(
            () => _statusMessage = 'Please select a JSON file.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Only JSON files are supported.',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _convertedFile = null;
        _downloadUrl = null;
        _savedFilePath = null;
        _statusMessage = 'JSON file selected: ${p.basename(file.path)}';
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select JSON file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convertJsonToCsv() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a JSON file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting JSON to CSV...';
      _convertedFile = null;
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
        ApiConfig.csvJsonToCsvEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        final outputFilename = response.data['output_filename'] as String;
        final downloadUrl = response.data['download_url'] as String;

        // Download the file immediately to temp
        final tempDir = await FileManager.getTempDirectory();
        final savePath = p.join(tempDir.path, outputFilename);
        
        // Construct full download URL
        String fullDownloadUrl = downloadUrl;
        if (!downloadUrl.startsWith('http')) {
             if (downloadUrl.startsWith('/')) {
                  fullDownloadUrl = '$apiBaseUrl$downloadUrl';
             } else {
                  fullDownloadUrl = '$apiBaseUrl/$downloadUrl';
             }
        }
        
        await dio.download(fullDownloadUrl, savePath);

        setState(() {
          _convertedFile = File(savePath);
          _downloadUrl = fullDownloadUrl;
          _statusMessage = 'JSON converted to CSV successfully!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV file ready: $outputFilename'),
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

  Future<void> _saveCsvFile() async {
    if (_convertedFile == null) return;

    setState(() => _isSaving = true);

    try {
      final targetDir = await FileManager.getJsonToCsvDirectory();

      String targetFileName = p.basename(_convertedFile!.path);
      File destinationFile = File(p.join(targetDir.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'csv',
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

  Future<void> _shareCsvFile() async {
    if (_convertedFile == null) return;
    final pathToShare = _savedFilePath ?? _convertedFile!.path;
    await Share.shareXFiles([
      XFile(pathToShare),
    ], text: 'Converted CSV file');
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
    if (base.toLowerCase().endsWith('.json')) {
      base = base.substring(0, base.length - 5);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
     if (base.isEmpty) {
      base = 'converted_json';
    }
    return base.substring(0, min(base.length, 80));
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _convertedFile = null;
      _downloadUrl = null;
      _isConverting = false;
      _isSaving = false;
      _fileNameEdited = false;
      _suggestedBaseName = null;
      _savedFilePath = null;
      _statusMessage = 'Select a JSON file to begin.';
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
          'JSON to CSV',
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
            child: Stack(
              children: const [
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(
                    Icons.data_object,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    Icons.table_chart,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Convert JSON to CSV',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Transform JSON data into structured CSV format.',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConverting ? null : _pickJsonFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select JSON File' : 'Change File',
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
              Icons.data_object,
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

    final hintText = _suggestedBaseName ?? 'converted_json';

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
        helperText: '.csv extension is added automatically',
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
        onPressed: canConvert ? _convertJsonToCsv : null,
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
                'Convert to CSV',
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
    final file = _convertedFile!;
    
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
                  Icons.table_chart,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CSV Ready',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.basename(file.path),
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
                  onPressed: _isSaving ? null : _saveCsvFile,
                  icon: const Icon(Icons.save_alt),
                  label: Text(_isSaving ? 'Saving...' : 'Save File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareCsvFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_savedFilePath != null) ...[
             const SizedBox(height: 12),
             Row(
               children: [
                 const Icon(Icons.folder_open, size: 16, color: AppColors.textSecondary),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     'Saved to: ${p.basename(_savedFilePath!)}',
                     style: const TextStyle(
                       color: AppColors.textSecondary,
                       fontSize: 12,
                       fontStyle: FontStyle.italic,
                     ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             )
          ],
        ],
      ),
    );
  }
}
