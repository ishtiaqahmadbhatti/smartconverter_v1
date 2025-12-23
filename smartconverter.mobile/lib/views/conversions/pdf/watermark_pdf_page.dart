import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../services/conversion_service.dart';
import '../../../services/admob_service.dart';
import '../../../utils/file_manager.dart';

class WatermarkPdfPage extends StatefulWidget {
  const WatermarkPdfPage({super.key});

  @override
  State<WatermarkPdfPage> createState() => _WatermarkPdfPageState();
}

class _WatermarkPdfPageState extends State<WatermarkPdfPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();

  final TextEditingController _watermarkController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;

  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;

  String _position = 'center';

  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  final List<String> _positions = const [
    'top-left',
    'top-center',
    'top-right',
    'middle-left',
    'center',
    'middle-right',
    'bottom-left',
    'bottom-center',
    'bottom-right',
    'top-left-diagonal',
    'top-center-diagonal',
    'top-right-diagonal',
    'middle-left-diagonal',
    'center-diagonal',
    'middle-right-diagonal',
    'bottom-left-diagonal',
    'bottom-center-diagonal',
    'bottom-right-diagonal',
  ];

  @override
  void initState() {
    super.initState();
    _initAds();
    _loadTargetDirectory();
  }

  Future<void> _initAds() async {
    _admobService.preloadAd();
    _loadBannerAd();
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

  Future<void> _loadTargetDirectory() async {
    final dir = await FileManager.getWatermarkPdfDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  @override
  void dispose() {
    _watermarkController.dispose();
    _fileNameController.dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await _service.pickFile(
      allowedExtensions: const ['pdf'],
      type: 'pdf',
    );
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _statusMessage = 'Picked file: ${p.basename(file.path)}';
      });
    }
  }

  Future<void> _applyWatermark() async {
    final file = _selectedFile;
    if (file == null) {
      setState(() => _statusMessage = 'Please select a PDF file first.');
      return;
    }
    final text = _watermarkController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusMessage = 'Watermark text is required.');
      return;
    }
    final name = _fileNameController.text.trim();

    setState(() {
      _isProcessing = true;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'Applying watermark...';
    });

    try {
      final res = await _service.watermarkPdf(
        file,
        text,
        _position,
        outputFilename: name.isNotEmpty ? name : null,
      );
      if (res != null) {
        setState(() {
          _resultFile = res;
          _statusMessage = 'Watermark applied. Ready to save.';
        });
      } else {
        setState(() => _statusMessage = 'Failed to apply watermark.');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveResult() async {
    final res = _resultFile;
    if (res == null) return;
    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getWatermarkPdfDirectory();
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
      setState(() {
        _savedFilePath = saved.path;
        _statusMessage = 'Saved to ${saved.path}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _shareResult() async {
    final path = _savedFilePath ?? _resultFile?.path;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Watermarked PDF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Watermark to PDF')),
      bottomNavigationBar: _isBannerReady && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );
  }

  Widget _buildPickerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_statusMessage),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFile != null
                        ? p.basename(_selectedFile!.path)
                        : 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pick PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _watermarkController,
              decoration: const InputDecoration(
                labelText: 'Watermark text',
                hintText: 'Enter watermark text',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Position:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _position,
                    isExpanded: true,
                    items: _positions
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _position = v ?? 'center'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'Output file name',
                hintText: 'optional',
              ),
            ),
            const SizedBox(height: 8),
            if (_targetDirectoryPath != null)
              Text('Will save under: ${_targetDirectoryPath!}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _applyWatermark,
                    icon: const Icon(Icons.water_drop_outlined),
                    label: Text(
                      _isProcessing ? 'Processing…' : 'Apply Watermark',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resultFile == null || _isSaving
                        ? null
                        : _saveResult,
                    icon: const Icon(Icons.save_alt),
                    label: Text(_isSaving ? 'Saving…' : 'Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _resultFile;
    final saved = _savedFilePath;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Result:'),
            const SizedBox(height: 8),
            if (res == null)
              const Text('No result yet')
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.basename(res.path),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareResult,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Saved: ${saved ?? 'Not saved yet'}'),
            ],
          ],
        ),
      ),
    );
  }
}
