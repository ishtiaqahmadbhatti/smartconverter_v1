import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../../app_utils/ad_helper.dart';
import '../../../app_services/conversion_service.dart';
import '../../../app_constants/app_colors.dart';

class JsonValidationPage extends StatefulWidget {
  const JsonValidationPage({super.key});

  @override
  State<JsonValidationPage> createState() => _JsonValidationPageState();
}

class _JsonValidationPageState extends State<JsonValidationPage> with AdHelper<JsonValidationPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _jsonTextController = TextEditingController();

  // Toggle between file upload and text input
  bool _useTextInput = false;
  
  File? _selectedFile;
  bool _isValidating = false;
  String _statusMessage = 'Select input method to begin.';
  Map<String, dynamic>? _validationResult;


  @override
  void dispose() {
    _jsonTextController.dispose();
    super.dispose();
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
        _validationResult = null;
        _statusMessage = 'File selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });
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

  Future<void> _validateJson() async {
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
      _isValidating = true;
      _statusMessage = 'Validating JSON...';
      _validationResult = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'JSON Validator');
    if (!adWatched) {
      setState(() {
        _isValidating = false;
        _statusMessage = 'Validation cancelled (Ad required).';
      });
      return;
    }

    try {
      Map<String, dynamic>? result;
      
      if (_useTextInput) {
        result = await _service.validateJsonText(_jsonTextController.text.trim());
      } else {
        result = await _service.validateJsonFile(_selectedFile!);
      }

      if (!mounted) return;


      if (result == null) {
        setState(() {
          _statusMessage = 'Validation failed. Please try again.';
        });
        return;
      }

      setState(() {
        _validationResult = result;
        _statusMessage = (result?['valid'] ?? false) == true
            ? '✅ JSON is valid!'
            : '❌ JSON is invalid!';
      });

      final isValid = (result['valid'] ?? false) == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid ? 'JSON is valid!' : 'JSON is invalid!'),
          backgroundColor: isValid ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Validation failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  void _resetForNewValidation() {
    setState(() {
      _selectedFile = null;
      _isValidating = false;
      _statusMessage = 'Select input method to begin.';
      _validationResult = null;
      _jsonTextController.clear();
      resetAdStatus(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'JSON Validator',
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
                ],
                _buildValidateButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_validationResult != null) ...[
                  const SizedBox(height: 20),
                  _buildValidationResult(),
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
              Icons.check_circle_outline,
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
                  'JSON Validator',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Validate your JSON for syntax errors.',
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
                  _resetForNewValidation();
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
                  _resetForNewValidation();
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
                      setState(() {}); // Rebuild to update line numbers
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
            onPressed: _isValidating ? null : _pickJsonFile,
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
              onPressed: _isValidating ? null : _resetForNewValidation,
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

    final fileName = p.basename(_selectedFile!.path);

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
            child: Text(
              fileName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    final canValidate = (!_useTextInput && _selectedFile != null) ||
        (_useTextInput && _jsonTextController.text.trim().isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canValidate && !_isValidating ? _validateJson : null,
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
        child: _isValidating
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
                'Validate JSON',
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
            _isValidating
                ? Icons.hourglass_empty
                : _validationResult != null
                ? (_validationResult!['valid'] == true
                    ? Icons.check_circle
                    : Icons.error)
                : Icons.info_outline,
            color: _isValidating
                ? AppColors.warning
                : _validationResult != null
                ? (_validationResult!['valid'] == true
                    ? AppColors.success
                    : AppColors.error)
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isValidating
                    ? AppColors.warning
                    : _validationResult != null
                    ? (_validationResult!['valid'] == true
                        ? AppColors.success
                        : AppColors.error)
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationResult() {
    if (_validationResult == null) return const SizedBox.shrink();

    final isValid = _validationResult!['valid'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isValid ? _buildSuccessGradient() : _buildErrorGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isValid ? AppColors.success : AppColors.error)
                .withOpacity(0.2),
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
                child: Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isValid ? 'Valid JSON' : 'Invalid JSON',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  LinearGradient _buildSuccessGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.success.withOpacity(0.8),
        AppColors.success.withOpacity(0.6),
      ],
    );
  }

  LinearGradient _buildErrorGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.error.withOpacity(0.8),
        AppColors.error.withOpacity(0.6),
      ],
    );
  }

}
