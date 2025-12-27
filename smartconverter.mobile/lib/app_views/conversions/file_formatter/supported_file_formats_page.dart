
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../constants/api_config.dart';
import '../../../constants/app_colors.dart';

class SupportedFileFormatsPage extends StatefulWidget {
  const SupportedFileFormatsPage({super.key});

  @override
  State<SupportedFileFormatsPage> createState() => _SupportedFileFormatsPageState();
}

class _SupportedFileFormatsPageState extends State<SupportedFileFormatsPage> {
  List<dynamic>? _formats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFormats();
  }

  Future<void> _fetchFormats() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${await ApiConfig.baseUrl}${ApiConfig.fileSupportedFormatsEndpoint}',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _formats = response.data['formats'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to fetch formats';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Supported Formats', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildFormatSection('Supported Input Formats', _formats ?? []),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildFormatSection(String title, List<dynamic> formats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: formats.map((f) => Chip(
              label: Text(f.toString()),
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.textPrimary),
              side: BorderSide.none,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
