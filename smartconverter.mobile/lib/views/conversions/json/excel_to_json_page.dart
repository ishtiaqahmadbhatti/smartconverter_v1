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
import '../../../utils/permission_manager.dart';
import '../../../utils/ad_helper.dart';

class ExcelToJsonPage extends StatefulWidget {
  const ExcelToJsonPage({super.key});

  @override
  State<ExcelToJsonPage> createState() => _ExcelToJsonPageState();
}

class _ExcelToJsonPageState extends State<ExcelToJsonPage> with AdHelper<ExcelToJsonPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  ImageToPdfResult? _conversionResult;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select an Excel file to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
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


  Future<void> _pickExcelFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['xls', 'xlsx'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) {
          setState(() => _statusMessage = 'No file selected.');
        }
        return;
      }

      final extension = p.extension(file.path).toLowerCase();
      if (!['.xls', '.xlsx'].contains(extension)) {
        if (mounted) {
          setState(
            () => _statusMessage = 'Please select an Excel file.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Only Excel files are supported. Please select a file with .xls or .xlsx extension.',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _conversionResult = null;
        _savedFilePath = null;
        _statusMessage = 'Excel file selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select Excel file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convertExcelToJson() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an Excel file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Preparing for conversion...';
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Excel-to-JSON');
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Converting Excel to JSON...';
    });

    try {
      final customFilename = _fileNameController.text.trim().isNotEmpty
          ? _sanitizeBaseName(_fileNameController.text.trim())
          : null;

      final result = await _service.convertExcelToJson(
        _selectedFile!,
        outputFilename: customFilename,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _statusMessage =
              'Conversion completed but no file returned. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conversion completed, but unable to download the file.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _conversionResult = result;
        _statusMessage = 'JSON file converted successfully!';
        _savedFilePath = null;
      });
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

  Future<void> _saveJsonFile() async {
    final result = _conversionResult;
    if (result == null) return;

    // Check for storage permissions first
    if (!await PermissionManager.isStoragePermissionGranted()) {
      final granted = await PermissionManager.requestStoragePermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to save files.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);

    try {
      final directory = await FileManager.getExcelToJsonDirectory();

      String targetFileName;
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensureJsonExtension(customName);
      } else {
        targetFileName = result.fileName;
      }

      File destinationFile = File(p.join(directory.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'json',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(directory.path, targetFileName));
      }

      final savedFile = await result.file.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _savedFilePath = savedFile.path);

      // Trigger system notification
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareJsonFile() async {
    final result = _conversionResult;
    if (result == null) return;
    final pathToShare = _savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);

    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not found. Please save it again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      await Share.shareXFiles([
        XFile(fileToShare.path),
      ], text: 'Converted JSON: ${result.fileName}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    if (base.toLowerCase().endsWith('.json')) {
      base = base.substring(0, base.length - 5);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) {
      base = 'converted_excel';
    }
    return base.substring(0, min(base.length, 80));
  }

  String _ensureJsonExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.json') ? trimmed : '$trimmed.json';
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _conversionResult = null;
      _isConverting = false;
      _isSaving = false;
      _savedFilePath = null;
      _statusMessage = 'Select an Excel file to begin.';
      _fileNameController.clear();
      resetAdStatus(null);
    });
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
          'Excel to JSON',
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
                if (_conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? PersistentResultCard(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareJsonFile,
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
                    Icons.table_chart,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    Icons.data_object,
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
                  'Convert Excel to JSON',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Transform Excel spreadsheets into JSON format.',
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
            onPressed: _isConverting ? null : _pickExcelFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select Excel File' : 'Change File',
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
              Icons.table_chart,
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

    final hintText = _suggestedBaseName ?? 'converted_excel';

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
        helperText: '.json extension is added automatically',
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
        onPressed: canConvert ? _convertExcelToJson : null,
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
                'Convert to JSON',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final bool isSuccess = _conversionResult != null || _savedFilePath != null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isConverting
                    ? Icons.hourglass_empty
                    : isSuccess
                    ? Icons.check_circle
                    : Icons.info_outline,
                color: _isConverting
                    ? AppColors.warning
                    : isSuccess
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
                        : isSuccess
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
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
                  Icons.data_object,
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
                      'JSON Ready',
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveJsonFile,
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
              label: const Text(
                'Save File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundSurface,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
