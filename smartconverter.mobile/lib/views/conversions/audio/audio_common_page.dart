import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/api_config.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';

/// A generic page for Audio format conversions.
class AudioCommonPage extends StatefulWidget {
  final String toolName;
  final String inputExtension;
  final String outputExtension; // pass empty string if variable
  final String apiEndpoint;
  final String outputFolder; // e.g., 'wav-to-mp3'
  final bool isVariableOutput; // If output extension depends on user choice

  // Optional: Build extra input fields to include in the form
  final Map<String, String> Function()? extraParamsBuilder;
  final List<Widget> Function(BuildContext context, Function(void Function()) setState)? extraWidgetsBuilder;

  const AudioCommonPage({
    super.key,
    required this.toolName,
    required this.inputExtension,
    required this.outputExtension,
    required this.apiEndpoint,
    required this.outputFolder,
    this.isVariableOutput = false,
    this.extraParamsBuilder,
    this.extraWidgetsBuilder,
  });

  @override
  State<AudioCommonPage> createState() => _AudioCommonPageState();
}

class _AudioCommonPageState extends State<AudioCommonPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _convertedFile;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = '';
  String? _suggestedBaseName;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _statusMessage = 'Select a ${widget.inputExtension.toUpperCase()} file to begin.';
    _fileNameController.addListener(_handleFileNameChange);
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  Future<void> _pickFile() async {
    try {
      // If inputExtension is generic 'audio', handle appropriately
      List<String> allowedExtensions = widget.inputExtension == 'audio' 
          ? ['mp3', 'wav', 'aac', 'flac', 'ogg', 'wma', 'm4a', 'aiff'] 
          : widget.inputExtension == 'video' // for mp4-to-mp3
            ? ['mp4', 'mov', 'mkv', 'avi']
            : [widget.inputExtension];

      final file = await _service.pickFile(
        allowedExtensions: allowedExtensions,
        type: 'custom',
      );

      if (file == null) {
        if (mounted) {
          setState(() => _statusMessage = 'No file selected.');
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _convertedFile = null;
        _savedFilePath = null;
        _statusMessage = 'Selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convert() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting audio...';
      _convertedFile = null;
      _savedFilePath = null;
    });

    // Validated Load: Show Rewarded Ad Gate
    final adWatched = await showRewardedAdGate(toolName: widget.toolName);
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
      ));

      final extraParams = widget.extraParamsBuilder?.call() ?? {};

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: p.basename(_selectedFile!.path),
        ),
        if (_fileNameController.text.trim().isNotEmpty)
          'filename': _fileNameController.text.trim(),
        ...extraParams,
      });

      final response = await dio.post(
        widget.apiEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        final outputFilename = response.data['output_filename'] as String;
        final downloadUrl = response.data['download_url'] as String;

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

        setState(() {
          _convertedFile = File(savePath);
          _statusMessage = 'Conversion successful!';
        });

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

  Future<void> _saveFile() async {
    if (_convertedFile == null) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);

    try {
      final root = await FileManager.getSmartConverterDirectory();
      final audioRoot = Directory('${root.path}/AudioConversion');
      if (!await audioRoot.exists()) {
        await audioRoot.create(recursive: true);
      }
      final targetDir = Directory('${audioRoot.path}/${widget.outputFolder}');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      String targetFileName = p.basename(_convertedFile!.path);
      File destinationFile = File(p.join(targetDir.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          p.extension(targetFileName).replaceAll('.', ''),
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(targetDir.path, targetFileName));
      }

      await _convertedFile!.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _savedFilePath = destinationFile.path);

      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: destinationFile.path,
      );

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

  Future<void> _shareFile() async {
    if (_convertedFile == null) return;
    final pathToShare = _savedFilePath ?? _convertedFile!.path;
    await Share.shareXFiles([
      XFile(pathToShare),
    ], text: 'Converted Audio file');
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
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) {
      base = 'converted_audio';
    }
    return base.substring(0, min(base.length, 80));
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _convertedFile = null;
      _isConverting = false;
      _isSaving = false;
      _fileNameEdited = false;
      _suggestedBaseName = null;
      _savedFilePath = null;
      _statusMessage = 'Select a ${widget.inputExtension.toUpperCase()} file to begin.';
      _fileNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    String extHelperText = '';
    if (widget.outputExtension.isNotEmpty && !widget.isVariableOutput) {
        extHelperText = '.${widget.outputExtension} extension is added automatically';
    } else {
        extHelperText = 'Appropriate extension will be added automatically';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.toolName,
          style: const TextStyle(
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
                
                if (widget.extraWidgetsBuilder != null) ...[
                   const SizedBox(height: 16),
                   ...widget.extraWidgetsBuilder!(context, setState),
                ],

                const SizedBox(height: 16),
                _buildFileNameField(extHelperText),
                const SizedBox(height: 20),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_convertedFile != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? ConversionResultCardWidget(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareFile,
                      )
                    : _buildResultCard(),
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
              Icons.audiotrack,
              size: 32,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.toolName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Convert, Normalize, Trim audio files.',
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
            onPressed: _isConverting ? null : _pickFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select File' : 'Change File',
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
    if (_selectedFile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.audio_file, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.basename(_selectedFile!.path),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNameField(String helperText) {
    if (_selectedFile == null) return const SizedBox.shrink();

    final hintText = _suggestedBaseName ?? 'converted_audio';

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
        helperText: helperText,
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
        onPressed: canConvert ? _convert : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isConverting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : const Text(
                'Convert',
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
            _isConverting ? Icons.hourglass_empty : _convertedFile != null ? Icons.check_circle : Icons.info_outline,
            color: _isConverting ? AppColors.warning : _convertedFile != null ? AppColors.success : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversion Complete',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveFile,
                  icon: const Icon(Icons.save_alt),
                  label: Text(_isSaving ? 'Saving...' : 'Save File'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundSurface.withOpacity(0.3),
                      foregroundColor: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
