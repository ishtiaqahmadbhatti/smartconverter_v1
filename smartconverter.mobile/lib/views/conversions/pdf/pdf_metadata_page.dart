import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';

class PdfMetadataPage extends StatefulWidget {
  const PdfMetadataPage({super.key});
  @override
  State<PdfMetadataPage> createState() => _PdfMetadataPageState();
}

class _PdfMetadataPageState extends State<PdfMetadataPage> with AdHelper {
  final ConversionService _service = ConversionService();
  // final AdMobService _admobService = AdMobService(); // Handled by AdHelper
  final TextEditingController _fileNameController = TextEditingController();
  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
  }

  Future<void> _loadTargetDirectoryPath() async {
    final dir = await FileManager.getMetadataPdfDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
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
      resetAdStatus(file.path);
    });
  }

  Future<void> _getMetadata() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Extracting metadata…';
      _resultFile = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Get PDF Metadata');
    if (!adWatched) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Extraction cancelled (Ad required).';
      });
      return;
    }
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.getPdfMetadataFile(file, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Metadata extraction failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Metadata JSON ready';
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
    
    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getMetadataPdfDirectory();
      String targetFileName = p.basename(res.path);
      File destinationFile = File('${dir.path}/$targetFileName');
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'json',
        );
        targetFileName = fallback;
        destinationFile = File('${dir.path}/$targetFileName');
      }
      final saved = await res.copy(destinationFile.path);
      if (!mounted) return;
      
      setState(() => _savedFilePath = saved.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: saved.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'Metadata saved successfully!';
        });
      }
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
    await Share.shareXFiles([XFile(f.path)], text: 'PDF Metadata');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Get PDF Metadata', style: TextStyle(color: AppColors.textPrimary)),
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
                _buildExtractButton(),
                const SizedBox(height: 12),
                _buildStatusMessage(),
                if (_resultFile != null) ...[
                  const SizedBox(height: 20),
                  _savedFilePath != null 
                    ? PersistentResultCard(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareResult,
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
                : 'Will save under: Documents/SmartConverter/PDFConversions/MetadataPDF',
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

  Widget _buildExtractButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_selectedFile == null || _isProcessing) ? null : _getMetadata,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isProcessing ? 'Processing…' : 'Get Metadata',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _resultFile!;
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
                  Icons.data_object,
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
                      'Metadata Ready',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.basename(res.path),
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
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveResult,
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
                  label: const Text('Save JSON'),
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
                  onPressed: _shareResult,
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

