import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';

class PdfCompressPage extends StatefulWidget {
  const PdfCompressPage({super.key});

  @override
  State<PdfCompressPage> createState() => _PdfCompressPageState();
}

class _PdfCompressPageState extends State<PdfCompressPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _targetPctController = TextEditingController();
  final TextEditingController _dpiController = TextEditingController();
  // final AdMobService _admobService = AdMobService(); // Removed as AdHelper handles it

  File? _selectedFile;
  CompressPdfResult? _result;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a PDF file to begin.';
  String? _targetDirectoryPath;
  String? _savedFilePath;
  String _compressionLevel = 'medium';

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    _targetPctController.dispose();
    _dpiController.dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  Future<void> _loadTargetDirectoryPath() async {
    final dir = await FileManager.getCompressedPdfsDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  Future<void> _pickPdfFile() async {
    try {
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
        _result = null;
        _savedFilePath = null;
        _statusMessage = '1 PDF file selected.';
        resetAdStatus(file.path);
      });
      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select PDF file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  void _updateSuggestedFileName() {
    final file = _selectedFile;
    if (file == null) {
      setState(() {
        _savedFilePath = null;
        if (!_fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }
    final base = p.basenameWithoutExtension(file.path);
    final sanitized = _sanitizeBaseName(base.isNotEmpty ? base : 'document');
    setState(() {
      if (!_fileNameEdited) {
        _fileNameController.text = sanitized;
      }
    });
  }

  String _sanitizeBaseName(String input) {
    final sanitized = input
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'^[._]+|[._]+$'), '');
    return sanitized.isEmpty ? 'document' : sanitized;
  }

  Future<void> _compress() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Compressing...';
      _result = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Compress PDF');
    if (!adWatched) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Compression cancelled (Ad required).';
      });
      return;
    }
    try {
      final pct = int.tryParse(_targetPctController.text.trim());
      final dpi = int.tryParse(_dpiController.text.trim());
      final base = _fileNameController.text.trim();
      final outputName = base.isNotEmpty ? base : null;
      final res = await _service.compressPdfFile(
        file,
        compressionLevel: _compressionLevel,
        targetReductionPct: pct,
        maxImageDpi: dpi,
        outputFilename: outputName,
      );
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Compression failed.');
        return;
      }
      setState(() {
        _result = res;
        final before = res.sizeBefore ?? 0;
        final after = res.sizeAfter ?? 0;
        final achieved = res.achievedReductionPct;
        final pctText = achieved != null
            ? '${achieved.toStringAsFixed(2)}%'
            : (before > 0
                  ? '${(((before - after) * 100.0) / before).toStringAsFixed(2)}%'
                  : '—');
        _statusMessage = 'Compressed: $pctText reduction';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Compression failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveCompressedFile() async {
    final res = _result;
    if (res == null) return;
    
    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();
    
    setState(() => _isSaving = true);
    try {
      final directory = await FileManager.getCompressedPdfsDirectory();
      String targetFileName = res.fileName;
      File destinationFile = File(p.join(directory.path, targetFileName));
      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          _sanitizeBaseName(p.basenameWithoutExtension(targetFileName)),
          'pdf',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(directory.path, targetFileName));
      }
      final savedFile = await res.file.copy(destinationFile.path);
      if (!mounted) return;
      
      setState(() => _savedFilePath = savedFile.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: savedFile.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'File saved successfully!';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareCompressedFile() async {
    final res = _result;
    if (res == null) return;
    final pathToShare = _savedFilePath ?? res.file.path;
    final fileToShare = File(pathToShare);
    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compressed file is not available on disk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Compressed PDF: ${res.fileName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Compress PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
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
                _buildCompressButton(),
                const SizedBox(height: 12),
                _buildStatusMessage(),
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? PersistentResultCard(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareCompressedFile,
                      )
                    : _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusMessage,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _buildPickerCard() {
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
                  _selectedFile != null
                      ? p.basename(_selectedFile!.path)
                      : 'No file selected',
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
                : 'Will save under: Documents/SmartConverter/PDFConversions/compressed_pdfs',
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _compressionLevel,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: _isProcessing
                      ? null
                      : (v) =>
                            setState(() => _compressionLevel = v ?? 'medium'),
                  decoration: const InputDecoration(
                    labelText: 'Compression Level',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textTertiary),
                    ),
                  ),
                  dropdownColor: AppColors.backgroundCard,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetPctController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target reduction %',
                    hintText: 'e.g., 30',
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
                  controller: _dpiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max image DPI',
                    hintText: 'e.g., 96 or 150',
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
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'Suggested base name',
              hintText: 'Auto from file name',
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

  Widget _buildCompressButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_selectedFile == null || _isProcessing)
            ? null
            : _compress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isProcessing ? 'Compressing…' : 'Compress PDF',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _result!;
    
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
                  Icons.picture_as_pdf,
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
                      'PDF Compressed',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(res.sizeBefore ?? 0)} -> ${(res.sizeAfter ?? 0)} bytes',
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
              Flexible(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCompressedFile,
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
                  label: const Text('Save Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _shareCompressedFile,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
