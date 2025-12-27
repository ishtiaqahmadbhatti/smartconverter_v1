import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../app_controllers/constants_controller.dart';
import '../app_controllers/services_controller.dart';
import '../app_controllers/models_controller.dart';
import '../app_controllers/utils_controller.dart';

/// Mixin to handle common logic for Text Conversion pages
mixin TextConversionMixin<T extends StatefulWidget> on State<T>, AdHelper<T> {
  // Abstract requirements
  ConversionModel get model;
  ConversionService get service;
  TextEditingController get fileNameController;
  
  // Configuration getters
  String get fileTypeLabel; // e.g. "Word", "PDF"
  List<String> get allowedExtensions; // e.g. ['doc', 'docx']
  String get conversionToolName; // e.g. "Word-to-Text"
  Future<Directory> get saveDirectory; // e.g. FileManager.getWordToTextDirectory()
  
  // The actual conversion action to perform
  Future<ImageToPdfResult?> performConversion(File file, String? outputName);

  void handleFileNameChange() {
    final trimmed = fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (model.fileNameEdited != edited) {
      setState(() => model.fileNameEdited = edited);
    }
  }

  Future<void> pickFile({String type = 'custom'}) async {
    try {
      final file = await service.pickFile(
        allowedExtensions: allowedExtensions,
        type: type,
      );

      if (file == null) {
        if (mounted) {
          setState(() => model.statusMessage = 'No file selected.');
        }
        return;
      }

      setState(() {
        model.selectedFile = file;
        model.conversionResult = null;
        model.savedFilePath = null;
        model.statusMessage = '$fileTypeLabel file selected: ${p.basename(file.path)}';
        resetAdStatus(file.path);
      });

      updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select $fileTypeLabel file: $e';
      if (mounted) {
        setState(() => model.statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  Future<void> convert() async {
    if (model.selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a $fileTypeLabel file first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      model.isConverting = true;
      model.statusMessage = 'Converting $fileTypeLabel to Text...';
      model.conversionResult = null;
      model.savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: conversionToolName);
    if (!adWatched) {
      setState(() {
        model.isConverting = false;
        model.statusMessage = 'Conversion cancelled (Ad required).';
      });
      return;
    }

    try {
      final customFilename = fileNameController.text.trim().isNotEmpty
          ? sanitizeBaseName(fileNameController.text.trim())
          : null;

      final result = await performConversion(
        model.selectedFile!,
        customFilename,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          model.statusMessage = 'Conversion completed but no file returned.';
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
        model.conversionResult = result;
        model.statusMessage = '$fileTypeLabel to Text converted successfully!';
        model.savedFilePath = null;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => model.statusMessage = 'Conversion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => model.isConverting = false);
      }
    }
  }

  Future<void> saveResult() async {
    final result = model.conversionResult;
    if (result == null) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => model.isSaving = true);

    try {
      final directory = await saveDirectory;

      String targetFileName;
      if (fileNameController.text.trim().isNotEmpty) {
        final customName = sanitizeBaseName(fileNameController.text.trim());
        targetFileName = ensureTxtExtension(customName);
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

      setState(() => model.savedFilePath = savedFile.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: savedFile.path,
      );

      if (mounted) {
        setState(() {
          model.statusMessage = 'File saved successfully!';
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
        setState(() => model.isSaving = false);
      }
    }
  }

  Future<void> shareTextFile() async {
    final result = model.conversionResult;
    if (result == null) return;
    final pathToShare = model.savedFilePath ?? result.file.path;
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

  void updateSuggestedFileName() {
    if (model.selectedFile == null) {
      setState(() {
        model.suggestedBaseName = null;
        if (!model.fileNameEdited) {
          fileNameController.clear();
        }
      });
      return;
    }

    final baseName = p.basenameWithoutExtension(model.selectedFile!.path);
    final sanitized = sanitizeBaseName(baseName);

    setState(() {
      model.suggestedBaseName = sanitized;
      if (!model.fileNameEdited) {
        fileNameController.text = sanitized;
      }
    });
  }

  String sanitizeBaseName(String input) {
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

  String ensureTxtExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.txt') ? trimmed : '$trimmed.txt';
  }

  void resetForNewConversion({String? customStatus}) {
    setState(() {
      model.reset(defaultStatusMessage: customStatus ?? 'Select a $fileTypeLabel file to begin.');
      fileNameController.clear();
    });
    // Ad loading handled by AdHelper automatically or on next demand
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }
}
