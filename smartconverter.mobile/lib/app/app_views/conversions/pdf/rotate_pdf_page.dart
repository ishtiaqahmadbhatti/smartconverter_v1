import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app_constants/app_colors.dart';
import '../../../app_services/conversion_service.dart';
import '../../../app_services/notification_service.dart';
import '../../../app_widgets/conversion_result_card_widget.dart';
import '../../../app_utils/file_manager.dart';
import '../../../app_utils/ad_helper.dart';

class RotatePdfPage extends StatefulWidget {
  const RotatePdfPage({super.key});

  @override
  State<RotatePdfPage> createState() => _RotatePdfPageState();
}

class _RotatePdfPageState extends State<RotatePdfPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;
  int _rotation = 90;

  @override
  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
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
      resetAdStatus(file.path);
    });
  }

  Future<void> _rotatePdf() async {
    final file = _selectedFile;
    if (file == null) return;
    
    final adWatched = await showRewardedAdGate(toolName: 'Rotate PDF');
    if (!adWatched) return;

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
    
    await showInterstitialAd();

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
      
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: saved.path,
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
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildSelectedFileCard(),
                const SizedBox(height: 16),
                _buildOptionsCard(),
                const SizedBox(height: 20),
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
              Icons.rotate_right_outlined,
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
                  'Rotate PDF',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Rotate your PDF pages to the desired orientation.',
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
            onPressed: _isProcessing ? null : _pickPdfFile,
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
        if (_selectedFile != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () {
                setState(() {
                  _selectedFile = null;
                  _resultFile = null;
                  _savedFilePath = null;
                  _statusMessage = 'Select a PDF file to begin.';
                  _fileNameController.clear();
                  resetAdStatus(null);
                });
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

  Widget _buildSelectedFileCard() {
    if (_selectedFile == null) return const SizedBox.shrink();

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
                  p.basename(_selectedFile!.path),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatBytes(_selectedFile!.lengthSync()),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rotation Angle:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              DropdownButton<int>(
                value: _rotation,
                dropdownColor: AppColors.backgroundSurface,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                items: const [
                  DropdownMenuItem(value: 90, child: Text('90° CW')),
                  DropdownMenuItem(value: 180, child: Text('180°')),
                  DropdownMenuItem(value: 270, child: Text('270° CW (90° CCW)')),
                ],
                onChanged: _isProcessing
                    ? null
                    : (val) {
                        if (val != null) setState(() => _rotation = val);
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _fileNameController,
          decoration: InputDecoration(
            labelText: 'Output file name (Optional)',
            hintText: 'Enter custom name',
            prefixIcon: const Icon(Icons.edit_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildConvertButton() {
     final bool canProceed = _selectedFile != null && !_isProcessing;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed ? _rotatePdf : null,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : const Text(
                'Rotate PDF',
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
            _isProcessing
                ? Icons.hourglass_empty
                : _resultFile != null
                ? Icons.check_circle
                : Icons.info_outline,
            color: _isProcessing
                ? AppColors.warning
                : _resultFile != null
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
                    : _resultFile != null
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
                      'PDF Rotated',
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Save File', style: TextStyle(fontSize: 14)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                  label: const Text('Share', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
  
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
