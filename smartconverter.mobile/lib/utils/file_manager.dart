import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Utility class for managing file organization in SmartConverter
class FileManager {
  static const String _smartConverterFolder = 'SmartConverter';

  // Tool-specific folder names
  static const String _addPageNumbersFolder = 'AddPageNumbers';
  static const String _mergePdfFolder = 'MergePDF';
  static const String _splitPdfFolder = 'SplitPDF';
  static const String _compressPdfFolder = 'CompressPDF';
  static const String _pdfToWordFolder = 'PdfToWord';
  static const String _wordToPdfFolder = 'WordToPdf';
  static const String _imageToPdfFolder = 'ImageToPdf';
  static const String _pdfToImageFolder = 'PdfToImage';
  static const String _rotatePdfFolder = 'RotatePDF';
  static const String _protectPdfFolder = 'ProtectPDF';
  static const String _unlockPdfFolder = 'UnlockPDF';
  static const String _watermarkPdfFolder = 'WatermarkPDF';
  static const String _removePagesFolder = 'RemovePages';
  static const String _extractPagesFolder = 'ExtractPages';
  static const String _videoConversionsFolder = 'VideoConversions';
  static const String _audioConversionsFolder = 'AudioConversions';
  static const String _videoToAudioFolder = 'video-to-audio';

  /// Get the Documents directory path
  static Future<Directory?> getDocumentsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Documents');
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  /// Get or create the SmartConverter main folder
  static Future<Directory> getSmartConverterDirectory() async {
    final documentsDir = await getDocumentsDirectory();
    if (documentsDir == null) {
      throw Exception('Could not access Documents directory');
    }

    final smartConverterDir = Directory(
      '${documentsDir.path}/$_smartConverterFolder',
    );

    if (!await smartConverterDir.exists()) {
      await smartConverterDir.create(recursive: true);
    }

    return smartConverterDir;
  }

  /// Get or create a tool-specific directory
  static Future<Directory> getToolDirectory(String toolName) async {
    final smartConverterDir = await getSmartConverterDirectory();
    final toolDir = Directory('${smartConverterDir.path}/$toolName');

    if (!await toolDir.exists()) {
      await toolDir.create(recursive: true);
    }

    return toolDir;
  }

  /// Get directory for Add Page Numbers tool
  static Future<Directory> getAddPageNumbersDirectory() async {
    return await getToolDirectory(_addPageNumbersFolder);
  }

  /// Get directory for Merge PDF tool
  static Future<Directory> getMergePdfDirectory() async {
    return await getToolDirectory(_mergePdfFolder);
  }

  /// Get directory for Split PDF tool
  static Future<Directory> getSplitPdfDirectory() async {
    return await getToolDirectory(_splitPdfFolder);
  }

  /// Get directory for Compress PDF tool
  static Future<Directory> getCompressPdfDirectory() async {
    return await getToolDirectory(_compressPdfFolder);
  }

  /// Get directory for PDF to Word tool
  static Future<Directory> getPdfToWordDirectory() async {
    return await getToolDirectory(_pdfToWordFolder);
  }

  /// Get directory for Word to PDF tool
  static Future<Directory> getWordToPdfDirectory() async {
    return await getToolDirectory(_wordToPdfFolder);
  }

  /// Get directory for Image to PDF tool
  static Future<Directory> getImageToPdfDirectory() async {
    return await getToolDirectory(_imageToPdfFolder);
  }

  /// Get directory for PDF to Image tool
  static Future<Directory> getPdfToImageDirectory() async {
    return await getToolDirectory(_pdfToImageFolder);
  }

  /// Get directory for Rotate PDF tool
  static Future<Directory> getRotatePdfDirectory() async {
    return await getToolDirectory(_rotatePdfFolder);
  }

  /// Get directory for Protect PDF tool
  static Future<Directory> getProtectPdfDirectory() async {
    return await getToolDirectory(_protectPdfFolder);
  }

  /// Get directory for Unlock PDF tool
  static Future<Directory> getUnlockPdfDirectory() async {
    return await getToolDirectory(_unlockPdfFolder);
  }

  /// Get directory for Watermark PDF tool
  static Future<Directory> getWatermarkPdfDirectory() async {
    return await getToolDirectory(_watermarkPdfFolder);
  }

  /// Get directory for Remove Pages tool
  static Future<Directory> getRemovePagesDirectory() async {
    return await getToolDirectory(_removePagesFolder);
  }

  /// Get directory for Extract Pages tool
  static Future<Directory> getExtractPagesDirectory() async {
    return await getToolDirectory(_extractPagesFolder);
  }

  /// Get directory for Video Conversions folder
  static Future<Directory> getVideoConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final videoConversionsDir = Directory(
      '${smartConverterDir.path}/$_videoConversionsFolder',
    );

    if (!await videoConversionsDir.exists()) {
      await videoConversionsDir.create(recursive: true);
    }

    return videoConversionsDir;
  }

  /// Get directory for Audio Conversions folder
  static Future<Directory> getAudioConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final audioConversionsDir = Directory(
      '${smartConverterDir.path}/$_audioConversionsFolder',
    );

    if (!await audioConversionsDir.exists()) {
      await audioConversionsDir.create(recursive: true);
    }

    return audioConversionsDir;
  }

  /// Get directory for Video to Audio conversion (from Video category)
  static Future<Directory> getVideoToAudioDirectory() async {
    final videoConversionsDir = await getVideoConversionsDirectory();
    final videoToAudioDir = Directory(
      '${videoConversionsDir.path}/$_videoToAudioFolder',
    );

    if (!await videoToAudioDir.exists()) {
      await videoToAudioDir.create(recursive: true);
    }

    return videoToAudioDir;
  }

  /// Get directory for Video to Audio conversion (from Audio category)
  static Future<Directory> getAudioVideoToAudioDirectory() async {
    final audioConversionsDir = await getAudioConversionsDirectory();
    final videoToAudioDir = Directory(
      '${audioConversionsDir.path}/$_videoToAudioFolder',
    );

    if (!await videoToAudioDir.exists()) {
      await videoToAudioDir.create(recursive: true);
    }

    return videoToAudioDir;
  }

  /// Generate a timestamp-based filename
  static String generateTimestampFilename(String prefix, String extension) {
    final timestamp = DateTime.now();
    final formattedDate =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}';
    return '${prefix}_$formattedDate.$extension';
  }

  /// Save file to tool-specific directory
  static Future<File> saveFileToToolDirectory(
    File sourceFile,
    String toolName,
    String filename,
  ) async {
    final toolDir = await getToolDirectory(toolName);
    final destinationPath = '${toolDir.path}/$filename';
    return await sourceFile.copy(destinationPath);
  }

  /// Get folder structure info
  static Future<Map<String, dynamic>> getFolderStructureInfo() async {
    try {
      final smartConverterDir = await getSmartConverterDirectory();
      final folders = await smartConverterDir.list().toList();

      final folderInfo = <String, dynamic>{};

      for (final folder in folders) {
        if (folder is Directory) {
          final folderName = folder.path.split('/').last;
          final files = await folder.list().toList();
          folderInfo[folderName] = {
            'path': folder.path,
            'fileCount': files.length,
            'files': files.map((f) => f.path.split('/').last).toList(),
          };
        }
      }

      return {
        'mainPath': smartConverterDir.path,
        'folders': folderInfo,
        'totalFolders': folderInfo.length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
