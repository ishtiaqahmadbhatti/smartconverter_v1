import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

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
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';
import '../../../models/conversion_model.dart';

class SrtToTextFromTextPage extends StatefulWidget {
  const SrtToTextFromTextPage({super.key});

  @override
  State<SrtToTextFromTextPage> createState() => _SrtToTextFromTextPageState();
}

class _SrtToTextFromTextPageState extends State<SrtToTextFromTextPage>
    with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  final ConversionModel _model = ConversionModel(
    statusMessage: 'Select an SRT file to begin.',
  );

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
    if (_model.fileNameEdited != edited) {
      setState(() => _model.fileNameEdited = edited);
    }
  }

  Future<void> _pickSrtFile() async {
    try {
      // Use FilePicker directly with FileType.any to avoid platform discrepancies with 'srt' filter
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        if (mounted) {
          setState(() => _model.statusMessage = 'No file selected.');
        }
        return;
      }

      final file = File(result.files.single.path!);

      setState(() {
        _model.selectedFile = file;
        _model.conversionResult = null;
        _model.savedFilePath = null;
        _model.statusMessage = 'SRT selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select SRT file: $e';
      if (mounted) {
        setState(() => _model.statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> _convertSrtToText() async {
    if (_model.selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an SRT file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _model.isConverting = true;
      _model.statusMessage = 'Converting SRT to Text...';
      _model.conversionResult = null;
      _model.savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'SRT-to-Text-Text');
    if (!adWatched) {
      setState(() {
        _model.isConverting = false;
        _model.statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    try {
      final customFilename = _fileNameController.text.trim().isNotEmpty
          ? _sanitizeBaseName(_fileNameController.text.trim())
          : null;

      final result = await _service.convertSrtToText(
        _model.selectedFile!,
        outputFilename: customFilename,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _model.statusMessage = 'Conversion completed but no file returned.';
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
        _model.conversionResult = result;
        _model.statusMessage = 'SRT to Text converted successfully!';
        _model.savedFilePath = null;
      });


    } catch (e) {
      if (!mounted) return;
      setState(() => _model.statusMessage = 'Conversion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _model.isConverting = false);
      }
    }
  }

  Future<void> _saveTextFile() async {
    final result = _model.conversionResult;
    if (result == null) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _model.isSaving = true);

    try {
      final directory = await FileManager.getSrtToTextDirectory();

      String targetFileName;
      if (_fileNameController.text.trim().isNotEmpty) {
        final customName = _sanitizeBaseName(_fileNameController.text.trim());
        targetFileName = _ensureTxtExtension(customName);
      } else {
        targetFileName = result.fileName;
      }

      File destinationFile = File(p.join(directory.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          'txt',
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(directory.path, targetFileName));
      }

      final savedFile = await result.file.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _model.savedFilePath = savedFile.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: savedFile.path,
      );

      if (mounted) {
        setState(() {
          _model.statusMessage = 'File saved successfully!';
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
        setState(() => _model.isSaving = false);
      }
    }
  }

  Future<void> _shareTextFile() async {
    final result = _model.conversionResult;
    if (result == null) return;
    final pathToShare = _model.savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);

    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text file is not available on disk.'),
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

  void _updateSuggestedFileName() {
    if (_model.selectedFile == null) {
      setState(() {
        _model.suggestedBaseName = null;
        if (!_model.fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    final baseName = p.basenameWithoutExtension(_model.selectedFile!.path);
    final sanitized = _sanitizeBaseName(baseName);

    setState(() {
      _model.suggestedBaseName = sanitized;
      if (!_model.fileNameEdited) {
        _fileNameController.text = sanitized;
      }
    });
  }

  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.txt')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) {
      base = 'converted_document';
    }
    return base.substring(0, min(base.length, 80));
  }

  String _ensureTxtExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.txt') ? trimmed : '$trimmed.txt';
  }

  void _resetForNewConversion() {
    setState(() {
      _model.reset(defaultStatusMessage: 'Select an SRT file to begin.');
      _fileNameController.clear();
    });
    // Ad loading handled by AdHelper automatically or on next demand
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
          'SRT to Text',
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
                if (_model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _model.savedFilePath != null 
                    ? PersistentResultCard(
                        savedFilePath: _model.savedFilePath!,
                        onShare: _shareTextFile,
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
      title: 'Convert SRT to Text',
      description: 'Extract captions from SRT subtitles and save as .txt',
      iconSource: Icons.insert_drive_file,
      iconTarget: Icons.text_fields,
    );
  }

  Widget _buildActionButtons() {
    return ConversionActionButtons(
      onPickFile: _pickSrtFile,
      onReset: _resetForNewConversion,
      isFileSelected: _model.selectedFile != null,
      isConverting: _model.isConverting,
      buttonText: 'Select SRT File',
    );
  }

  Widget _buildSelectedFileCard() {
    if (_model.selectedFile == null) return const SizedBox.shrink();
    final file = _model.selectedFile!;
    final fileName = p.basename(file.path);
    
    // Check if file still exists before accessing its size
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
      fileIcon: Icons.subtitles,
    );
  }

  Widget _buildFileNameField() {
    if (_model.selectedFile == null) return const SizedBox.shrink();
    final hintText = _model.suggestedBaseName ?? 'converted_document';
    return ConversionFileNameField(
      controller: _fileNameController,
      hintText: hintText,
    );
  }

  Widget _buildConvertButton() {
    final canConvert = _model.selectedFile != null && !_model.isConverting;

    return ConversionConvertButton(
      onConvert: _convertSrtToText,
      isConverting: _model.isConverting,
      isEnabled: canConvert,
    );
  }

  Widget _buildStatusMessage() {
    return ConversionStatusDisplay(
      isConverting: _model.isConverting,
      isSuccess: _model.conversionResult != null,
      message: _model.statusMessage,
    );
  }

  Widget _buildResultCard() {
    return ConversionResultSaveCard(
      fileName: _model.conversionResult!.fileName,
      isSaving: _model.isSaving,
      onSave: _saveTextFile,
      title: 'Text File Ready',
    );
  }

}
