
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'dart:convert';

import '../../../constants/app_colors.dart';
import '../../../constants/api_config.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';

/// A generic page for File Validation tools.
class FileValidatorCommonPage extends StatefulWidget {
  final String toolName;
  final String inputExtension;
  final String? schemaExtension; // e.g. 'json' for schema or 'xsd' for xml
  final String apiEndpoint;
  
  const FileValidatorCommonPage({
    super.key,
    required this.toolName,
    required this.inputExtension,
    this.schemaExtension,
    required this.apiEndpoint,
  });

  @override
  State<FileValidatorCommonPage> createState() => _FileValidatorCommonPageState();
}

class _FileValidatorCommonPageState extends State<FileValidatorCommonPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();

  File? _selectedFile;
  File? _schemaFile;
  
  bool _isValidating = false;
  String _statusMessage = '';
  Map<String, dynamic>? _validationResult;
  
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _statusMessage = 'Select a ${widget.inputExtension.toUpperCase()} file to validate.';
    _admobService.preloadAd();
    _loadBannerAd();
    _service.initialize();
  }

  @override
  void dispose() {
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

  Future<void> _pickFile(bool isSchema) async {
    try {
      String ext = isSchema ? (widget.schemaExtension ?? '') : widget.inputExtension;
      if (ext.isEmpty) return;

      final file = await _service.pickFile(
        allowedExtensions: [ext],
        type: 'custom',
      );

      if (file == null) return;

      setState(() {
        if (isSchema) {
          _schemaFile = file;
        } else {
          _selectedFile = file;
          _statusMessage = 'Selected: ${p.basename(file.path)}';
          _validationResult = null;
        }
      });
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

  Future<void> _validate() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a file to validate.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _statusMessage = 'Validating...';
      _validationResult = null;
    });

    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ));

      final formDataMap = <String, dynamic>{
        'file': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: p.basename(_selectedFile!.path),
        ),
      };

      if (_schemaFile != null && widget.schemaExtension != null) {
          String schemaField = widget.schemaExtension == 'xsd' ? 'xsd_file' : 'schema_file';
          formDataMap[schemaField] = await MultipartFile.fromFile(
              _schemaFile!.path,
              filename: p.basename(_schemaFile!.path),
          );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        widget.apiEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _validationResult = response.data['validation_result'] ?? response.data['schema_info'];
          _statusMessage = 'Validation complete!';
        });
      } else {
        throw Exception(response.data['message'] ?? 'Validation failed');
      }
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

  @override
  Widget build(BuildContext context) {
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
                
                // File Selection
                _buildFileSelector(
                    label: 'Select ${widget.inputExtension.toUpperCase()} File',
                    file: _selectedFile,
                    onTap: () => _pickFile(false),
                    icon: Icons.description
                ),
                
                // Schema Selection (Optional)
                if (widget.schemaExtension != null) ...[
                  const SizedBox(height: 16),
                   _buildFileSelector(
                    label: 'Select ${widget.schemaExtension!.toUpperCase()} Schema (Optional)',
                    file: _schemaFile,
                    onTap: () => _pickFile(true),
                    icon: Icons.schema
                ),
                ],

                const SizedBox(height: 20),
                _buildValidateButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                
                if (_validationResult != null) ...[
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
                  'Validate structure and schema conformance.',
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

  Widget _buildFileSelector({required String label, required File? file, required VoidCallback onTap, required IconData icon}) {
      return InkWell(
          onTap: _isValidating ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
                children: [
                    Icon(icon, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    label,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                    ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    file != null ? p.basename(file.path) : 'No file chosen',
                                    style: TextStyle(
                                        color: file != null ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.5),
                                        fontWeight: file != null ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ],
                        ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
            ),
          ),
      );
  }

  Widget _buildValidateButton() {
    final canConvert = _selectedFile != null && !_isValidating;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConvert ? _validate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isValidating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : const Text(
                'Validate',
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
            _isValidating ? Icons.hourglass_empty : _validationResult != null ? Icons.check_circle : Icons.info_outline,
            color: _isValidating ? AppColors.warning : _validationResult != null ? AppColors.success : AppColors.textSecondary,
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
    // Pretty print JSON result
    String prettyJson = const JsonEncoder.withIndent('  ').convert(_validationResult);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface, // Use surface color for specific contrast
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const Text(
                  'Result:',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                      child: SelectableText(
                          prettyJson,
                          style: const TextStyle(
                              color: AppColors.textPrimary, 
                              fontFamily: 'monospace',
                              fontSize: 12
                          ),
                      ),
                  ),
              )
          ],
      ),
    );
  }
}
