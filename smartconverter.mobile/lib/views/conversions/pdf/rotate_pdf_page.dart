import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class RotatePdfPage extends StatefulWidget {
  const RotatePdfPage({super.key});

  @override
  State<RotatePdfPage> createState() => _RotatePdfPageState();
}

class _RotatePdfPageState extends State<RotatePdfPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;
  int _rotation = 90;

  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    _loadBannerAd();
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
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

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getRotatePdfDirectory();
      if (mounted) {
        setState(() => _targetDirectoryPath = dir.path);
      }
    } catch (_) {}
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

  Future<void> _rotatePdf() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Rotating pages…';
      _resultFile = null;
      _savedFilePath = null;
    });
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.rotatePdf(
        file,
        _rotation,
        outputFilename: name.isNotEmpty ? name : null,
      );
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Rotation failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'PDF rotated successfully';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Rotation failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveResult() async {
    final res = _resultFile;
    if (res == null) return;
    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getRotatePdfDirectory();
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
    await Share.shareXFiles([XFile(f.path)], text: 'Rotated PDF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Rotate PDF', style: TextStyle(color: AppColors.textPrimary)),
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
                : 'Will save under: Documents/SmartConverter/PDFConversions/RotatePDF',
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
              const Text('Rotation:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _rotation,
                dropdownColor: AppColors.backgroundDark,
                items: const [
                  DropdownMenuItem(value: 90, child: Text('90°')),
                  DropdownMenuItem(value: 180, child: Text('180°')),
                  DropdownMenuItem(value: 270, child: Text('270°')),
                ],
                onChanged: _isProcessing
                    ? null
                    : (val) {
                        if (val != null) setState(() => _rotation = val);
                      },
              ),
            ],
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
                  onPressed: (_selectedFile == null || _isProcessing) ? null : _rotatePdf,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: Text(_isProcessing ? 'Processing…' : 'Rotate', style: const TextStyle(color: Colors.white)),
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
