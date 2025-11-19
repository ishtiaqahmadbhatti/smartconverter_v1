import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class JsonToXmlPage extends StatefulWidget {
  const JsonToXmlPage({super.key});

  @override
  State<JsonToXmlPage> createState() => _JsonToXmlPageState();
}

class _JsonToXmlPageState extends State<JsonToXmlPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _xmlController = TextEditingController();
  final TextEditingController _rootNameController =
      TextEditingController(text: 'root');

  File? _selectedJsonFile;
  File? _downloadedXmlFile;
  bool _isProcessing = false;
  String _status = '';

  @override
  void dispose() {
    _jsonController.dispose();
    _xmlController.dispose();
    _rootNameController.dispose();
    super.dispose();
  }

  Future<void> _pickJsonFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: ['json'],
        type: 'custom',
      );
      if (file != null) {
        final rawContent = await file.readAsString();
        String pretty = rawContent;
        try {
          final decoded = jsonDecode(rawContent);
          pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          // Leave raw content if parsing fails; API will validate on submit.
        }
        setState(() {
          _selectedJsonFile = file;
          _jsonController.text = pretty;
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

  Future<void> _convertJsonToXml() async {
    if (_selectedJsonFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a JSON file to convert.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Converting JSON to XML...';
      _xmlController.clear();
      _downloadedXmlFile = null;
    });

    try {
      await _service.initialize();
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
        ),
      );

      dynamic parsedJson;
      try {
        parsedJson = jsonDecode(_jsonController.text);
      } catch (e) {
        throw Exception('Invalid JSON: ${e.toString()}');
      }

      final rootName = _rootNameController.text.trim().isEmpty
          ? 'root'
          : _rootNameController.text.trim();

      final response = await dio.post(
        '/api/v1/jsonconversiontools/json-to-xml',
        data: {
          'json_data': parsedJson,
          'root_name': rootName,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final xmlContent = response.data['converted_data'] as String;

        setState(() {
          _xmlController.text = xmlContent;
          _status = 'Conversion successful!';
        });

        await _saveXmlFile(xmlContent);
      } else {
        String errorMsg = 'Conversion failed';
        if (response.data != null) {
          if (response.data['detail'] is Map) {
            final detail = response.data['detail'] as Map;
            errorMsg = detail['message'] ?? detail['error'] ?? errorMsg;
          } else if (response.data['message'] != null) {
            errorMsg = response.data['message'] as String;
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveXmlFile(String xmlContent) async {
    try {
      final xmlDir = await FileManager.getToolDirectory('XMLConversions');
      final filename =
          FileManager.generateTimestampFilename('json_to_xml', 'xml');
      final file = File('${xmlDir.path}/$filename');
      await file.writeAsString(xmlContent);
      setState(() => _downloadedXmlFile = file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved XML file to: ${file.path}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save XML file: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _copyXmlToClipboard() async {
    final xmlText = _xmlController.text;
    if (xmlText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: xmlText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('XML copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          'JSON to XML',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status / instructions
              Text(
                _status.isEmpty
                    ? 'Select a JSON file to convert it into XML.'
                    : _status,
                style: TextStyle(
                  color: _status.startsWith('Error')
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickJsonFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select JSON File'),
              ),
              const SizedBox(height: 16),

              if (_selectedJsonFile != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textTertiary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'JSON Preview (read-only):',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _jsonController,
                        readOnly: true,
                        maxLines: 10,
                        minLines: 6,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Selected JSON file contents will appear here.',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                          helperText:
                              'Editing disabled. Choose a different file to change the content.',
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
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              TextField(
                controller: _rootNameController,
                decoration: InputDecoration(
                  labelText: 'Root element name (optional)',
                  hintText: 'Default: root',
                  filled: true,
                  fillColor: AppColors.backgroundSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.textTertiary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isProcessing ? null : _convertJsonToXml,
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.textPrimary),
                        ),
                      )
                    : const Text('Convert JSON to XML'),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'XML Output:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textTertiary.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              controller: _xmlController,
                              maxLines: null,
                              readOnly: true,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Converted XML will appear here after conversion.',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _xmlController.text.isEmpty
                                      ? null
                                      : _copyXmlToClipboard,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy XML'),
                                ),
                                TextButton.icon(
                                  onPressed: _downloadedXmlFile == null
                                      ? null
                                      : () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Saved at: ${_downloadedXmlFile!.path}',
                                              ),
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.save),
                                  label: const Text('View Save Path'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
