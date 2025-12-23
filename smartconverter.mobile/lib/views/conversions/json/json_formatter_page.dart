import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/permission_manager.dart';
import '../../../utils/ad_helper.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  State<JsonFormatterPage> createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> with AdHelper<JsonFormatterPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _jsonTextController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  // Toggle between file upload and text input
  bool _useTextInput = false;
  
  File? _selectedFile;
  bool _isConverting = false;
  bool _isSaving = false;
  String _statusMessage = 'Select input method to begin.';
  String? _formattedJson;
  ImageToPdfResult? _conversionResult;
  String? _savedFilePath;
  String? _suggestedBaseName;
  bool _fileNameEdited = false;
  int _indentSize = 2;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_onFileNameChanged);
  }

  @override
  void dispose() {
    _fileNameController.removeListener(_onFileNameChanged);
    _fileNameController.dispose();
    _jsonTextController.dispose();
    super.dispose();
  }

  void _onFileNameChanged() {
    if (_fileNameController.text.isNotEmpty &&
        _fileNameController.text != _suggestedBaseName) {
      _fileNameEdited = true;
    }
  }


  Future<void> _pickJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final extension = p.extension(file.path).toLowerCase();

      if (extension != '.json') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a valid JSON file (.json)'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _formattedJson = null;
        _conversionResult = null;
        _savedFilePath = null;
        _statusMessage = 'File selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
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

  Future<void> _formatJson() async {
    if (!_useTextInput && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a JSON file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_useTextInput && _jsonTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter JSON content.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Preparing for formatting...';
      _formattedJson = null;
      _conversionResult = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'JSON Formatter');
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Formatting cancelled (Ad required).';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Formatting JSON...';
    });

    try {
      dynamic result;
      
      if (_useTextInput) {
        // Format JSON text directly
        result = await _service.formatJsonText(
          _jsonTextController.text.trim(),
          indent: _indentSize,
        );
      } else {
        // Format JSON file
        final customFilename = _fileNameController.text.trim().isNotEmpty
            ? _sanitizeBaseName(_fileNameController.text.trim())
            : null;

        result = await _service.formatJsonFile(
          _selectedFile!,
          outputFilename: customFilename,
          indent: _indentSize,
        );
      }

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _statusMessage = 'Formatting failed. Please try again.';
        });
        return;
      }

      if (_useTextInput) {
        // Text mode: result is formatted JSON string
        setState(() {
          _formattedJson = result as String;
          _statusMessage = 'JSON formatted successfully!';
        });
      } else {
        // File mode: result is ImageToPdfResult with file
        setState(() {
          _conversionResult = result as ImageToPdfResult;
          _statusMessage = 'JSON file formatted successfully!';
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON formatted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Formatting failed: $e');
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
      final directory = await FileManager.getJsonConversionsDirectory();

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
            content: Text('JSON file is not available on disk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Formatted JSON: ${result.fileName}');
  }

  void _copyFormattedJson() {
    if (_formattedJson != null) {
      Clipboard.setData(ClipboardData(text: _formattedJson!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formatted JSON copied to clipboard!'),
          backgroundColor: AppColors.success,
        ),
      );
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
      base = 'formatted_json';
    }
    return base.substring(0, min(base.length, 80));
  }

  String _ensureJsonExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.json')
        ? trimmed
        : '$trimmed.json';
  }

  void _resetForNewConversion() {
    setState(() {
      _selectedFile = null;
      _isConverting = false;
      _statusMessage = 'Select input method to begin.';
      _formattedJson = null;
      _conversionResult = null;
      _savedFilePath = null;
      _suggestedBaseName = null;
      _fileNameController.clear();
      _jsonTextController.clear();
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
          'JSON Formatter',
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
                _buildInputMethodToggle(),
                const SizedBox(height: 16),
                if (_useTextInput) ...[
                  _buildJsonTextInput(),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildSelectedFileCard(),
                  const SizedBox(height: 16),
                  _buildFileNameField(),
                  const SizedBox(height: 16),
                ],
                _buildIndentSelector(),
                const SizedBox(height: 20),
                _buildFormatButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_formattedJson != null) ...[
                  const SizedBox(height: 20),
                  _buildFormattedJsonDisplay(),
                ],
                if (_conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? _buildPersistentResultCard() 
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
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.code,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'JSON Formatter',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Beautify and format your JSON with proper indentation.',
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

  Widget _buildInputMethodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useTextInput = false;
                  _resetForNewConversion();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_useTextInput
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      color: !_useTextInput
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upload File',
                      style: TextStyle(
                        color: !_useTextInput
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: !_useTextInput
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useTextInput = true;
                  _resetForNewConversion();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _useTextInput
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: _useTextInput
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paste JSON',
                      style: TextStyle(
                        color: _useTextInput
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: _useTextInput
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.code, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Paste JSON Content',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Line numbers and text input
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard.withOpacity(0.5),
                    border: Border(
                      right: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      _jsonTextController.text.split('\n').length.clamp(1, 30),
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _jsonTextController,
                    maxLines: 10,
                    onChanged: (value) {
                      // Trigger rebuild to update button state and line numbers
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Paste your JSON here...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
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
              elevation: 4,
              shadowColor: AppColors.primaryBlue.withOpacity(0.4),
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
                elevation: 4,
                shadowColor: AppColors.error.withOpacity(0.4),
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
              Icons.code,
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

    final hintText = _suggestedBaseName ?? 'formatted_json';

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

  Widget _buildIndentSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indentation Size',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [2, 3, 4].map((size) {
              final isSelected = _indentSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _indentSize = size);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '$size spaces',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton() {
    final canFormat = (!_useTextInput && _selectedFile != null) ||
        (_useTextInput && _jsonTextController.text.trim().isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canFormat && !_isConverting ? _formatJson : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: AppColors.primaryBlue.withOpacity(0.4),
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
                'Format JSON',
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
                : (_formattedJson != null || _conversionResult != null)
                ? Icons.check_circle
                : Icons.info_outline,
            color: _isConverting
                ? AppColors.warning
                : (_formattedJson != null || _conversionResult != null)
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
                    : (_formattedJson != null || _conversionResult != null)
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

  Widget _buildFormattedJsonDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Formatted JSON',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _copyFormattedJson,
                icon: const Icon(Icons.copy, color: AppColors.primaryBlue),
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  Container(
                    padding: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        _formattedJson!.split('\n').length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.5),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.4),
                              fontFamily: 'monospace',
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Formatted JSON text
                  Expanded(
                    child: SelectableText(
                      _formattedJson!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
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
                  Icons.check_circle_outline,
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
                      'JSON Formatted',
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

  Widget _buildPersistentResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'CONVERSION RESULT',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'FILE SAVED AT:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _savedFilePath!.replaceFirst('/storage/emulated/0/', ''),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                     if (!await File(_savedFilePath!).exists()) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('File no longer exists.')),
                          );
                        }
                        return;
                     }
                     await NotificationService.openFile(_savedFilePath!);
                  },
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Open File'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final folderPath = p.dirname(_savedFilePath!);
                    await NotificationService.openFile(folderPath);
                  },
                  icon: const Icon(Icons.folder_open, size: 14),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Open Folder'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareJsonFile,
                  icon: const Icon(Icons.share, size: 14),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Share'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryGreen,
                    side: const BorderSide(color: AppColors.secondaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    textStyle: const TextStyle(fontSize: 11),
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
