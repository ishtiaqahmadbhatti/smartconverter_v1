import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';

class SrtToTextPage extends StatefulWidget {
  const SrtToTextPage({super.key});
  @override
  State<SrtToTextPage> createState() => _SrtToTextPageState();
}

class _SrtToTextPageState extends State<SrtToTextPage> {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  ImageToPdfResult? _result;
  bool _isConverting = false;
  String _status = 'Select an SRT file to begin.';
  String? _suggestedBaseName;

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await _service.pickFile(allowedExtensions: ['srt'], type: null);
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _suggestedBaseName = p.basenameWithoutExtension(file.path);
        _status = 'Selected: ${p.basename(file.path)}';
      });
    }
  }

  Future<void> _convert() async {
    if (_selectedFile == null) return;
    setState(() { _isConverting = true; _status = 'Converting...'; });
    try {
      final outName = _fileNameController.text.trim();
      _result = await _service.convertSrtToText(
        _selectedFile!,
        outputFilename: outName.isEmpty ? null : outName,
      );
      setState(() {
        _isConverting = false;
        _status = _result != null ? 'Conversion successful' : 'Conversion completed (no file)';
      });
    } catch (e) {
      setState(() { _isConverting = false; _status = 'Failed: $e'; });
    }
  }

  Widget _buildFileNameField() {
    if (_selectedFile == null) return const SizedBox.shrink();
    final hintText = _suggestedBaseName ?? 'converted_subtitles';
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
        helperText: '.txt extension is added automatically',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_snippet_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _result!.fileName,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Share.shareXFiles([XFile(_result!.file.path)], text: _result!.fileName),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConvert = _selectedFile != null && !_isConverting;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert SRT to Text'),
        backgroundColor: AppColors.backgroundSurface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select SRT File'),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.subtitles_outlined, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.basename(_selectedFile!.path),
                        style: const TextStyle(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _buildFileNameField(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canConvert ? _convert : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isConverting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary)),
                      )
                    : const Text('Convert to Text', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            _buildResultCard(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(8)),
              child: Text(_status, style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
