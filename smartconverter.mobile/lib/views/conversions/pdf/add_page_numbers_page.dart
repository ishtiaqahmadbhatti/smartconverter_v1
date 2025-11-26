import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../services/conversion_service.dart';
import '../../../services/admob_service.dart';
import '../../../utils/file_manager.dart';
import '../../../constants/app_colors.dart';

class AddPageNumbersPage extends StatefulWidget {
  const AddPageNumbersPage({super.key});

  @override
  State<AddPageNumbersPage> createState() => _AddPageNumbersPageState();
}

class _AddPageNumbersPageState extends State<AddPageNumbersPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();

  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _formatController = TextEditingController(text: '{page}');
  final TextEditingController _startPageController = TextEditingController(text: '1');
  final TextEditingController _fontSizeController = TextEditingController(text: '12');

  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;

  String _position = 'bottom-center';
  final List<String> _positions = const [
    'top-left', 'top-center', 'top-right',
    'bottom-left', 'bottom-center', 'bottom-right',
  ];

  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    _loadBannerAd();
    _loadTargetDirectory();
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

  Future<void> _loadTargetDirectory() async {
    final dir = await FileManager.getPageNumberPdfDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _formatController.dispose();
    _startPageController.dispose();
    _fontSizeController.dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final file = await _service.pickFile(allowedExtensions: const ['pdf'], type: 'pdf');
    if (file == null) {
      setState(() => _statusMessage = 'No file selected.');
      return;
    }
    setState(() {
      _selectedFile = file;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'PDF selected: ${p.basename(file.path)}';
    });
  }

  Future<void> _applyPageNumbers() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Applying page numbers…';
      _resultFile = null;
      _savedFilePath = null;
    });
    try {
      final name = _fileNameController.text.trim();
      final fmt = _formatController.text.trim().isEmpty ? '{page}' : _formatController.text.trim();
      final startPage = int.tryParse(_startPageController.text.trim()) ?? 1;
      final fontSize = double.tryParse(_fontSizeController.text.trim()) ?? 12.0;

      final res = await _service.addPageNumbersToPdf(
        file,
        position: _position,
        startPage: startPage,
        format: fmt,
        fontSize: fontSize,
        outputFilename: name.isNotEmpty ? name : null,
      );
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Failed to apply page numbers.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Page numbers applied';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveResult() async {
    final res = _resultFile;
    if (res == null) return;
    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getPageNumberPdfDirectory();
      String targetFileName = p.basename(res.path);
      File destinationFile = File('${dir.path}/$targetFileName');
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'pdf',
        );
        targetFileName = fallback;
        destinationFile = File('${dir.path}/$targetFileName');
      }
      final saved = await res.copy(destinationFile.path);
      if (!mounted) return;
      setState(() => _savedFilePath = saved.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: ${saved.path}'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareResult() async {
    final pathToShare = _savedFilePath ?? _resultFile?.path;
    if (pathToShare == null) return;
    final f = File(pathToShare);
    if (!await f.exists()) return;
    await Share.shareXFiles([XFile(f.path)], text: 'Numbered PDF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Page Numbers', style: TextStyle(color: AppColors.textPrimary)),
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
                _buildPickerCard(),
                const SizedBox(height: 12),
                _buildOptionsCard(),
                const SizedBox(height: 12),
                _buildActionsCard(),
                const SizedBox(height: 12),
                _buildResultCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: (_isBannerReady && _bannerAd != null)
          ? SafeArea(
              bottom: true,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }

  Widget _buildPickerCard() {
    final name = _selectedFile != null ? p.basename(_selectedFile!.path) : 'No file selected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select PDF', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickPdfFile,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                child: const Text('Choose', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _targetDirectoryPath != null
                ? 'Will save under: $_targetDirectoryPath'
                : 'Will save under: Documents/SmartConverter/PDFConversions/PageNumberPDF',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Options', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Position:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _position,
                dropdownColor: AppColors.backgroundDark,
                items: _positions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: _isProcessing ? null : (v) => setState(() => _position = v ?? 'bottom-center'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startPageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Start page',
                    hintText: '1',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textTertiary),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Font size',
                    hintText: '12',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textTertiary),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _formatController,
            decoration: const InputDecoration(
              labelText: 'Format',
              hintText: '{page}',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textTertiary),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'Output file name',
              hintText: 'optional',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textTertiary),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_selectedFile == null || _isProcessing) ? null : _applyPageNumbers,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: Text(_isProcessing ? 'Processing…' : 'Apply Page Numbers', style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_resultFile == null || _isSaving) ? null : _saveResult,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: Text(_isSaving ? 'Saving…' : 'Save', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_statusMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _resultFile;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Result', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (res == null)
            const Text('No result yet.', style: TextStyle(color: AppColors.textSecondary))
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.basename(res.path),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primaryBlue),
                  onPressed: _shareResult,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Saved: ${_savedFilePath ?? 'Not saved yet'}',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
