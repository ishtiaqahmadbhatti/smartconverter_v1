
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_constants/app_colors.dart';

class GetAudioInfoPage extends StatefulWidget {
  const GetAudioInfoPage({super.key});

  @override
  State<GetAudioInfoPage> createState() => _GetAudioInfoPageState();
}

class _GetAudioInfoPageState extends State<GetAudioInfoPage> {
  File? _selectedFile;
  Map<String, dynamic>? _info;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'wma', 'm4a'],
    );

    if (result != null) {
       setState(() {
         _selectedFile = File(result.files.single.path!);
         _info = null;
         _errorMessage = null;
       });
       _fetchInfo();
    }
  }

  Future<void> _fetchInfo() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path),
      });

      final response = await dio.post(
        '${await ApiConfig.baseUrl}${ApiConfig.audioInfoEndpoint}',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _info = response.data['audio_info'];
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to get info';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Get Audio Info', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(_selectedFile == null ? 'Select Audio File' : 'Change File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              if (_info != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File: ${p.basename(_selectedFile!.path)}',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(color: AppColors.textSecondary),
                        const SizedBox(height: 10),
                        Expanded(child: _buildInfoList()),
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

  Widget _buildInfoList() {
    return ListView.separated(
      itemCount: _info!.length,
      separatorBuilder: (ctx, i) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        final key = _info!.keys.elementAt(index);
        final value = _info![key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatKey(key),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                value.toString(),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((str) => 
      str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : ''
    ).join(' ');
  }
}
