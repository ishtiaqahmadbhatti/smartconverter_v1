import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/conversion_service.dart';
import '../services/admob_service.dart';
import 'package:share_plus/share_plus.dart';

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

class _ToolActionPageState extends State<ToolActionPage> {
  final ConversionService _service = ConversionService();
  final AdMobService _admobService = AdMobService();
  File? _selectedFile;
  bool _isProcessing = false;
  String _status = '';
  bool _adWatchedForCurrentFile =
      false; // Track if ad has been watched for current file
  String? _lastFilePath; // Track last processed file path

  @override
  void initState() {
    super.initState();
    // Preload ad if this is MP4 to MP3 conversion
    if (_isMp4ToMp3Conversion()) {
      _admobService.preloadAd();
    }
  }

  @override
  void dispose() {
    _admobService.dispose();
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
          // Reset ad watch status when a new file is selected
          if (_lastFilePath != file.path) {
            _adWatchedForCurrentFile = false;
            _lastFilePath = file.path;
          }
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

    // Check if this is MP4 to MP3 conversion - show rewarded ad first
    // Only show ad if not already watched for this file
    if (_isMp4ToMp3Conversion() && !_adWatchedForCurrentFile) {
      final adShown = await _showRewardedAdDialog();
      if (!adShown) {
        // User didn't watch ad, don't proceed
        return;
      }
      // Mark ad as watched for current file
      _adWatchedForCurrentFile = true;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Processing video to audio...';
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
            _status = '✅ Conversion successful!\nFile saved to:\n$savedPath';
          });

          // Show success dialog with download option
          _showSuccessDialog(convertedFile);
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

  Future<bool> _showRewardedAdDialog() async {
    // First check if ad is ready, if not try to load it
    if (!_admobService.isAdReady) {
      await _admobService.loadRewardedAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!_admobService.isAdReady) {
      // Ad not available, show dialog asking if user wants to proceed anyway
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundSurface,
              title: const Text(
                'Ad Not Available',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: const Text(
                'The ad is not ready. Would you like to proceed with conversion anyway?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ) ??
          false;
    }

    // Show dialog asking user to watch ad
    final watchAd = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSurface,
        title: const Text(
          'Watch Ad to Convert',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Watch a short ad to unlock MP4 to MP3 conversion.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );

    if (watchAd != true) {
      return false;
    }

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    // Show the rewarded ad
    bool adCompleted = false;
    final result = await _admobService.showRewardedAd(
      onRewarded: (reward) {
        adCompleted = true;
        // Mark ad as watched immediately when reward is granted
        _adWatchedForCurrentFile = true;
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ad completed! Starting conversion...'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onFailed: (error) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ad error: $error'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      },
    );

    if (!result && mounted) {
      Navigator.of(context).pop(); // Close loading dialog if still open
    }

    return adCompleted;
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
    final isSuccess = _status.toLowerCase().contains('completed');
    final isError = _status.toLowerCase().startsWith('failed');
    final color = isError
        ? AppColors.warning
        : isSuccess
        ? AppColors.success
        : AppColors.info;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(_status, style: TextStyle(color: color, fontSize: 14)),
    );
  }
}
