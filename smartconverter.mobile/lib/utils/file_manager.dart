import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Utility class for managing file organization in SmartConverter
class FileManager {
  static const String _smartConverterFolder = 'SmartConverter';

  // Tool-specific folder names
  static const String _addPageNumbersFolder = 'AddPageNumbers';
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
  static const String _pageNumberPdfFolder = 'PageNumberPDF';
  static const String _removePagesFolder = 'RemovePages';
  static const String _extractPagesFolder = 'ExtractPages';
  static const String _pdfConversionsFolder = 'PDFConversions';
  static const String _cropPdfFolder = 'CropPDF';
  static const String _repairPdfFolder = 'RepairPDF';
  static const String _comparePdfFolder = 'ComparePDF';
  static const String _metadataPdfFolder = 'MetadataPDF';
  static const String _mergedPdfsSubFolder = 'merged_pdfs';
  static const String _markdownToPdfSubFolder = 'markdown_to_pdf';
  static const String _htmlToPdfSubFolder = 'html_to_pdf';
  static const String _jpgToPdfSubFolder = 'jpg_to_pdf';
  static const String _pngToPdfSubFolder = 'png_to_pdf';
  static const String _pdfToHtmlSubFolder = 'pdf_to_html';
  static const String _pdfToMarkdownSubFolder = 'pdf_to_markdown';
  static const String _pdfToJsonSubFolder = 'pdf_to_json';
  static const String _pdfToCsvSubFolder = 'pdf_to_csv';
  static const String _pdfToExcelSubFolder = 'pdf_to_excel';
  static const String _pdfToTextSubFolder = 'pdf_to_text';
  static const String _pdfToJpgImagesSubFolder = 'pdf_to_jpg';
  static const String _pdfToPngImagesSubFolder = 'pdf_to_png';
  static const String _pdfToTiffImagesSubFolder = 'pdf_to_tiff';
  static const String _pdfToSvgImagesSubFolder = 'pdf_to_svg';
  static const String _splitPdfsSubFolder = 'split_pdfs';
  static const String _compressedPdfsSubFolder = 'compressed_pdfs';
  static const String _videoConversionsFolder = 'VideoConversions';
  static const String _audioConversionsFolder = 'AudioConversions';
  static const String _videoToAudioFolder = 'video-to-audio';
  static const String _imageConversionsFolder = 'ImageConversions';
  static const String _imagePdfToJpgSubFolder = 'pdf_to_jpg';
  static const String _imagePdfToPngSubFolder = 'pdf_to_png';
  static const String _imagePdfToTiffSubFolder = 'pdf_to_tiff';
  static const String _imagePdfToSvgSubFolder = 'pdf_to_svg';
  static const String _textConversionsFolder = 'TextConversion';
  static const String _wordToTextSubFolder = 'word-to-text';
  static const String _powerpointToTextSubFolder = 'powerpoint-to-text';
  static const String _pdfToTextTextSubFolder = 'pdf-to-text';
  static const String _srtToTextSubFolder = 'srt-to-text';
  static const String _vttToTextSubFolder = 'vtt-to-text';
  static const String _subtitleConversionsFolder = 'SubtitleConversion';
  static const String _srtToCsvSubtitleSubFolder = 'srt-to-csv';
  static const String _srtToExcelSubtitleSubFolder = 'srt-to-excel';
  static const String _srtToTextSubtitleSubFolder = 'srt-to-text';
  static const String _srtToVttSubtitleSubFolder = 'srt-to-vtt';
  static const String _vttToTextSubtitleSubFolder = 'vtt-to-text';
  static const String _vttToSrtSubtitleSubFolder = 'vtt-to-srt';
  static const String _csvToSrtSubtitleSubFolder = 'csv-to-srt';
  static const String _excelToSrtSubtitleSubFolder = 'excel-to-srt';
  static const String _srtTranslateSubFolder = 'srt-translate';
  static const String _websiteConversionsFolder = 'WebsiteConversion';
  static const String _websiteToPdfSubFolder = 'website-to-pdf';
  static const String _wordToHtmlSubFolder = 'word-to-html';
  static const String _powerPointToHtmlSubFolder = 'powerpoint-to-html';
  static const String _markdownToHtmlSubFolder = 'markdown-to-html';
  static const String _websiteToJpgSubFolder = 'website-to-jpg';
  static const String _htmlToJpgSubFolder = 'html-to-jpg';
  static const String _websiteToPngSubFolder = 'website-to-png';
  static const String _htmlToPngSubFolder = 'html-to-png';

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
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pageNumberPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Page Number PDF tool
  static Future<Directory> getPageNumberPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pageNumberPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Merge PDF tool
  static Future<Directory> getMergePdfDirectory() async {
    return await getMergedPdfsDirectory();
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
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_rotatePdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Protect PDF tool
  static Future<Directory> getProtectPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_protectPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Unlock PDF tool
  static Future<Directory> getUnlockPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_unlockPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Watermark PDF tool
  static Future<Directory> getWatermarkPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_watermarkPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Remove Pages tool
  static Future<Directory> getRemovePagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_removePagesFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Extract Pages tool
  static Future<Directory> getExtractPagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_extractPagesFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Crop PDF tool
  static Future<Directory> getCropPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_cropPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Repair PDF tool
  static Future<Directory> getRepairPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_repairPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Compare PDFs tool
  static Future<Directory> getComparePdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_comparePdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Metadata reports
  static Future<Directory> getMetadataPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_metadataPdfFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
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

  /// Get or create the PDF conversions directory
  static Future<Directory> getPdfConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final pdfConversionsDir = Directory(
      '${smartConverterDir.path}/$_pdfConversionsFolder',
    );
    if (!await pdfConversionsDir.exists()) {
      await pdfConversionsDir.create(recursive: true);
    }
    return pdfConversionsDir;
  }

  /// Get or create the Text conversions directory
  static Future<Directory> getTextConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final textConversionsDir = Directory(
      '${smartConverterDir.path}/$_textConversionsFolder',
    );
    if (!await textConversionsDir.exists()) {
      await textConversionsDir.create(recursive: true);
    }
    return textConversionsDir;
  }

  /// Get or create the Subtitle conversions directory
  static Future<Directory> getSubtitleConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final subtitleConversionsDir = Directory(
      '${smartConverterDir.path}/$_subtitleConversionsFolder',
    );
    if (!await subtitleConversionsDir.exists()) {
      await subtitleConversionsDir.create(recursive: true);
    }
    return subtitleConversionsDir;
  }

  /// Get directory for Word to Text outputs (under TextConversion)
  static Future<Directory> getWordToTextDirectory() async {
    final textConversionsDir = await getTextConversionsDirectory();
    final dir = Directory('${textConversionsDir.path}/$_wordToTextSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for PowerPoint to Text outputs (under TextConversion)
  static Future<Directory> getPowerpointToTextDirectory() async {
    final textConversionsDir = await getTextConversionsDirectory();
    final dir = Directory('${textConversionsDir.path}/$_powerpointToTextSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for PDF to Text outputs (under TextConversion)
  static Future<Directory> getPdfToTextTextDirectory() async {
    final textConversionsDir = await getTextConversionsDirectory();
    final dir = Directory('${textConversionsDir.path}/$_pdfToTextTextSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for SRT to Text outputs (under TextConversion)
  static Future<Directory> getSrtToTextDirectory() async {
    final textConversionsDir = await getTextConversionsDirectory();
    final dir = Directory('${textConversionsDir.path}/$_srtToTextSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for VTT to Text outputs (under TextConversion)
  static Future<Directory> getVttToTextDirectory() async {
    final textConversionsDir = await getTextConversionsDirectory();
    final dir = Directory('${textConversionsDir.path}/$_vttToTextSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for SRT to CSV outputs (under SubtitleConversion)
  static Future<Directory> getSrtToCsvSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_srtToCsvSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for SRT to Excel outputs (under SubtitleConversion)
  static Future<Directory> getSrtToExcelSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_srtToExcelSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getSrtToTextSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_srtToTextSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getSrtToVttSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_srtToVttSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getVttToTextSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_vttToTextSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getVttToSrtSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_vttToSrtSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getCsvToSrtSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_csvToSrtSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getExcelToSrtSubtitleDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_excelToSrtSubtitleSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getSrtTranslateDirectory() async {
    final subtitleDir = await getSubtitleConversionsDirectory();
    final dir = Directory('${subtitleDir.path}/$_srtTranslateSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Website conversions directory
  static Future<Directory> getWebsiteConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final websiteConversionsDir = Directory(
      '${smartConverterDir.path}/$_websiteConversionsFolder',
    );
    if (!await websiteConversionsDir.exists()) {
      await websiteConversionsDir.create(recursive: true);
    }
    return websiteConversionsDir;
  }

  /// Get directory for Word to HTML outputs (under WebsiteConversion)
  static Future<Directory> getWordToHtmlDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_wordToHtmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for PowerPoint to HTML outputs (under WebsiteConversion)
  static Future<Directory> getPowerPointToHtmlDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_powerPointToHtmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Markdown to HTML outputs (under WebsiteConversion)
  static Future<Directory> getMarkdownToHtmlDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_markdownToHtmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Website to JPG outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteToJpgDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteToJpgSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for HTML to JPG outputs (under WebsiteConversion)
  static Future<Directory> getHtmlToJpgDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_htmlToJpgSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _websiteHtmlToPdfSubFolder = 'html-to-pdf';

  /// Get directory for HTML to PDF outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteHtmlToPdfDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteHtmlToPdfSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _websiteHtmlToCsvSubFolder = 'html-to-csv';

  /// Get directory for HTML to CSV outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteHtmlToCsvDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteHtmlToCsvSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Website to PNG outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteToPngDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteToPngSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for HTML to PNG outputs (under WebsiteConversion)
  static Future<Directory> getHtmlToPngDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_htmlToPngSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Website to PDF outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteToPdfDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteToPdfSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for Split PDF outputs (under PDFConversions)
  static Future<Directory> getSplitPdfsDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final splitDir = Directory(
      '${pdfConversionsDir.path}/$_splitPdfsSubFolder',
    );
    if (!await splitDir.exists()) {
      await splitDir.create(recursive: true);
    }
    return splitDir;
  }

  static Future<Directory> getCompressedPdfsDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final compressedDir = Directory(
      '${pdfConversionsDir.path}/$_compressedPdfsSubFolder',
    );
    if (!await compressedDir.exists()) {
      await compressedDir.create(recursive: true);
    }
    return compressedDir;
  }

  /// Get directory for merged PDF outputs
  static Future<Directory> getMergedPdfsDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final mergedPdfsDir = Directory(
      '${pdfConversionsDir.path}/$_mergedPdfsSubFolder',
    );
    if (!await mergedPdfsDir.exists()) {
      await mergedPdfsDir.create(recursive: true);
    }
    return mergedPdfsDir;
  }

  /// Get directory for markdown to PDF outputs
  static Future<Directory> getMarkdownToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final markdownToPdfDir = Directory(
      '${pdfConversionsDir.path}/$_markdownToPdfSubFolder',
    );
    if (!await markdownToPdfDir.exists()) {
      await markdownToPdfDir.create(recursive: true);
    }
    return markdownToPdfDir;
  }

  /// Get directory for JPG to PDF outputs
  static Future<Directory> getJpgToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final jpgToPdfDir = Directory(
      '${pdfConversionsDir.path}/$_jpgToPdfSubFolder',
    );
    if (!await jpgToPdfDir.exists()) {
      await jpgToPdfDir.create(recursive: true);
    }
    return jpgToPdfDir;
  }

  /// Get directory for PNG to PDF outputs
  static Future<Directory> getPngToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pngToPdfDir = Directory(
      '${pdfConversionsDir.path}/$_pngToPdfSubFolder',
    );
    if (!await pngToPdfDir.exists()) {
      await pngToPdfDir.create(recursive: true);
    }
    return pngToPdfDir;
  }

  /// Get directory for HTML to PDF outputs
  static Future<Directory> getHtmlToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final htmlToPdfDir = Directory(
      '${pdfConversionsDir.path}/$_htmlToPdfSubFolder',
    );
    if (!await htmlToPdfDir.exists()) {
      await htmlToPdfDir.create(recursive: true);
    }
    return htmlToPdfDir;
  }

  /// Get directory for PDF to HTML outputs
  static Future<Directory> getPdfToHtmlDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToHtmlDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToHtmlSubFolder',
    );
    if (!await pdfToHtmlDir.exists()) {
      await pdfToHtmlDir.create(recursive: true);
    }
    return pdfToHtmlDir;
  }

  /// Get directory for PDF to Markdown outputs
  static Future<Directory> getPdfToMarkdownDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToMarkdownDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToMarkdownSubFolder',
    );
    if (!await pdfToMarkdownDir.exists()) {
      await pdfToMarkdownDir.create(recursive: true);
    }
    return pdfToMarkdownDir;
  }

  /// Get directory for PDF to JSON outputs
  static Future<Directory> getPdfToJsonDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToJsonDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToJsonSubFolder',
    );
    if (!await pdfToJsonDir.exists()) {
      await pdfToJsonDir.create(recursive: true);
    }
    return pdfToJsonDir;
  }

  /// Get directory for PDF to CSV outputs
  static Future<Directory> getPdfToCsvDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToCsvDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToCsvSubFolder',
    );
    if (!await pdfToCsvDir.exists()) {
      await pdfToCsvDir.create(recursive: true);
    }
    return pdfToCsvDir;
  }

  /// Get directory for PDF to Excel outputs
  static Future<Directory> getPdfToExcelDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToExcelDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToExcelSubFolder',
    );
    if (!await pdfToExcelDir.exists()) {
      await pdfToExcelDir.create(recursive: true);
    }
    return pdfToExcelDir;
  }

  /// Get directory for PDF to Text outputs
  static Future<Directory> getPdfToTextDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToTextDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToTextSubFolder',
    );
    if (!await pdfToTextDir.exists()) {
      await pdfToTextDir.create(recursive: true);
    }
    return pdfToTextDir;
  }

  /// Get directory for PDF to JPG image outputs
  static Future<Directory> getPdfToJpgImagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToJpgDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToJpgImagesSubFolder',
    );
    if (!await pdfToJpgDir.exists()) {
      await pdfToJpgDir.create(recursive: true);
    }
    return pdfToJpgDir;
  }

  /// Get directory for PDF to PNG image outputs
  static Future<Directory> getPdfToPngImagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToPngDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToPngImagesSubFolder',
    );
    if (!await pdfToPngDir.exists()) {
      await pdfToPngDir.create(recursive: true);
    }
    return pdfToPngDir;
  }

  /// Get directory for PDF to TIFF image outputs (under PDFConversions)
  static Future<Directory> getPdfToTiffImagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToTiffDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToTiffImagesSubFolder',
    );
    if (!await pdfToTiffDir.exists()) {
      await pdfToTiffDir.create(recursive: true);
    }
    return pdfToTiffDir;
  }

  /// Get directory for PDF to SVG image outputs (under PDFConversions)
  static Future<Directory> getPdfToSvgImagesDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final pdfToSvgDir = Directory(
      '${pdfConversionsDir.path}/$_pdfToSvgImagesSubFolder',
    );
    if (!await pdfToSvgDir.exists()) {
      await pdfToSvgDir.create(recursive: true);
    }
    return pdfToSvgDir;
  }

  /// Get directory for Image Conversions folder
  static Future<Directory> getImageConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final imageConversionsDir = Directory(
      '${smartConverterDir.path}/$_imageConversionsFolder',
    );
    if (!await imageConversionsDir.exists()) {
      await imageConversionsDir.create(recursive: true);
    }
    return imageConversionsDir;
  }

  /// Get directory for Image category subfolders
  static Future<Directory> getImageCategoryDirectory(String subFolder) async {
    final imageConversionsDir = await getImageConversionsDirectory();
    final targetDir = Directory('${imageConversionsDir.path}/$subFolder');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  static Future<Directory> getImagePdfToJpgDirectory() async {
    return getImageCategoryDirectory(_imagePdfToJpgSubFolder);
  }

  static Future<Directory> getImagePdfToPngDirectory() async {
    return getImageCategoryDirectory(_imagePdfToPngSubFolder);
  }

  static Future<Directory> getImagePdfToTiffDirectory() async {
    return getImageCategoryDirectory(_imagePdfToTiffSubFolder);
  }

  static Future<Directory> getImagePdfToSvgDirectory() async {
    return getImageCategoryDirectory(_imagePdfToSvgSubFolder);
  }
}
