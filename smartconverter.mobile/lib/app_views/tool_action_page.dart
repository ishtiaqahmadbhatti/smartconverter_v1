import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../app_modules/imports_module.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import '../utils/permission_manager.dart';
import '../utils/ad_helper.dart';

class ToolActionPage extends StatefulWidget {
  final String categoryId;
  final String toolName;
  final IconData categoryIcon;

  const ToolActionPage({
    super.key,
    required this.categoryId,
    required this.toolName,
    required this.categoryIcon,
  });

  @override
  State<ToolActionPage> createState() => _ToolActionPageState();
}

class _ToolActionPageState extends State<ToolActionPage> with AdHelper {
  final ConversionService _service = ConversionService();
  File? _selectedFile;
  bool _isProcessing = false;
  String _status = '';
  String? _savedFilePath;
  String? _lastFilePath; // Track last processed file path

  @override
  void initState() {
    super.initState();
    // AdHelper handles preloading and banner loading
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isMp4ToMp3Conversion() {
    // DRY principle: Detect MP4 to MP3 from both Audio and Video categories
    return widget.toolName.toLowerCase().contains('mp4 to mp3') ||
        (widget.toolName.toLowerCase().contains('video to audio') &&
            widget.categoryId.contains('video')) ||
        (widget.categoryId.contains('audio') &&
            widget.toolName.toLowerCase().contains('mp4'));
  }

  List<String> _resolveAllowedExtensions() {
    // Special case: MP4 to MP3 conversion needs video files as input
    // Works for both Audio and Video categories (DRY principle)
    if (widget.toolName.toLowerCase().contains('mp4 to mp3') ||
        widget.toolName.toLowerCase().contains('video to audio')) {
      return ['mp4', 'mov', 'mkv', 'avi', 'wmv', 'flv', 'webm', 'm4v'];
    }

    if (widget.categoryId.contains('json')) return ['json', 'txt'];
    if (widget.categoryId.contains('xml')) return ['xml', 'txt'];
    if (widget.categoryId.contains('csv')) return ['csv', 'txt'];
    if (widget.categoryId.contains('pdf')) return ['pdf'];
    if (widget.categoryId.contains('image')) return ['png', 'jpg', 'jpeg'];
    if (widget.categoryId.contains('audio'))
      return ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'];
    if (widget.categoryId.contains('video'))
      return ['mp4', 'mov', 'mkv', 'avi', 'wmv', 'flv', 'webm', 'm4v'];
    if (widget.categoryId.contains('ebook')) return ['epub', 'mobi', 'pdf'];
    return [];
  }

  Future<void> _pickFile() async {
    try {
      // Determine file type for better picker support
      String? fileType;
      final extensions = _resolveAllowedExtensions();

      // Special handling for MP4 to MP3 - needs video files
      if (widget.toolName.toLowerCase().contains('mp4 to mp3') ||
          widget.toolName.toLowerCase().contains('video to audio')) {
        fileType = 'video';
      } else if (widget.categoryId.contains('video')) {
        fileType = 'video';
      } else if (widget.categoryId.contains('audio')) {
        fileType = 'audio';
      } else if (widget.categoryId.contains('image')) {
        fileType = 'image';
      }

      final file = await _service.pickFile(
        allowedExtensions: extensions,
        type: fileType,
      );
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _status = 'Selected: ${file.path.split('/').last}';
          _savedFilePath = null; // Clear previous result
          // Reset ad watch status when a new file is selected
          _savedFilePath = null; // Clear previous result
          // Reset ad watch status when a new file is selected
          resetAdStatus(file.path);
        });
      } else {
        setState(() => _status = 'No file selected');
      }
    } catch (e) {
      String errorMessage = 'Failed to select file';
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('permission') || errorStr.contains('denied')) {
        errorMessage = 'Permission denied. Please grant storage access.';
      } else if (errorStr.contains('not exist')) {
        errorMessage = 'Selected file does not exist.';
      } else if (errorStr.contains('platform') ||
          errorStr.contains('support')) {
        errorMessage = 'File picking not supported on this device.';
      } else if (errorStr.contains('cancel')) {
        errorMessage = 'File selection cancelled.';
      }

      setState(() => _status = errorMessage);

      // Show snackbar for better visibility
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _process() async {
    if (_selectedFile == null) {
      setState(() => _status = 'Please select a file first');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video file first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Check for storage permissions first
    if (!await PermissionManager.isStoragePermissionGranted()) {
      final granted = await PermissionManager.requestStoragePermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to save files.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    // Check if this is MP4 to MP3 conversion - show rewarded ad first
    // Only show ad if not already watched for this file and ads are enabled
    if (_isMp4ToMp3Conversion()) {
      final adWatched = await showRewardedAdGate(toolName: 'MP4 to MP3');
      if (!adWatched) return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Processing video to audio...';
      _savedFilePath = null; // Clear previous result
    });

    try {
      File? result;

      // Check if this is a video-to-audio conversion (from both Audio and Video categories)
      // DRY principle: Same method handles both categories
      if (widget.toolName.toLowerCase().contains('video to audio') ||
          widget.toolName.toLowerCase().contains('mp4 to mp3') ||
          (widget.categoryId.contains('video') &&
              widget.toolName.toLowerCase().contains('audio')) ||
          (widget.categoryId.contains('audio') &&
              widget.toolName.toLowerCase().contains('mp4'))) {
        // Determine preferred endpoint and category based on categoryId
        String? preferredEndpoint = widget.categoryId.contains('audio')
            ? 'audio'
            : null;
        String? category = widget.categoryId.contains('audio')
            ? 'audio'
            : 'video';

        // Call unified video-to-audio conversion method (works for both categories)
        result = await _service.convertVideoToAudio(
          _selectedFile!,
          bitrate: '192k',
          quality: 'medium',
          outputFormat: 'mp3',
          preferredEndpoint: preferredEndpoint,
          category: category,
        );

        if (result != null && result.existsSync()) {
          final convertedFile = result;
          final savedPath = convertedFile.path;

          setState(() {
            _isProcessing = false;
            _status = '✅ Conversion successful!\nFile saved to SmartConverter folder';
            _savedFilePath = savedPath;
          });


          // Trigger System Notification
          await NotificationService.showFileSavedNotification(
            fileName: p.basename(savedPath),
            filePath: savedPath,
          );
        } else {
          throw Exception('Conversion failed: File was not created properly');
        }
      } else {
        // Placeholder for other conversions
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isProcessing = false;
          _status = 'Completed (Placeholder)';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion failed: ${e.toString()}'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showSuccessDialog(File convertedFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSurface,
          title: const Text(
            'Conversion Successful!',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your video has been converted to audio successfully.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                'Saved to:\n${convertedFile.path}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Share.shareXFiles([XFile(convertedFile.path)]);
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.toolName,
          style: const TextStyle(
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
                _buildHeader(),
                const SizedBox(height: 16),
                _buildPicker(),
                const SizedBox(height: 16),
                _buildAction(),
                const SizedBox(height: 16),
                if (_status.isNotEmpty) _buildStatus(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.categoryIcon,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.toolName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile == null ? Icons.cloud_upload : Icons.check_circle,
              size: 48,
              color: _selectedFile == null
                  ? AppColors.primaryBlue
                  : AppColors.success,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile == null ? 'Tap to select file' : 'File selected',
              style: TextStyle(
                color: _selectedFile == null
                    ? AppColors.textPrimary
                    : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 6),
              Text(
                _selectedFile!.path.split('/').last,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAction() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _process,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : const Text('Process'),
      ),
    );
  }

  Widget _buildStatus() {
    if (_status.isEmpty && _savedFilePath == null) return const SizedBox.shrink();

    final isSuccess = _status.toLowerCase().contains('successful') ||
        _status.toLowerCase().contains('completed') ||
        _savedFilePath != null;
    final isError = _status.toLowerCase().startsWith('failed');
    final color = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.info;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isError ? Icons.error_outline : isSuccess ? Icons.check_circle : Icons.info_outline,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isError ? 'CONVERSION FAILED' : 'CONVERSION RESULT',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_savedFilePath != null) ...[
            const Text(
              'FILE SAVED AT:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _savedFilePath!.replaceFirst('/storage/emulated/0/', ''),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                       if (!await File(_savedFilePath!).exists()) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File no longer exists.')),
                            );
                          }
                          return;
                       }
                       await NotificationService.openFile(_savedFilePath!);
                    },
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Open File'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final folderPath = p.dirname(_savedFilePath!);
                      await NotificationService.openFile(folderPath);
                    },
                    icon: const Icon(Icons.folder_open, size: 14),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Folder File'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(_savedFilePath!)]),
                    icon: const Icon(Icons.share, size: 14),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Share'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryGreen,
                      side: const BorderSide(color: AppColors.secondaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              _status,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
