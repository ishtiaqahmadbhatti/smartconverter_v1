import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../constants/app_colors.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/persistent_result_card.dart';
import '../../../widgets/conversion_status_display.dart';
import '../../../widgets/conversion_result_save_card.dart';
import '../../../widgets/conversion_header_card.dart';
import '../../../widgets/conversion_action_buttons.dart';
import '../../../widgets/conversion_selected_file_card.dart';
import '../../../widgets/conversion_file_name_field.dart';
import '../../../widgets/conversion_convert_button.dart';
import '../../../utils/ad_helper.dart';
import '../../../utils/file_manager.dart';

class PowerPointToTextPage extends StatefulWidget {
  const PowerPointToTextPage({super.key});
  
  @override
  State<PowerPointToTextPage> createState() => _PowerPointToTextPageState();
}

class _PowerPointToTextPageState extends State<PowerPointToTextPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  ImageToPdfResult? _conversionResult;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select a PowerPoint file to begin.';
  String? _suggestedBaseName;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _service.pickFile(
        allowedExtensions: ['ppt', 'pptx'],
        type: 'custom',
      );

      if (file == null) {
        if (mounted) {
          setState(() => _statusMessage = 'No file selected.');
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _conversionResult = null;
        _savedFilePath = null;
        _statusMessage = 'PowerPoint selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select PowerPoint file: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convert() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a PowerPoint file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting PowerPoint to Text...';
      _conversionResult = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'PowerPoint-to-Text');
    if (!adWatched) {
      setState(() {
        _isConverting = false;
        _statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    try {
      final customFilename = _fileNameController.text.trim().isNotEmpty
          ? _sanitizeBaseName(_fileNameController.text.trim())
          : null;

      final result = await _service.convertPowerpointToText(
        _selectedFile!,
        outputFilename: customFilename,
      );

      if (!mounted) return;

      if (result == null) {
         setState(() {
          _statusMessage = 'Conversion completed but no file returned.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conversion completed, but unable to download the file.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _conversionResult = result;
        _statusMessage = 'PowerPoint to Text converted successfully!';
        _savedFilePath = null;
      });


    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Conversion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isConverting = false);
      }
    }
  }

  Future<void> _saveResult() async {
    final result = _conversionResult;
    if (result == null) return;
    
    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getPowerpointToTextDirectory();
      
      String targetFileName;
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensureTxtExtension(customName);
      } else {
        targetFileName = result.fileName;
      }
      
      File destinationFile = File(p.join(dir.path, targetFileName));
      
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'txt',
        );
        targetFileName = fallback;
        destinationFile = File(p.join(dir.path, targetFileName));
      }
      
      final savedFile = await result.file.copy(destinationFile.path);
      
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
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  Future<void> _shareResult() async {
    final result = _conversionResult;
    if (result == null) return;
    final pathToShare = _savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);

    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is not available on disk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Converted Text: ${result.fileName}');
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.txt')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) base = 'converted_document';
    return base.substring(0, min(base.length, 80));
  }

  String _ensureTxtExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.txt') ? trimmed : '$trimmed.txt';
  }

  void _updateSuggestedFileName() {
    if (_selectedFile == null) {
      setState(() {
        _suggestedBaseName = null;
        if (!_fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    final baseName = p.basenameWithoutExtension(_selectedFile!.path);
    final sanitized = _sanitizeBaseName(baseName);

    setState(() {
      _suggestedBaseName = sanitized;
      if (!_fileNameEdited) {
        _fileNameController.text = sanitized;
      }
    });
  }

  void _resetForNewConversion() {
      setState(() {
        _selectedFile = null;
        _conversionResult = null;
        _isConverting = false;
        _isSaving = false;
        _fileNameEdited = false;
        _suggestedBaseName = null;
        _savedFilePath = null;
        _statusMessage = 'Select a PowerPoint file to begin.';
        _fileNameController.clear();
      });
      // Ad loading is handled by mixin or on demand
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PowerPoint to Text',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildSelectedFileCard(),
                const SizedBox(height: 16),
                _buildFileNameField(),
                const SizedBox(height: 20),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildStatusMessage(),
                if (_conversionResult != null) ...[
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

  Widget _buildHeaderCard() {
    return const ConversionHeaderCard(
      title: 'Convert PowerPoint to Text',
      description: 'Extract text from slides and tables in PowerPoint (.ppt, .pptx) and save as .txt',
      iconSource: Icons.slideshow,
      iconTarget: Icons.text_fields,
    );
  }

  Widget _buildActionButtons() {
    return ConversionActionButtons(
      onPickFile: _pickFile,
      onReset: _resetForNewConversion,
      isFileSelected: _selectedFile != null,
      isConverting: _isConverting,
      buttonText: 'Select PowerPoint File',
    );
  }

  Widget _buildSelectedFileCard() {
    if (_selectedFile == null) return const SizedBox.shrink();
    final file = _selectedFile!;
    final fileName = p.basename(file.path);
    
    String fileSize;
    try {
      if (file.existsSync()) {
        fileSize = _formatBytes(file.lengthSync());
      } else {
        fileSize = 'File no longer available';
      }
    } catch (e) {
      fileSize = 'Unknown size';
    }

    return ConversionSelectedFileCard(
      fileName: fileName,
      fileSize: fileSize,
      fileIcon: Icons.slideshow,
    );
  }

  Widget _buildFileNameField() {
    if (_selectedFile == null) return const SizedBox.shrink();
    final hintText = _suggestedBaseName ?? 'converted_presentation';
    return ConversionFileNameField(
      controller: _fileNameController,
      hintText: hintText,
    );
  }

  Widget _buildConvertButton() {
     final canConvert = _selectedFile != null && !_isConverting;

    return ConversionConvertButton(
      onConvert: _convert,
      isConverting: _isConverting,
      isEnabled: canConvert,
    );
  }

  Widget _buildStatusMessage() {
    return ConversionStatusDisplay(
      isConverting: _isConverting,
      isSuccess: _conversionResult != null,
      message: _statusMessage,
    );
  }

  Widget _buildResultCard() {
    return ConversionResultSaveCard(
      fileName: _conversionResult!.fileName,
      isSaving: _isSaving,
      onSave: _saveResult,
      title: 'Text File Ready',
    );
  }

}
