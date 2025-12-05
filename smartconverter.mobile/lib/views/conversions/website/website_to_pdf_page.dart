import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:file_picker/file_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class WebsiteToPdfPage extends StatefulWidget {
  const WebsiteToPdfPage({super.key});

  @override
  State<WebsiteToPdfPage> createState() => _WebsiteToPdfPageState();
}

class _WebsiteToPdfPageState extends State<WebsiteToPdfPage>
    with SingleTickerProviderStateMixin {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _htmlContentController = TextEditingController();
  final TextEditingController _cssContentController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  late TabController _tabController;

  File? _selectedFile;
  ImageToPdfResult? _conversionResult;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Enter a URL, select a file, or paste HTML.';
  String? _savedFilePath;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fileNameController.addListener(_handleFileNameChange);
    _admobService.preloadAd();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _urlController.dispose();
    _htmlContentController.dispose();
    _cssContentController.dispose();
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    _admobService.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _statusMessage = 'Enter a URL, select a file, or paste HTML.';
        _conversionResult = null;
        _savedFilePath = null;
      });
    }
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
    // If the file was saved but the user changes the name, allow saving again
    if (_savedFilePath != null) {
      setState(() => _savedFilePath = null);
    }
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

  Future<void> _pickHtmlFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _statusMessage = 'File selected: ${p.basename(file.path)}';
          // Auto-fill filename if not edited
          if (!_fileNameEdited) {
            _fileNameController.text = _sanitizeBaseName(
              p.basenameWithoutExtension(file.path),
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick file: $e', isError: true);
    }
  }

  Future<void> _convert() async {
    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting...';
      _conversionResult = null;
      _savedFilePath = null;
    });

    try {
      final customFilename =
          _fileNameController.text.trim().isNotEmpty
              ? _sanitizeBaseName(_fileNameController.text.trim())
              : null;

      ImageToPdfResult? result;

      switch (_tabController.index) {
        case 0: // URL
          final url = _urlController.text.trim();
          if (url.isEmpty) {
            throw Exception('Please enter a valid URL');
          }
          result = await _service.convertHtmlToPdf(
            url: url,
            outputFilename: customFilename,
          );
          break;
        case 1: // File
          if (_selectedFile == null) {
            throw Exception('Please select an HTML file');
          }
          result = await _service.convertHtmlToPdf(
            htmlFile: _selectedFile,
            outputFilename: customFilename,
          );
          break;
        case 2: // HTML Content
          final content = _htmlContentController.text;
          if (content.isEmpty) {
            throw Exception('Please enter HTML content');
          }
          result = await _service.convertHtmlToPdf(
            htmlContent: content,
            cssContent: _cssContentController.text.trim().isNotEmpty
                ? _cssContentController.text
                : null,
            outputFilename: customFilename,
          );
          break;
      }

      if (!mounted) return;

      if (result == null) {
        throw Exception('Conversion returned no result');
      }

      setState(() {
        _conversionResult = result;
        _statusMessage = 'PDF generated successfully! Saving...';
      });

      // Auto-save the file
      await _savePdfFile(autoSave: true);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Conversion failed: $e');
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isConverting = false);
      }
    }
  }

  Future<void> _savePdfFile({bool autoSave = false}) async {
    final result = _conversionResult;
    if (result == null) return;

    setState(() => _isSaving = true);

    try {
      final directory = await FileManager.getWebsiteToPdfDirectory();

      String targetFileName;
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensurePdfExtension(customName);
      } else {
        targetFileName = result.fileName;
      }

      File destinationFile = File(p.join(directory.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'pdf',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(directory.path, targetFileName));
      }

      final savedFile = await result.file.copy(destinationFile.path);

      if (!mounted) return;

      setState(() {
        _savedFilePath = savedFile.path;
        _statusMessage = 'Saved to: ${p.basename(savedFile.path)}';
      });

      if (autoSave) {
        _showSnackBar('Converted & Saved: ${p.basename(savedFile.path)}', isError: false);
      } else {
        _showSnackBar('Saved to: ${savedFile.path}', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Save failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sharePdfFile() async {
    final result = _conversionResult;
    if (result == null) return;

    final pathToShare = _savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);

    if (!await fileToShare.exists()) {
      _showSnackBar('File not found on disk', isError: true);
      return;
    }

    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Converted PDF: ${result.fileName}');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.pdf')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._ -]+'), '_');
    return base.substring(0, min(base.length, 80));
  }

  String _ensurePdfExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.pdf') ? trimmed : '$trimmed.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Website to PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'URL'),
            Tab(text: 'File'),
            Tab(text: 'HTML'),
          ],
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
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                      case 0:
                        return _buildUrlInput();
                      case 1:
                        return _buildFileInput();
                      case 2:
                        return _buildHtmlInput();
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildFileNameField(),
                const SizedBox(height: 20),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isBannerReady && _bannerAd != null
          ? Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  Widget _buildUrlInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: 'Website URL',
            hintText: 'https://example.com',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFileInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _pickHtmlFile,
          icon: const Icon(Icons.file_upload),
          label: Text(_selectedFile == null ? 'Select HTML File' : 'Change File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: 12),
          Text(
            p.basename(_selectedFile!.path),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ],
    );
  }

  Widget _buildHtmlInput() {
    return Column(
      children: [
        TextField(
          controller: _htmlContentController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'HTML Content',
            hintText: 'Paste your HTML code here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cssContentController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'CSS Content (Optional)',
            hintText: 'body { color: red; }',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFileNameField() {
    return TextField(
      controller: _fileNameController,
      decoration: InputDecoration(
        labelText: 'Output Filename (Optional)',
        hintText: 'my_document',
        prefixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        helperText: '.pdf will be added automatically',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isConverting ? null : _convert,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isConverting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Convert to PDF',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _conversionResult!;
    final isSaved = _savedFilePath != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: AppColors.textPrimary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PDF Ready',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      result.fileName,
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_isSaving || isSaved) ? null : _savePdfFile,
                  icon: const Icon(Icons.save),
                  label: Text(isSaved ? 'Saved' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaved ? AppColors.success : AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sharePdfFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
