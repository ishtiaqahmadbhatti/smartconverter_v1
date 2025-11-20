import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../models/conversion_tool.dart';

class PdfSplitPage extends StatefulWidget {
  const PdfSplitPage({super.key});
  @override
  State<PdfSplitPage> createState() => _PdfSplitPageState();
}

class _PdfSplitPageState extends State<PdfSplitPage> {
  final ConversionService _service = ConversionService();
  File? _pdfFile;
  String _splitType = 'page_ranges';
  final TextEditingController _rangesCtrl = TextEditingController();
  final TextEditingController _prefixCtrl = TextEditingController();
  bool _zip = false;
  bool _loading = false;
  List<SplitFileResult> _results = [];

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (res != null && res.files.isNotEmpty) {
      final path = res.files.first.path;
      if (path != null) {
        final f = File(path);
        setState(() {
          _pdfFile = f;
          _prefixCtrl.text = p.basenameWithoutExtension(f.path);
        });
      }
    }
  }

  Future<void> _split() async {
    if (_pdfFile == null) return;
    final prefix = _prefixCtrl.text.trim().isEmpty ? p.basenameWithoutExtension(_pdfFile!.path) : _prefixCtrl.text.trim();
    final ranges = _splitType == 'page_ranges' ? _rangesCtrl.text.trim() : null;
    setState(() => _loading = true);
    try {
      final result = await _service.splitPdf(
        _pdfFile!,
        splitType: _splitType,
        pageRanges: ranges,
        outputPrefix: prefix,
        zip: _zip,
      );
      setState(() {
        _results = result?.files ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Split PDF', style: TextStyle(color: AppColors.textPrimary)),
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
                _buildPicker(),
                const SizedBox(height: 12),
                _buildOptions(),
                const SizedBox(height: 12),
                _buildAction(),
                const SizedBox(height: 16),
                _buildResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicker() {
    final name = _pdfFile != null ? p.basename(_pdfFile!.path) : 'No file selected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(color: AppColors.textPrimary))),
          ElevatedButton(
            onPressed: _pickFile,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Choose PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Radio<String>(value: 'every_page', groupValue: _splitType, onChanged: (v) => setState(() => _splitType = v!)),
              const Text('Every page', style: TextStyle(color: AppColors.textPrimary)),
              const SizedBox(width: 16),
              Radio<String>(value: 'page_ranges', groupValue: _splitType, onChanged: (v) => setState(() => _splitType = v!)),
              const Text('Page ranges', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rangesCtrl,
            enabled: _splitType == 'page_ranges',
            decoration: const InputDecoration(hintText: 'e.g., 1-4,5,30,45-50', hintStyle: TextStyle(color: AppColors.textSecondary)),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prefixCtrl,
            decoration: const InputDecoration(hintText: 'Output prefix', hintStyle: TextStyle(color: AppColors.textSecondary)),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _zip,
            onChanged: (v) => setState(() => _zip = v),
            title: const Text('Return zip also', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _split,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
        child: _loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Split PDF'),
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Results', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._results.map((r) => ListTile(
                title: Text(r.fileName, style: const TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(r.pages.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final f = await _service.downloadConvertedFile(r.downloadUrl, r.fileName);
                    if (f != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded ${r.fileName}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: const Text('Download'),
                ),
              )),
        ],
      ),
    );
  }
}