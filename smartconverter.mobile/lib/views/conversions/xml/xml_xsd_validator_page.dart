import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dio/dio.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/api_config.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class XmlXsdValidatorPage extends StatefulWidget {
  const XmlXsdValidatorPage({super.key});

  @override
  State<XmlXsdValidatorPage> createState() => _XmlXsdValidatorPageState();
}

class _XmlXsdValidatorPageState extends State<XmlXsdValidatorPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _previewController = TextEditingController();

  File? _selectedXmlFile;
  File? _selectedXsdFile;
  bool _isValidating = false;
  String _statusMessage = 'Select XML file (and optional XSD) to validate.';
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  
  // Validation Result
  bool _isValid = false;
  String? _validationResultText;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    _loadBannerAd();
    _service.initialize();
  }

  @override
  void dispose() {
    _previewController.dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
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

    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ));

      final formDataMap = <String, dynamic>{
        'file_xml': await MultipartFile.fromFile(
          _selectedXmlFile!.path,
          filename: p.basename(_selectedXmlFile!.path),
        ),
      };

      if (_selectedXsdFile != null) {
        formDataMap['file_xsd'] = await MultipartFile.fromFile(
          _selectedXsdFile!.path,
          filename: p.basename(_selectedXsdFile!.path),
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        ApiConfig.xmlXsdValidatorEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        
        bool isValid = false;
        String resultString = '';

        // Check if we have converted_data which contains the validation result
        if (data is Map && data.containsKey('converted_data') && data['converted_data'] is String) {
          try {
            final validationJson = jsonDecode(data['converted_data']);
            isValid = validationJson['valid'] == true;
            resultString = const JsonEncoder.withIndent('  ').convert(validationJson);
          } catch (e) {
            // Fallback if parsing fails
            resultString = data['converted_data'];
            isValid = false;
          }
        } else {
          // Fallback for unexpected response structure
          if (data is Map) {
             resultString = const JsonEncoder.withIndent('  ').convert(data);
             isValid = data['valid'] == true || data['success'] == true;
          } else {
             resultString = data.toString();
             isValid = true;
          }
        }

        setState(() {
          _isValid = isValid;
          _validationResultText = resultString;
          _previewController.text = resultString;
          _statusMessage = isValid ? 'Validation Successful: XML is Valid' : 'Validation Failed: XML is Invalid';
        });

      } else {
        throw Exception(response.data['message'] ?? 'Validation failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Validation Error: $e');
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
    });
    _admobService.preloadAd();
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isValid ? AppColors.success.withOpacity(0.5) : AppColors.error.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isValid ? Icons.verified : Icons.warning,
                color: _isValid ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Validation Result',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
             height: 200,
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.black12,
               borderRadius: BorderRadius.circular(8),
             ),
             child: TextField(
               controller: _previewController,
               readOnly: true,
               maxLines: null,
               style: const TextStyle(
                 fontFamily: 'monospace',
                 fontSize: 12,
                 color: AppColors.textPrimary,
               ),
               decoration: const InputDecoration(
                 border: InputBorder.none,
                 contentPadding: EdgeInsets.zero,
               ),
             ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () async {
                 if (_previewController.text.isNotEmpty) {
                    await Clipboard.setData(ClipboardData(text: _previewController.text));
                    if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Copied to clipboard')),
                        );
                    }
                 }
              },
              icon: const Icon(Icons.copy, color: AppColors.primaryBlue),
              tooltip: 'Copy Result',
            ),
          )
        ],
      ),
    );
  }
}
