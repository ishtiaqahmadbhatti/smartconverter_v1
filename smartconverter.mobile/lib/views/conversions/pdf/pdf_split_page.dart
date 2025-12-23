import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';
import '../../../models/conversion_tool.dart';

class PdfSplitPage extends StatefulWidget {
  const PdfSplitPage({super.key});
  @override
  State<PdfSplitPage> createState() => _PdfSplitPageState();
}

class _PdfSplitPageState extends State<PdfSplitPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _prefixCtrl = TextEditingController();
  final TextEditingController _rangesCtrl = TextEditingController();
  File? _selectedFile;
  String _splitType = 'page_ranges';
  bool _zip = false;
  bool _isProcessing = false;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  List<SplitFileResult> _results = [];
  String? _savedFolderPath;
  String _statusMessage = 'Select a PDF file to begin.';
  String? _targetDirectoryPath;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    _loadBannerAd();
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    if (!AdMobService.adsEnabled) return;
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
      final dir = await FileManager.getSplitPdfsDirectory();
      if (mounted) {
        setState(() => _targetDirectoryPath = dir.path);
      }
    } catch (_) {}
  }

  Future<void> _pickPdfFile() async {
    final file = await _service.pickFile(
      allowedExtensions: const ['pdf'],
      type: 'pdf',
    );
    if (file == null) {
      setState(() => _statusMessage = 'No file selected.');
      return;
    }
    setState(() {
      _selectedFile = file;
      _results = [];
      _savedFolderPath = null;
      _statusMessage = 'PDF file selected: ${p.basename(file.path)}';
      _prefixCtrl.text = p.basenameWithoutExtension(file.path);
    });
  }

  Future<void> _splitPdf() async {
    if (_selectedFile == null) {
      setState(() => _statusMessage = 'Please select a PDF file first.');
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final prefix = _prefixCtrl.text.trim().isEmpty
          ? p.basenameWithoutExtension(_selectedFile!.path)
          : _prefixCtrl.text.trim();
      final ranges = _splitType == 'page_ranges'
          ? _rangesCtrl.text.trim()
          : null;
      final result = await _service.splitPdf(
        _selectedFile!,
        splitType: _splitType,
        pageRanges: ranges,
        outputPrefix: prefix,
        zip: _zip,
      );
      setState(() {
        _results = result?.files ?? [];
        _statusMessage = 'Split completed: ${_results.length} files.';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Split failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _savePartsLocally() async {
    if (_results.isEmpty) return;
    final baseDir = await FileManager.getSplitPdfsDirectory();
    String targetFolder = _prefixCtrl.text.trim().isEmpty
        ? (_selectedFile != null
              ? p.basenameWithoutExtension(_selectedFile!.path)
              : 'split')
        : _prefixCtrl.text.trim();
    Directory destination = Directory(p.join(baseDir.path, targetFolder));
    int counter = 1;
    while (await destination.exists()) {
      destination = Directory(p.join(baseDir.path, '${targetFolder}_$counter'));
      counter++;
    }
    await destination.create(recursive: true);
    for (final part in _results) {
      final tmp = await _service.downloadConvertedFile(
        part.downloadUrl,
        part.fileName,
      );
      if (tmp != null) {
        await tmp.copy(p.join(destination.path, part.fileName));
      }
    }
    setState(() => _savedFolderPath = destination.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Split PDF',
          style: TextStyle(color: AppColors.textPrimary),
        ),
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
                _buildResultsCard(),
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
    final name = _selectedFile != null
        ? p.basename(_selectedFile!.path)
        : 'No file selected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select PDF',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickPdfFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Choose',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _targetDirectoryPath != null
                ? 'Will save under: $_targetDirectoryPath'
                : 'Will save under: Documents/SmartConverter/PDFConversions/split_pdfs',
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
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<String>(
                value: 'every_page',
                groupValue: _splitType,
                onChanged: (v) => setState(() => _splitType = v!),
              ),
              const Text(
                'Every page',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              Radio<String>(
                value: 'page_ranges',
                groupValue: _splitType,
                onChanged: (v) => setState(() => _splitType = v!),
              ),
              const Text(
                'Page ranges',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rangesCtrl,
            enabled: _splitType == 'page_ranges',
            decoration: const InputDecoration(
              labelText: 'Page ranges',
              hintText: 'e.g., 1-4,5,30,45-50',
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
            controller: _prefixCtrl,
            decoration: const InputDecoration(
              labelText: 'Output prefix',
              hintText: 'Auto from file name',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textTertiary),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _zip,
            onChanged: (v) => setState(() => _zip = v),
            title: const Text(
              'Return zip also',
              style: TextStyle(color: AppColors.textPrimary),
            ),
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
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _splitPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: Text(
                    _isProcessing ? 'Splitting…' : 'Split PDF',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _results.isEmpty ? null : _savePartsLocally,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text(
                    'Save Parts',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_savedFolderPath != null)
            Text(
              'Saved to: $_savedFolderPath',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 8),
          ..._results.map(
            (r) => ListTile(
              title: Text(
                r.fileName,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Pages: ${r.pages.join(', ')}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  final f = await _service.downloadConvertedFile(
                    r.downloadUrl,
                    r.fileName,
                  );
                  if (f != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloaded ${r.fileName}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () async {
                final f = await _service.downloadConvertedFile(
                  r.downloadUrl,
                  r.fileName,
                );
                if (f != null) {
                  await Share.shareXFiles([
                    XFile(f.path),
                  ], text: 'Split part: ${r.fileName}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
