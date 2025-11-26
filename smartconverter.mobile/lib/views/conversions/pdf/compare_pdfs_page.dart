import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../services/admob_service.dart';
import '../../../utils/file_manager.dart';

class ComparePdfsPage extends StatefulWidget {
  const ComparePdfsPage({super.key});
  @override
  State<ComparePdfsPage> createState() => _ComparePdfsPageState();
}

class _ComparePdfsPageState extends State<ComparePdfsPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _fileNameController = TextEditingController();
  File? _file1;
  File? _file2;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select two PDF files to compare.';
  bool _isProcessing = false;
  bool _isSaving = false;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    _loadBannerAd();
    _loadTargetDirectoryPath();
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

  Future<void> _loadTargetDirectoryPath() async {
    final dir = await FileManager.getComparePdfDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _pickFile1() async {
    final file = await _service.pickFile(allowedExtensions: const ['pdf'], type: 'pdf');
    if (file == null) return;
    setState(() {
      _file1 = file;
      _resultFile = null;
      _savedFilePath = null;
    });
  }

  Future<void> _pickFile2() async {
    final file = await _service.pickFile(allowedExtensions: const ['pdf'], type: 'pdf');
    if (file == null) return;
    setState(() {
      _file2 = file;
      _resultFile = null;
      _savedFilePath = null;
    });
  }

  Future<void> _comparePdfs() async {
    final f1 = _file1;
    final f2 = _file2;
    if (f1 == null || f2 == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Comparing…';
      _resultFile = null;
      _savedFilePath = null;
    });
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.comparePdfs(f1, f2, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Comparison failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Comparison report ready';
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
      final dir = await FileManager.getComparePdfDirectory();
      String targetFileName = p.basename(res.path);
      File destinationFile = File('${dir.path}/$targetFileName');
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'txt',
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
    await Share.shareXFiles([XFile(f.path)], text: 'PDF Comparison Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Compare PDFs', style: TextStyle(color: AppColors.textPrimary)),
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
    final name1 = _file1 != null ? p.basename(_file1!.path) : 'No file 1';
    final name2 = _file2 != null ? p.basename(_file2!.path) : 'No file 2';
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
          const Text('Select PDFs', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(name1, style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _isProcessing ? null : _pickFile1, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue), child: const Text('Choose 1', style: TextStyle(color: Colors.white))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(name2, style: const TextStyle(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _isProcessing ? null : _pickFile2, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue), child: const Text('Choose 2', style: TextStyle(color: Colors.white))),
          ]),
          const SizedBox(height: 8),
          Text(
            _targetDirectoryPath != null
                ? 'Will save under: $_targetDirectoryPath'
                : 'Will save under: Documents/SmartConverter/PDFConversions/ComparePDF',
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
                  onPressed: ((_file1 == null || _file2 == null) || _isProcessing) ? null : _comparePdfs,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: Text(_isProcessing ? 'Processing…' : 'Compare', style: const TextStyle(color: Colors.white)),
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

