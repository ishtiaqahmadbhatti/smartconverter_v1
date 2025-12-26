import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';

class AiTranslateSrtPage extends StatefulWidget {
  const AiTranslateSrtPage({super.key});

  @override
  State<AiTranslateSrtPage> createState() => _AiTranslateSrtPageState();
}

class _AiTranslateSrtPageState extends State<AiTranslateSrtPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService(); // Keep for preload if needed, or rely on AdHelper
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  String? _fileSize;
  ImageToPdfResult? _conversionResult;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select an SRT file to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;

  List<String> _supportedLanguages = [];
  String? _selectedTargetLanguage;
  bool _isLoadingLanguages = true;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _loadSupportedLanguages();
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadSupportedLanguages() async {
    final languages = await _service.getSupportedLanguages();
    if (mounted) {
      setState(() {
        languages.sort();
        _supportedLanguages = languages;
        _isLoadingLanguages = false;
      });
    }
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }



  Future<void> _pickSrtFile() async {
    try {
      final file = await _service.pickFile(type: 'any');
      if (file == null) {
        if (mounted) setState(() => _statusMessage = 'No file selected.');
        return;
      }
      final ext = p.extension(file.path).toLowerCase();
      if (ext != '.srt') {
        if (mounted) {
          setState(() => _statusMessage = 'Please select an SRT file (.srt).');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unsupported file. Please choose a .srt file.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }
      
      String sizeStr = 'Unknown size';
      try {
        if (await file.exists()) {
          sizeStr = _formatBytes(await file.length());
        }
      } catch (e) {
        debugPrint('Error getting file size: $e');
      }

      setState(() {
        _selectedFile = file;
        _fileSize = sizeStr;
        _conversionResult = null;
        _savedFilePath = null;
        _statusMessage = 'SRT selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });
      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select SRT file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _translateSrt() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an SRT file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedTargetLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target language.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Preparing for translation...';
      _conversionResult = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'AI Translate SRT');
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Translation cancelled (Ad required).';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Translating SRT to $_selectedTargetLanguage...';
    });

    try {
      final customFilename = _fileNameController.text.trim().isNotEmpty
          ? _sanitizeBaseName(_fileNameController.text.trim())
          : null;

      final result = await _service.translateSrt(
        _selectedFile!,
        targetLanguage: _selectedTargetLanguage!,
        outputFilename: customFilename,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _statusMessage = 'Translation completed but no file returned.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Translation completed, but unable to download the file.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _conversionResult = result;
        _statusMessage = 'SRT translated successfully!';
        _savedFilePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SRT ready: ${result.fileName}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Translation failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  Future<void> _saveSrtFile() async {
    final result = _conversionResult;
    if (result == null) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);
    try {
      final directory = await FileManager.getSrtTranslateDirectory();
      String targetFileName;
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensureSrtExtension(customName);
      } else {
        targetFileName = result.fileName;
      }
      File destinationFile = File(p.join(directory.path, targetFileName));
      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'srt',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(directory.path, targetFileName));
      }
      final savedFile = await result.file.copy(destinationFile.path);
      if (!mounted) return;
      
      setState(() => _savedFilePath = savedFile.path);
      
      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: savedFile.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'File saved successfully!';
        });
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareSrtFile() async {
    final result = _conversionResult;
    if (result == null) return;
    final pathToShare = _savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);
    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SRT file is not available on disk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Translated SRT: ${result.fileName}');
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
    final langSuffix = _selectedTargetLanguage != null ? '_$_selectedTargetLanguage' : '';
    
    setState(() {
      _suggestedBaseName = '$sanitized$langSuffix';
      if (!_fileNameEdited) {
        _fileNameController.text = _suggestedBaseName!;
      }
    });
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.srt')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) base = 'translated_subtitle';
    return base.substring(0, min(base.length, 80));
  }

  String _ensureSrtExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.srt') ? trimmed : '$trimmed.srt';
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
          'AI Translate SRT',
          style: TextStyle(color: AppColors.textPrimary),
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
                _buildLanguageDropdown(),
                const SizedBox(height: 16),
                _buildFileNameField(),
                const SizedBox(height: 20),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? ConversionResultCardWidget(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareSrtFile,
                      )
                    : _buildResultCard(),
                ],
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.translate,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Translate SRT',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Translate SRT subtitles to other languages using AI',
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
            onPressed: _isConverting ? null : _pickSrtFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select SRT File' : 'Change File',
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
              onPressed: _isConverting
                  ? null
                  : () {
                      setState(() {
                        _selectedFile = null;
                        _fileSize = null;
                        _conversionResult = null;
                        _isConverting = false;
                        _isSaving = false;
                        _fileNameEdited = false;
                        _suggestedBaseName = null;
                        _savedFilePath = null;
                        _statusMessage = 'Select an SRT file to begin.';
                        _fileNameController.clear();
                      });
                      _admobService.preloadAd();
                    },
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
    final file = _selectedFile!;
    final fileName = p.basename(file.path);
    final fileSize = _fileSize ?? 'Unknown size';
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
              Icons.subtitles,
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
                  style: const TextStyle(
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

  Widget _buildLanguageDropdown() {
    if (_isLoadingLanguages) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTargetLanguage,
          hint: const Text(
            'Select Target Language',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          dropdownColor: AppColors.backgroundSurface,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          style: const TextStyle(color: AppColors.textPrimary),
          items: _supportedLanguages.map((String lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang.toUpperCase()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTargetLanguage = newValue;
              _updateSuggestedFileName();
            });
          },
        ),
      ),
    );
  }

  Widget _buildFileNameField() {
    if (_selectedFile == null) return const SizedBox.shrink();
    final hintText = _suggestedBaseName ?? 'translated_subtitle';
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
        helperText: '.srt extension is added automatically',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildConvertButton() {
    final canConvert = _selectedFile != null && _selectedTargetLanguage != null && !_isConverting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConvert ? _translateSrt : null,
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
                'Translate SRT',
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
                : _conversionResult != null
                    ? Icons.check_circle
                    : Icons.info_outline,
            color: _isConverting
                ? AppColors.warning
                : _conversionResult != null
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
                    : _conversionResult != null
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
    final result = _conversionResult!;
    final isSaved = _savedFilePath != null;
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
                  Icons.translate,
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
                      'Translation Ready',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.fileName,
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
              Flexible(
                flex: isSaved ? 3 : 1,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSrtFile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Save Document',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (isSaved) ...[
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _shareSrtFile,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundSurface,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
