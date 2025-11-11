import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';
import '../../../constants/api_config.dart';
import 'package:share_plus/share_plus.dart';

class XmlToJsonPage extends StatefulWidget {
  const XmlToJsonPage({super.key});

  @override
  State<XmlToJsonPage> createState() => _XmlToJsonPageState();
}

class _XmlToJsonPageState extends State<XmlToJsonPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _xmlController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();

  File? _selectedXmlFile;
  String? _jsonContent;
  File? _downloadedJsonFile;
  bool _isProcessing = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _service.initialize();
  }

  @override
  void dispose() {
    _xmlController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickXmlFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: ['xml'],
        type: 'custom',
      );
      if (file != null) {
        setState(() {
          _selectedXmlFile = file;
          _status = 'Selected: ${file.path.split('/').last}';
        });
      }
    } catch (e) {
      setState(() => _status = 'Error selecting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _convertXmlToJson() async {
    // Validate input - at least one must be provided
    final hasTextContent = _xmlController.text.trim().isNotEmpty;
    final hasFile = _selectedXmlFile != null;

    if (!hasTextContent && !hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter XML content OR select an XML file (at least one is required)',
          ),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // If both are provided, prefer file over text content
    if (hasFile && hasTextContent) {
      // Clear text content to avoid confusion
      _xmlController.clear();
    }

    setState(() {
      _isProcessing = true;
      _status = 'Converting XML to JSON...';
      _jsonContent = null;
      _downloadedJsonFile = null;
    });

    try {
      await _service.initialize();
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );

      FormData formData;

      // Prepare form data - either file or content
      if (_selectedXmlFile != null) {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            _selectedXmlFile!.path,
            filename: _selectedXmlFile!.path.split('/').last,
          ),
        });
      } else {
        // Get XML content and ensure it's properly formatted
        String xmlContent = _xmlController.text.trim();
        
        // Validate XML content is not empty
        if (xmlContent.isEmpty) {
          throw Exception('XML content cannot be empty');
        }
        
        // Basic XML validation - should start with < or <?xml
        if (!xmlContent.startsWith('<')) {
          throw Exception('Invalid XML: XML must start with "<" or "<?xml"');
        }
        
        formData = FormData.fromMap({
          'xml_content': xmlContent,
        });
      }

      final response = await dio.post(
        '/api/v1/jsonconversiontools/xml-to-json',
        data: formData,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Don't throw for 4xx errors, let us handle them
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final jsonContent = response.data['converted_data'] as String;
        final outputFilename = response.data['output_filename'] as String?;
        final downloadUrl = response.data['download_url'] as String?;

        setState(() {
          _jsonContent = jsonContent;
          _jsonController.text = jsonContent;
          _status = 'Conversion successful!';
        });

        // Download JSON file if available
        if (outputFilename != null && downloadUrl != null) {
          await _downloadJsonFile(outputFilename, downloadUrl);
        }
      } else {
        // Handle API error response
        String errorMsg = 'Conversion failed';
        if (response.data != null) {
          if (response.data['detail'] != null) {
            // FastAPI error format
            if (response.data['detail'] is String) {
              errorMsg = response.data['detail'] as String;
            } else if (response.data['detail'] is Map) {
              final detail = response.data['detail'] as Map;
              errorMsg = detail['message'] ?? detail['error'] ?? errorMsg;
            } else if (response.data['detail'] is List && (response.data['detail'] as List).isNotEmpty) {
              // FastAPI validation errors
              final firstError = (response.data['detail'] as List).first;
              if (firstError is Map && firstError['msg'] != null) {
                errorMsg = firstError['msg'] as String;
              }
            }
          } else if (response.data['message'] != null) {
            errorMsg = response.data['message'] as String;
          }
        }
        
        // If status code indicates error, include it
        if (response.statusCode != null && response.statusCode! >= 400) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: errorMsg,
            type: DioExceptionType.badResponse,
          );
        } else {
          throw Exception(errorMsg);
        }
      }
    } catch (e) {
      String errorMessage = 'Conversion failed';
      final errorStr = e.toString().toLowerCase();
      
      // Provide user-friendly error messages
      if (errorStr.contains('invalid xml') || 
          errorStr.contains('xml parsing') ||
          errorStr.contains('not well-formed') ||
          errorStr.contains('unclosed') ||
          errorStr.contains('unexpected token')) {
        errorMessage = 'Invalid XML format. Please check:\n'
            '• All tags are properly closed (e.g., <tag>content</tag>)\n'
            '• No invalid or special characters\n'
            '• Proper XML structure\n'
            '• XML starts with "<" or "<?xml"';
      } else if (errorStr.contains('empty')) {
        errorMessage = 'XML content cannot be empty. Please enter XML content.';
      } else if (errorStr.contains('must start with')) {
        errorMessage = 'Invalid XML: XML must start with "<" or "<?xml" declaration.';
      } else if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorStr.contains('fileprocessingerror')) {
        // Extract the actual error message
        final match = RegExp(r'fileprocessingerror[:\s]+(.+)', caseSensitive: false).firstMatch(errorStr);
        errorMessage = match != null ? match.group(1)?.trim() ?? 'XML processing error' : 'XML processing error';
      } else {
        // Clean up error message
        errorMessage = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('Error: ', '')
            .replaceAll('DioException: ', '')
            .trim();
      }
      
      setState(() {
        _status = 'Error: $errorMessage';
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _downloadJsonFile(String filename, String downloadUrl) async {
    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );

      // Ensure downloadUrl is absolute and uses correct endpoint
      String fullDownloadUrl;
      if (downloadUrl.startsWith('http')) {
        fullDownloadUrl = downloadUrl;
      } else if (downloadUrl.startsWith('/api/v1/jsonconversiontools')) {
        fullDownloadUrl = '$apiBaseUrl$downloadUrl';
      } else {
        // Fallback: try JSON conversion tools endpoint
        fullDownloadUrl = '$apiBaseUrl/api/v1/jsonconversiontools$downloadUrl';
      }

      final response = await dio.get(
        fullDownloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Save to JSON Conversions directory
        final jsonDir = await FileManager.getToolDirectory('JSONConversions');
        final savedFilePath = '${jsonDir.path}/$filename';
        final savedFile = File(savedFilePath);
        await savedFile.writeAsBytes(response.data as List<int>);

        setState(() {
          _downloadedJsonFile = savedFile;
          _status = 'File saved to: ${savedFile.path}';
        });
      }
    } catch (e) {
      print('Download error: $e');
      // Continue even if download fails, user can copy content
    }
  }

  Future<void> _copyJsonContent() async {
    if (_jsonContent != null && _jsonContent!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _jsonContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON content copied to clipboard'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _shareJsonFile() async {
    if (_downloadedJsonFile != null && await _downloadedJsonFile!.exists()) {
      await Share.shareXFiles([
        XFile(_downloadedJsonFile!.path),
      ], text: 'Converted JSON file');
    } else if (_jsonContent != null && _jsonContent!.isNotEmpty) {
      // Share content as text if file not available
      await Share.share(_jsonContent!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('XML to JSON'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // XML Input Section
            Card(
              color: AppColors.backgroundCard,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        const Text(
                          'XML Input',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // File picker button
                    ElevatedButton.icon(
                      onPressed: _pickXmlFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Select XML File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_selectedXmlFile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'File: ${_selectedXmlFile!.path.split('/').last}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'OR Enter XML Content:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Required if no file',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _xmlController,
                      maxLines: 10,
                      minLines: 8,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Paste or type XML content here...\n\nExample:\n<?xml version="1.0"?>\n<root>\n  <item>Value</item>\n</root>',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                        helperText: 'Tip: Ensure all XML tags are properly closed (e.g., <tag>content</tag>)',
                        helperStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.textTertiary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.textTertiary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundSurface,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Convert Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _convertXmlToJson,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Convert to JSON',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Status
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                  color: _status.contains('Error')
                      ? AppColors.error
                      : AppColors.success,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 16),

            // JSON Output Section
            if (_jsonContent != null) ...[
              Card(
                color: AppColors.backgroundCard,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.data_object,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'JSON Output',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Copy button
                              ElevatedButton.icon(
                                onPressed: _copyJsonContent,
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Copy'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Download button
                              if (_downloadedJsonFile != null)
                                ElevatedButton.icon(
                                  onPressed: _shareJsonFile,
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Scrollable JSON content display in TextArea format
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          controller: _jsonController,
                          maxLines: null,
                          readOnly: true,
                          expands: true,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Converted JSON content will appear here...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              fontFamily: 'monospace',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Download button
                      if (_downloadedJsonFile != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'File saved: ${_downloadedJsonFile!.path.split('/').last}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _shareJsonFile,
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Download'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
