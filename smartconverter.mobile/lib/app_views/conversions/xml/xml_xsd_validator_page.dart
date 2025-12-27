import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../constants/app_colors.dart';

import '../../../app_modules/imports_module.dart';
import '../../../utils/ad_helper.dart';

class XmlXsdValidatorPage extends StatefulWidget {
  const XmlXsdValidatorPage({super.key});

  @override
  State<XmlXsdValidatorPage> createState() => _XmlXsdValidatorPageState();
}

class _XmlXsdValidatorPageState extends State<XmlXsdValidatorPage> with AdHelper<XmlXsdValidatorPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _previewController = TextEditingController();

  File? _selectedXmlFile;
  File? _selectedXsdFile;
  bool _isValidating = false;
  String _statusMessage = 'Select XML file (and optional XSD) to validate.';
  
  // Validation Result
  bool _isValid = false;
  String? _validationResultText;

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  Future<void> _pickXmlFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['xml'],
        type: 'custom',
      );

      if (file == null) return;

      final extension = p.extension(file.path).toLowerCase();
      if (extension != '.xml') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only XML files are supported.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedXmlFile = file;
        _validationResultText = null;
        _statusMessage = 'XML selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickXsdFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['xsd'],
        type: 'custom',
      );

      if (file == null) return;

      final extension = p.extension(file.path).toLowerCase();
      if (extension != '.xsd') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only XSD files are supported.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedXsdFile = file;
        _validationResultText = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _validateXml() async {
    if (_selectedXmlFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an XML file.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _statusMessage = 'Validating...';
      _validationResultText = null;
      _previewController.clear();
    });

    // Show Rewarded Ad before validation
    final adWatched = await showRewardedAdGate(toolName: 'XML-Validator');
    if (!adWatched) {
      setState(() {
        _isValidating = false;
        _statusMessage = 'Validation cancelled (Ad required).';
      });
      return;
    }

    try {
      final result = await _service.validateXmlXsd(
        xmlFile: _selectedXmlFile!,
        xsdFile: _selectedXsdFile,
      );

      if (!mounted) return;

      if (result != null) {
        bool isValid = false;
        String resultString = '';

        // Safely parse specific known response structures
        if (result.containsKey('converted_data') && result['converted_data'] is String) {
           try {
             final validationJson = jsonDecode(result['converted_data']);
             isValid = validationJson['valid'] == true;
             resultString = const JsonEncoder.withIndent('  ').convert(validationJson);
           } catch (e) {
             resultString = result['converted_data'];
             isValid = false;
           }
        } else if (result.containsKey('detail') || (result.containsKey('valid') && result['valid'] == false)) {
             // Handle explicit error responses from backend
             isValid = false;
             if (result.containsKey('detail') && result['detail'] is Map) {
                final detail = result['detail'];
                if (detail['details'] != null && detail['details']['error'] != null) {
                    resultString = detail['details']['error'].toString();
                } else {
                    resultString = const JsonEncoder.withIndent('  ').convert(detail);
                }
             } else {
                 resultString = const JsonEncoder.withIndent('  ').convert(result);
             }
        } else {
             // Default success structure check
             isValid = result['valid'] == true || result['success'] == true;
             resultString = const JsonEncoder.withIndent('  ').convert(result);
        }

        setState(() {
          _isValid = isValid;
          _validationResultText = resultString;
          _previewController.text = resultString;
          _statusMessage = isValid ? 'Validation Successful: XML is Valid' : 'Validation Failed: XML is Invalid';
        });

      } else {
        throw Exception('Validation failed: No response data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
         _statusMessage = 'Validation Error: $e';
         _isValid = false;
         _validationResultText = 'Error occurred during validation: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  void _resetvalidator() {
    setState(() {
      _selectedXmlFile = null;
      _selectedXsdFile = null;
      _validationResultText = null;
      _isValidating = false;
      _statusMessage = 'Select XML file (and optional XSD) to validate.';
      _previewController.clear();
      resetAdStatus(null);
    });
  }

  Future<void> _copyContent() async {
    if (_previewController.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _previewController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Validation result copied to clipboard'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'XML Validator',
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
                _buildFilePickers(),
                const SizedBox(height: 20),
                _buildValidateButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_validationResultText != null) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(),
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
              Icons.fact_check,
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
                  'XML / XSD Validator',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Validate XML against XSD schema or check syntax.',
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

  Widget _buildFilePickers() {
    return Column(
      children: [
        // XML File Picker
        _buildFilePickerButton(
          label: _selectedXmlFile == null ? 'Select XML File *' : 'Change XML',
          file: _selectedXmlFile,
          onPressed: _pickXmlFile,
          icon: Icons.code,
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        // XSD File Picker
        _buildFilePickerButton(
          label: _selectedXsdFile == null ? 'Select XSD File (Optional)' : 'Change XSD',
          file: _selectedXsdFile,
          onPressed: _pickXsdFile,
          icon: Icons.rule,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildFilePickerButton({
    required String label,
    required File? file,
    required VoidCallback onPressed,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? AppColors.primaryBlue : AppColors.textSecondary.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: _isValidating ? null : onPressed,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isPrimary ? AppColors.primaryBlue : AppColors.textSecondary)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isPrimary ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
        title: Text(
          file == null ? label : p.basename(file.path),
          style: TextStyle(
            color: file == null ? AppColors.textSecondary : AppColors.textPrimary,
            fontWeight: file == null ? FontWeight.normal : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: file != null
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            : const Icon(Icons.add, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildValidateButton() {
    final canValidate = _selectedXmlFile != null && !_isValidating;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canValidate ? _validateXml : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
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
                    'Validate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        if (_validationResultText != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: _isValidating ? null : _resetvalidator,
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
                : _validationResultText != null
                ? (_isValid ? Icons.check_circle : Icons.error)
                : Icons.info_outline,
            color: _isValidating
                ? AppColors.warning
                : _validationResultText != null
                ? (_isValid ? AppColors.success : AppColors.error)
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
                    : _validationResultText != null
                    ? (_isValid ? AppColors.success : AppColors.error)
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: _isValid 
            ? AppColors.success.withOpacity(0.1) 
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isValid ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isValid ? Icons.check_circle_outline : Icons.error_outline,
            size: 64,
            color: _isValid ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            _isValid ? 'XML IS VALID' : 'XML IS INVALID',
            style: TextStyle(
              color: _isValid ? AppColors.success : AppColors.error,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          if (!_isValid && _validationResultText != null) ...[
             const SizedBox(height: 24),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppColors.backgroundSurface,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppColors.error.withOpacity(0.3)),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         'Error Details:',
                         style: TextStyle(
                           color: AppColors.textPrimary,
                           fontWeight: FontWeight.bold,
                           fontSize: 14,
                         ),
                       ),
                       IconButton(
                          onPressed: _copyContent,
                          icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(
                     _parseErrorText(_validationResultText!),
                     style: const TextStyle(
                       color: AppColors.textSecondary,
                       fontSize: 13, 
                       height: 1.5,
                       fontFamily: 'monospace',
                     ),
                   ),
                 ],
               ),
             ),
          ],
        ],
      ),
    );
  }

  String _parseErrorText(String jsonResult) {
    try {
      final json = jsonDecode(jsonResult);
      if (json is Map && json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List && errors.isNotEmpty) {
           return errors.map((e) => "• $e").join('\n');
        }
      }
      if (json is Map && json.containsKey('message')) {
         return json['message'].toString();
      }
      return jsonResult; // Fallback
    } catch (e) {
      return jsonResult;
    }
  }
}
