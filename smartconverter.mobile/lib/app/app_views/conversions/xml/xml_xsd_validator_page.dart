import '../../../app_modules/imports_module.dart';

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

      final ext = extension(file.path).toLowerCase();
      if (ext != '.xml') {
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
        _statusMessage = 'XML selected: ${basename(file.path)}';
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

      final ext = extension(file.path).toLowerCase();
      if (ext != '.xsd') {
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
        title: const Text('XML Validator', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const ConversionHeaderCardWidget(
                        title: 'XML / XSD Validator',
                        description: 'Validate XML against XSD schema or check syntax.',
                        sourceIcon: Icons.fact_check,
                        destinationIcon: Icons.rule,
                      ),
                      const SizedBox(height: 20),
                      
                      // XML Picker (Using standard widget with tweaks or custom if needed)
                      ConversionActionButtonWidget(
                        isFileSelected: _selectedXmlFile != null,
                        onPickFile: _pickXmlFile,
                        onReset: _resetvalidator,
                        isConverting: _isValidating,
                        buttonText: _selectedXmlFile == null ? 'Select XML File' : 'Change XML',
                      ),

                      if (_selectedXmlFile != null) ...[
                        const SizedBox(height: 16),
                        ConversionSelectedFileCardWidget(
                          fileName: basename(_selectedXmlFile!.path),
                          fileSize: formatBytes(_selectedXmlFile!.lengthSync()),
                          fileIcon: Icons.code,
                        ),
                      ],

                      const SizedBox(height: 12),

                      // XSD Picker - Custom button reusing styles or simpler widget
                      _buildXsdPicker(),

                      const SizedBox(height: 20),

                      ConversionConvertButtonWidget(
                        isConverting: _isValidating,
                        onConvert: _validateXml,
                        buttonText: 'Validate',
                      ),
                      
                      const SizedBox(height: 16),
                      ConversionStatusWidget(
                        statusMessage: _statusMessage,
                        isConverting: _isValidating,
                        // We don't utilize conversionResult here directly for success state in the same way, 
                        // but we can pass null and rely on status message style or pass a dummy if needed.
                        // Actually, let's just use the status message part.
                        conversionResult: _validationResultText != null 
                          ? ImageToPdfResult(
                              file: File(''), 
                              fileName: _isValid ? 'Valid' : 'Invalid',
                              downloadUrl: '',
                            ) 
                          : null, 
                      ),

                      if (_validationResultText != null) ...[
                        const SizedBox(height: 20),
                        _buildResultCard(),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildXsdPicker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: _isValidating ? null : _pickXsdFile,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.rule,
            color: AppColors.textSecondary,
          ),
        ),
        title: Text(
          _selectedXsdFile == null ? 'Select XSD File (Optional)' : basename(_selectedXsdFile!.path),
          style: TextStyle(
            color: _selectedXsdFile == null ? AppColors.textSecondary : AppColors.textPrimary,
            fontWeight: _selectedXsdFile == null ? FontWeight.normal : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _selectedXsdFile != null
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            : const Icon(Icons.add, color: AppColors.textSecondary),
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

  String formatBytes(int bytes) { 
        if (bytes <= 0) return '0 B';
        const units = ['B', 'KB', 'MB', 'GB', 'TB'];
        final digitGroups = (log(bytes) / log(1024)).floor();
        final clampedGroups = digitGroups.clamp(0, units.length - 1);
        final value = bytes / pow(1024, clampedGroups);
        return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }
}
