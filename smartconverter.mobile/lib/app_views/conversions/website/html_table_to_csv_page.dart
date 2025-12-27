import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:file_picker/file_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../app_services/admob_service.dart';
import '../../../app_services/conversion_service.dart';
import '../../../utils/file_manager.dart';

class HtmlTableToCsvPage extends StatefulWidget {
  final String? categoryId;
  const HtmlTableToCsvPage({super.key, this.categoryId});

  @override
  State<HtmlTableToCsvPage> createState() => _HtmlTableToCsvPageState();
}

class _HtmlTableToCsvPageState extends State<HtmlTableToCsvPage>
    with SingleTickerProviderStateMixin {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  final TextEditingController _htmlContentController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  late TabController _tabController;

  File? _selectedFile;
  ImageToPdfResult? _conversionResult;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a file or paste HTML content.';
  String? _suggestedBaseName;
  String? _savedFilePath;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fileNameController.addListener(_handleFileNameChange);
    _admobService.preloadAd();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _htmlContentController.dispose();
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
        _statusMessage = 'Select a file or paste HTML content.';
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
        case 0: // File
          if (_selectedFile == null) {
            throw Exception('Please select an HTML file');
          }
          result = await _service.convertHtmlTableToCsv(
            htmlFile: _selectedFile,
            outputFilename: customFilename,
          );
          break;
        case 1: // HTML Content
          final content = _htmlContentController.text;
          if (content.isEmpty) {
            throw Exception('Please enter HTML content');
          }
          result = await _service.convertHtmlTableToCsv(
            htmlContent: content,
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
        _statusMessage = 'CSV generated successfully! Saving...';
      });

      // Auto-save the file
      await _saveCsvFile(autoSave: true);
      
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

  Future<void> _saveCsvFile({bool autoSave = false}) async {
    final result = _conversionResult;
    if (result == null) return;

    setState(() => _isSaving = true);

    try {
      // Use the dedicated CSV directory
      final directory = await FileManager.getWebsiteHtmlToCsvDirectory();

      String targetFileName;
      File destinationFile;
      
      // If user provided a custom name, use it; otherwise use result filename or generated one
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensureCsvExtension(customName);
        destinationFile = File(p.join(directory.path, targetFileName));
      } else {
        // If auto-generated, avoid overwriting
        targetFileName = result.fileName;
        destinationFile = File(p.join(directory.path, targetFileName));
        
        if (await destinationFile.exists()) {
          final fallbackName = FileManager.generateTimestampFilename(
            p.basenameWithoutExtension(targetFileName),
            'csv',
          );
          targetFileName = fallbackName;
          destinationFile = File(p.join(directory.path, targetFileName));
        }
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

  Future<void> _shareCsvFile() async {
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
    ], text: 'Converted CSV: ${result.fileName}');
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
    if (base.toLowerCase().endsWith('.csv')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._ -]+'), '_');
    return base.substring(0, min(base.length, 80));
  }

  String _ensureCsvExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.csv') ? trimmed : '$trimmed.csv';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HTML Table to CSV',
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
            Tab(text: 'File'),
            Tab(text: 'HTML Content'),
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
                _buildHeaderCard(),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                       case 0:
                        return _buildFileInput();
                      case 1:
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.grid_on,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Convert HTML Table to CSV',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Extract tables from HTML files or content to CSV format',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInput() {
    return _buildActionButtons();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConverting ? null : _pickHtmlFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select HTML File' : 'Change File',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: _isConverting
                  ? null
                  : () {
                      setState(() {
                        _selectedFile = null;
                        _conversionResult = null;
                        _isConverting = false;
                        _isSaving = false;
                        _fileNameEdited = false;
                        _suggestedBaseName = null;
                        _savedFilePath = null;
                        _statusMessage = 'Select an HTML file to begin.';
                        _fileNameController.clear();
                      });
                      _admobService.preloadAd();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh),
            ),
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
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'HTML Content',
            hintText: 'Paste your HTML code here...',
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
    final hintText = _suggestedBaseName ?? 'table_export';
    return TextField(
      controller: _fileNameController,
      decoration: InputDecoration(
        labelText: 'Output Filename (Optional)',
        hintText: hintText,
        prefixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.backgroundSurface,
        helperText: '.csv will be added automatically',
        helperStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildConvertButton() {
    final canConvert = !_isConverting && 
        (_tabController.index == 1 || _selectedFile != null);
        
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConvert ? _convert : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isConverting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : const Text(
                'Convert to CSV',
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
            _isConverting
                ? Icons.hourglass_empty
                : _conversionResult != null
                    ? Icons.check_circle
                    : Icons.info_outline,
            color: _isConverting
                ? AppColors.warning
                : _conversionResult != null
                    ? AppColors.success
                    : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isConverting
                    ? AppColors.warning
                    : _conversionResult != null
                        ? AppColors.success
                        : AppColors.textSecondary,
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.table_view,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CSV Ready',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.fileName,
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Flexible(
                flex: isSaved ? 3 : 1,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCsvFile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Save CSV',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (isSaved) ...[
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _shareCsvFile,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundSurface,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
