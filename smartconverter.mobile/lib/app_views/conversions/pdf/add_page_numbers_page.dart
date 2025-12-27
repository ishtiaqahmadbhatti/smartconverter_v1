import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../app_services/conversion_service.dart';
import '../../../app_services/admob_service.dart';
import '../../../app_services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../app_utils/file_manager.dart';
import '../../../app_utils/ad_helper.dart';
import '../../../app_constants/app_colors.dart';

class AddPageNumbersPage extends StatefulWidget {
  const AddPageNumbersPage({super.key});

  @override
  State<AddPageNumbersPage> createState() => _AddPageNumbersPageState();
}

class _AddPageNumbersPageState extends State<AddPageNumbersPage> with AdHelper {
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

  @override
  void initState() {
    super.initState();
    _loadTargetDirectory();
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

  Future<void> _applyPageNumbers() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Preparing...';
      _resultFile = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Add Page Numbers');
    if (!adWatched) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Operation cancelled (Ad required).';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Applying page numbers…';
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

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

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

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: saved.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'File saved successfully!';
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
    await Share.shareXFiles([XFile(f.path)], text: 'Numbered PDF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Page Numbers', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildSelectedFileCard(),
                const SizedBox(height: 16),
                _buildOptionsCard(),
                const SizedBox(height: 16),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_resultFile != null) ...[
                   const SizedBox(height: 20),
                   _savedFilePath != null
                     ? ConversionResultCardWidget(
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
              Icons.format_list_numbered,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Add Page Numbers',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Insert page numbers into your PDF documents with custom formatting and positioning.',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (_isProcessing) ? null : _pickPdfFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFile == null ? 'Select PDF File' : 'Change File',
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
      ],
    );
  }

  Widget _buildSelectedFileCard() {
    if (_selectedFile == null) {
      return const SizedBox.shrink();
    }

    final file = _selectedFile!;
    final fileName = p.basename(file.path);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Options', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Position:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _position,
                  dropdownColor: AppColors.backgroundDark,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: _positions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: _isProcessing ? null : (v) => setState(() => _position = v ?? 'bottom-center'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startPageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Start Number',
                     hintText: '1',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Font Size',
                     hintText: '12',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _formatController,
            decoration: InputDecoration(
               labelText: 'Format (use {page} placeholder)',
               hintText: '{page}',
               labelStyle: const TextStyle(color: AppColors.textSecondary),
               hintStyle: const TextStyle(color: AppColors.textTertiary),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
               filled: true,
               fillColor: AppColors.backgroundDark,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
               labelText: 'Output Filename (Optional)',
               hintText: 'custom_name',
               labelStyle: const TextStyle(color: AppColors.textSecondary),
               hintStyle: const TextStyle(color: AppColors.textTertiary),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
               filled: true,
               fillColor: AppColors.backgroundDark,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertButton() {
     final canConvert = _selectedFile != null && !_isProcessing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canConvert ? _applyPageNumbers : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isProcessing
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
                'Apply Page Numbers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final bool isSuccess = _resultFile != null || _savedFilePath != null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isProcessing
                    ? Icons.hourglass_empty
                    : isSuccess
                    ? Icons.check_circle
                    : Icons.info_outline,
                color: _isProcessing
                    ? AppColors.warning
                    : isSuccess
                    ? AppColors.success
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _isProcessing
                        ? AppColors.warning
                        : isSuccess
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _resultFile;
    if (res == null) return const SizedBox.shrink();

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
                  Icons.check_circle_outline,
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
                      'Ready to Save',
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
          SizedBox(
            width: double.infinity,
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
              label: const Text(
                'Save File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundSurface,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
