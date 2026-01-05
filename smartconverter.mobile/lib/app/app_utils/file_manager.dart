import '../app_modules/imports_module.dart';

/// Utility class for managing file organization in SmartConverter
class FileManager {
  static const String _smartConverterFolder = 'SmartConverter';

  // Tool-specific folder names
  static const String _addPageNumbersFolder = 'add-page-numbers';
  static const String _splitPdfFolder = 'split-pdf';
  static const String _compressPdfFolder = 'compress-pdf';
  static const String _pdfToWordFolder = 'pdf-to-word';
  static const String _wordToPdfFolder = 'word-to-pdf';
  static const String _imageToPdfFolder = 'image-to-pdf';
  static const String _pdfToImageFolder = 'pdf-to-image';
  static const String _rotatePdfFolder = 'rotate-pdf';
  static const String _protectPdfFolder = 'protect-pdf';
  static const String _unlockPdfFolder = 'unlock-pdf';
  static const String _watermarkPdfFolder = 'watermark-pdf';
  static const String _pageNumberPdfFolder = 'page-number-pdf';
  static const String _removePagesFolder = 'remove-pages';
  static const String _extractPagesFolder = 'extract-pages';
  static const String _pdfConversionsFolder = 'PDFConversion';
  static const String _cropPdfFolder = 'crop-pdf';
  static const String _repairPdfFolder = 'repair-pdf';
  static const String _comparePdfFolder = 'compare-pdfs';
  static const String _metadataPdfFolder = 'metadata-pdf';
  static const String _mergedPdfsSubFolder = 'merged-pdfs';
  static const String _markdownToPdfSubFolder = 'markdown-to-pdf';
  static const String _htmlToPdfSubFolder = 'html-to-pdf';
  static const String _jpgToPdfSubFolder = 'jpg-to-pdf';
  static const String _pngToPdfSubFolder = 'png-to-pdf';
  static const String _pdfToHtmlSubFolder = 'pdf-to-html';
  static const String _pdfToMarkdownSubFolder = 'pdf-to-markdown';
  static const String _pdfToJsonSubFolder = 'pdf-to-json';
  static const String _pdfToCsvSubFolder = 'pdf-to-csv';
  static const String _pdfToWordSubFolder = 'pdf-to-word';
  static const String _pdfToExcelSubFolder = 'pdf-to-excel';
  static const String _pdfToTextSubFolder = 'pdf-to-text';
  static const String _pdfToJpgImagesSubFolder = 'pdf-to-jpg';
  static const String _pdfToPngImagesSubFolder = 'pdf-to-png';
  static const String _pdfToTiffImagesSubFolder = 'pdf-to-tiff';
  static const String _pdfToSvgImagesSubFolder = 'pdf-to-svg';
  static const String _splitPdfsSubFolder = 'split-pdfs';
  static const String _compressedPdfsSubFolder = 'compressed-pdfs';
  static const String _pdfExcelToXpsSubFolder = 'excel-to-xps';
  static const String _pdfOdsToPdfSubFolder = 'ods-to-pdf';
  static const String _pdfOxpsToPdfSubFolder = 'oxps-to-pdf';
  static const String _videoConversionsFolder = 'VideoConversions';
  static const String _audioConversionsFolder = 'AudioConversions';
  static const String _videoToAudioFolder = 'video-to-audio';
  static const String _imageConversionsFolder = 'ImageConversion';
  static const String _imagePdfToJpgSubFolder = 'pdf-to-jpg';
  static const String _imagePdfToPngSubFolder = 'pdf-to-png';
  static const String _imagePdfToTiffSubFolder = 'pdf-to-tiff';
  static const String _imagePdfToSvgSubFolder = 'pdf-to-svg';
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
  static const String _jsonConversionsFolder = 'JSONConversion';
  static const String _jsonPdfToJsonSubFolder = 'pdf-to-json';

  static const String _csvConversionsFolder = 'CSVConversion';
  static const String _htmlTableToCsvSubFolder = 'html-table-to-csv';
  static const String _excelToCsvSubFolder = 'excel-to-csv';
  static const String _odsToCsvSubFolder = 'ods-to-csv';
  static const String _csvToExcelSubFolder = 'csv-to-excel';
  static const String _csvToXmlSubFolder = 'csv-to-xml';
  static const String _csvPdfToCsvSubFolder = 'pdf-to-csv';
  static const String _csvHtmlTableToCsvSubFolder = 'html-table-to-csv';
  static const String _csvXmlToCsvSubFolder = 'xml-to-csv';
  static const String _csvJsonToCsvSubFolder = 'json-to-csv';
  static const String _csvCsvToJsonSubFolder = 'csv-to-json';
  static const String _csvJsonObjectsToCsvSubFolder = 'json-object-to-csv';

  static const String _officeDocumentsConversionsFolder = 'OfficeDocumentsConversion';
  static const String _officePdfToCsvSubFolder = 'pdf-to-csv';
  static const String _officePdfToExcelSubFolder = 'pdf-to-excel';
  static const String _officePdfToWordSubFolder = 'pdf-to-word';
  static const String _officeWordToPdfSubFolder = 'word-to-pdf';
  static const String _officeWordToHtmlSubFolder = 'word-to-html';
  static const String _officeWordToTextSubFolder = 'word-to-text';
  static const String _officePowerPointToPdfSubFolder = 'powerpoint-to-pdf';
  static const String _officePowerPointToHtmlSubFolder = 'powerpoint-to-html';
  static const String _officePowerPointToTextSubFolder = 'powerpoint-to-text';
  static const String _officeExcelToPdfSubFolder = 'excel-to-pdf';
  static const String _officeExcelToXpsSubFolder = 'excel-to-xps';
  static const String _officeExcelToHtmlSubFolder = 'excel-to-html';
  static const String _officeExcelToCsvSubFolder = 'excel-to-csv';
  static const String _officeExcelToOdsSubFolder = 'excel-to-ods';
  static const String _officeExcelToXmlSubFolder = 'excel-to-xml';
  static const String _officeOdsToCsvSubFolder = 'ods-to-csv';
  static const String _officeOdsToPdfSubFolder = 'ods-to-pdf';
  static const String _officeOdsToExcelSubFolder = 'ods-to-excel';
  static const String _officeCsvToExcelSubFolder = 'csv-to-excel';
  static const String _officeXmlToCsvSubFolder = 'xml-to-csv';
  static const String _officeXmlToExcelSubFolder = 'xml-to-excel';
  static const String _officeJsonToExcelSubFolder = 'json-to-excel';
  static const String _officeExcelToJsonSubFolder = 'excel-to-json';
  static const String _officeJsonObjectsToExcelSubFolder = 'json-objects-to-excel';
  static const String _officeBsonToExcelSubFolder = 'bson-to-excel';
  static const String _officeSrtToExcelSubFolder = 'srt-to-excel';
  static const String _officeSrtToXlsxSubFolder = 'srt-to-xlsx';
  static const String _officeSrtToXlsSubFolder = 'srt-to-xls';
  static const String _officeExcelToSrtSubFolder = 'excel-to-srt';
  static const String _officeXlsxToSrtSubFolder = 'xlsx-to-srt';
  static const String _officeXlsToSrtSubFolder = 'xls-to-srt';

  static const String _jsonToCsvSubFolder = 'json-to-csv';
  static const String _csvToJsonSubFolderLegacy = 'csv-to-json'; // Renamed to avoid conflict if any, utilizing consistent naming

  static const String _bsonToCsvSubFolder = 'bson-to-csv';
  static const String _srtToCsvSubFolder = 'srt-to-csv';
  static const String _csvToSrtSubFolder = 'csv-to-srt';

  /// Get the Documents directory path
  static Future<Directory?> getDocumentsDirectory() async {
    if (Platform.isAndroid) {
      // 1. Try to use Public Documents folder first (Visible to all file managers)
      // This is the ideal location for "View Folder" actions to work correctly.
      final publicDocs = Directory('/storage/emulated/0/Documents');
      
      try {
        if (!await publicDocs.exists()) {
          await publicDocs.create(recursive: true);
        }
        return publicDocs;
      } catch (e) {
        print('DEBUG: Failed to access public Documents: $e');
      }

      // 2. Fallback: App-specific external storage
      // Note: Sub-directories here are often HIDDEN from third-party explorers on Android 11+.
      final externalDirs = await getExternalStorageDirectories(type: StorageDirectory.documents);
      if (externalDirs != null && externalDirs.isNotEmpty) {
        return externalDirs.first;
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  /// Get the temporary directory
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get the app's main document directory (SmartConverter folder)
  static Future<Directory> getAppDirectory() async {
    return await getSmartConverterDirectory();
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
      print('DEBUG: Creating SmartConverter directory at ${smartConverterDir.path}');
      await smartConverterDir.create(recursive: true);
    }

    try {
      final canRead = await Directory(smartConverterDir.path).exists();
      print('DEBUG: SmartConverter dir accessibility - Path: ${smartConverterDir.path}');
      print('DEBUG: SmartConverter dir accessibility - Exists: $canRead');
    } catch (e) {
      print('DEBUG: Error checking SmartConverter dir accessibility: $e');
    }

    return smartConverterDir;
  }

  /// Get or create the JSONConversion folder
  static Future<Directory> getJsonConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final jsonConversionsDir = Directory(
      '${smartConverterDir.path}/$_jsonConversionsFolder',
    );

    if (!await jsonConversionsDir.exists()) {
      await jsonConversionsDir.create(recursive: true);
    }

    return jsonConversionsDir;
  }

  /// Get or create the CSVConversion folder
  static Future<Directory> getCsvConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final csvConversionsDir = Directory(
      '${smartConverterDir.path}/$_csvConversionsFolder',
    );

    if (!await csvConversionsDir.exists()) {
      await csvConversionsDir.create(recursive: true);
    }

    return csvConversionsDir;
  }

  /// Get or create the Office Documents Conversion folder
  static Future<Directory> getOfficeDocumentsConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final officeDocsDir = Directory(
      '${smartConverterDir.path}/$_officeDocumentsConversionsFolder',
    );

    if (!await officeDocsDir.exists()) {
      await officeDocsDir.create(recursive: true);
    }

    return officeDocsDir;
  }

  static Future<Directory> _getOfficeSubDir(String subFolder) async {
    final rootDir = await getOfficeDocumentsConversionsDirectory();
    final dir = Directory('${rootDir.path}/$subFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> getOfficePdfToCsvDirectory() => _getOfficeSubDir(_officePdfToCsvSubFolder);
  static Future<Directory> getOfficePdfToExcelDirectory() => _getOfficeSubDir(_officePdfToExcelSubFolder);
  static Future<Directory> getOfficePdfToWordDirectory() => _getOfficeSubDir(_officePdfToWordSubFolder);
  static Future<Directory> getOfficeWordToPdfDirectory() => _getOfficeSubDir(_officeWordToPdfSubFolder);
  static Future<Directory> getOfficeWordToHtmlDirectory() => _getOfficeSubDir(_officeWordToHtmlSubFolder);
  static Future<Directory> getOfficeWordToTextDirectory() => _getOfficeSubDir(_officeWordToTextSubFolder);
  static Future<Directory> getOfficePowerPointToPdfDirectory() => _getOfficeSubDir(_officePowerPointToPdfSubFolder);
  static Future<Directory> getOfficePowerPointToHtmlDirectory() => _getOfficeSubDir(_officePowerPointToHtmlSubFolder);
  static Future<Directory> getOfficePowerPointToTextDirectory() => _getOfficeSubDir(_officePowerPointToTextSubFolder);
  static Future<Directory> getOfficeExcelToPdfDirectory() => _getOfficeSubDir(_officeExcelToPdfSubFolder);
  static Future<Directory> getOfficeExcelToXpsDirectory() => _getOfficeSubDir(_officeExcelToXpsSubFolder);
  static Future<Directory> getOfficeExcelToHtmlDirectory() => _getOfficeSubDir(_officeExcelToHtmlSubFolder);
  static Future<Directory> getOfficeExcelToCsvDirectory() => _getOfficeSubDir(_officeExcelToCsvSubFolder);
  static Future<Directory> getOfficeExcelToOdsDirectory() => _getOfficeSubDir(_officeExcelToOdsSubFolder);
  static Future<Directory> getOfficeExcelToXmlDirectory() => _getOfficeSubDir(_officeExcelToXmlSubFolder);
  static Future<Directory> getOfficeOdsToCsvDirectory() => _getOfficeSubDir(_officeOdsToCsvSubFolder);
  static Future<Directory> getOfficeOdsToPdfDirectory() => _getOfficeSubDir(_officeOdsToPdfSubFolder);
  static Future<Directory> getOfficeOdsToExcelDirectory() => _getOfficeSubDir(_officeOdsToExcelSubFolder);
  static Future<Directory> getOfficeCsvToExcelDirectory() => _getOfficeSubDir(_officeCsvToExcelSubFolder);
  static Future<Directory> getOfficeXmlToCsvDirectory() => _getOfficeSubDir(_officeXmlToCsvSubFolder);
  static Future<Directory> getOfficeXmlToExcelDirectory() => _getOfficeSubDir(_officeXmlToExcelSubFolder);
  static Future<Directory> getOfficeJsonToExcelDirectory() => _getOfficeSubDir(_officeJsonToExcelSubFolder);
  static Future<Directory> getOfficeExcelToJsonDirectory() => _getOfficeSubDir(_officeExcelToJsonSubFolder);
  static Future<Directory> getOfficeJsonObjectsToExcelDirectory() => _getOfficeSubDir(_officeJsonObjectsToExcelSubFolder);
  static Future<Directory> getOfficeBsonToExcelDirectory() => _getOfficeSubDir(_officeBsonToExcelSubFolder);
  static Future<Directory> getOfficeSrtToExcelDirectory() => _getOfficeSubDir(_officeSrtToExcelSubFolder);
  static Future<Directory> getOfficeSrtToXlsxDirectory() => _getOfficeSubDir(_officeSrtToXlsxSubFolder);
  static Future<Directory> getOfficeSrtToXlsDirectory() => _getOfficeSubDir(_officeSrtToXlsSubFolder);
  static Future<Directory> getOfficeExcelToSrtDirectory() => _getOfficeSubDir(_officeExcelToSrtSubFolder);
  static Future<Directory> getOfficeXlsxToSrtDirectory() => _getOfficeSubDir(_officeXlsxToSrtSubFolder);
  static Future<Directory> getOfficeXlsToSrtDirectory() => _getOfficeSubDir(_officeXlsToSrtSubFolder);

  /// Get directory for HTML Table to CSV
  static Future<Directory> getHtmlTableToCsvDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_htmlTableToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for Excel to CSV
  static Future<Directory> getExcelToCsvDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_excelToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for ODS to CSV
  static Future<Directory> getOdsToCsvDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_odsToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for CSV to Excel
  static Future<Directory> getCsvToExcelDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvToExcelSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for CSV to XML
  static Future<Directory> getCsvToXmlDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvToXmlSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for PDF to CSV outputs (CSV Category)
  static Future<Directory> getPdfToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvPdfToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for HTML Table to CSV (CSV Category)
  static Future<Directory> getHtmlTableToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvHtmlTableToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for XML to CSV (CSV Category)
  static Future<Directory> getXmlToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvXmlToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for JSON to CSV (CSV Category)
  static Future<Directory> getJsonToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvJsonToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for CSV to JSON (CSV Category)
  static Future<Directory> getCsvToJsonDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvCsvToJsonSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for JSON Objects to CSV (CSV Category)
  static Future<Directory> getJsonObjectsToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvJsonObjectsToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for ODS to CSV (CSV Category)
  static Future<Directory> getOdsToCsvDirectoryFromCsvCategory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_odsToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }





  /// Get directory for JSON to CSV (JSON Category)
  static Future<Directory> getJsonToCsvDirectory() async {
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_jsonToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for CSV to JSON
  static Future<Directory> getCsvToJsonConversionDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvToJsonSubFolderLegacy');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }



  /// Get directory for BSON to CSV
  static Future<Directory> getBsonToCsvDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_bsonToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for SRT to CSV
  static Future<Directory> getSrtToCsvDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_srtToCsvSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for CSV to SRT
  static Future<Directory> getCsvToSrtDirectory() async {
    final csvDir = await getCsvConversionsDirectory();
    final dir = Directory('${csvDir.path}/$_csvToSrtSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for JSON PDF to JSON outputs (under JSONConversion)
  static Future<Directory> getJsonPdfToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonPdfToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonPngToJsonSubFolder = 'png-to-json';

  /// Get directory for JSON PNG to JSON outputs (under JSONConversion)
  static Future<Directory> getJsonPngToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonPngToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonJpgToJsonSubFolder = 'jpg-to-json';

  /// Get directory for JSON JPG to JSON outputs (under JSONConversion)
  static Future<Directory> getJsonJpgToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonJpgToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonXmlToJsonSubFolder = 'xml-to-json';

  /// Get directory for JSON XML to JSON outputs (under JSONConversion)
  static Future<Directory> getJsonXmlToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonXmlToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonJsonToXmlSubFolder = 'json-to-xml';

  /// Get directory for JSON to XML outputs (under JSONConversion)
  static Future<Directory> getJsonJsonToXmlDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonJsonToXmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonJsonToCsvSubFolder = 'json-to-csv';

  /// Get directory for JSON to CSV outputs (under JSONConversion)
  static Future<Directory> getJsonJsonToCsvDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonJsonToCsvSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonJsonToExcelSubFolder = 'json-to-excel';

  /// Get directory for JSON to Excel outputs (under JSONConversion)
  static Future<Directory> getJsonJsonToExcelDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonJsonToExcelSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _excelToJsonSubFolder = 'excel-to-json';

  /// Get directory for Excel to JSON outputs (under JSONConversion)
  static Future<Directory> getExcelToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_excelToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _csvToJsonSubFolder = 'csv-to-json';

  /// Get directory for CSV to JSON outputs (under JSONConversion)
  static Future<Directory> getCsvToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_csvToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonToYamlSubFolder = 'json-to-yaml';

  /// Get directory for JSON to YAML outputs (under JSONConversion)
  static Future<Directory> getJsonToYamlDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonToYamlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonObjectsToCsvSubFolder = 'json-objects-to-csv';

  /// Get directory for JSON Objects to CSV outputs (under JSONConversion)
  static Future<Directory> getJsonObjectsToCsvDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonObjectsToCsvSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _jsonObjectsToExcelSubFolder = 'json-objects-to-excel';

  /// Get directory for JSON Objects to Excel outputs (under JSONConversion)
  static Future<Directory> getJsonObjectsToExcelDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_jsonObjectsToExcelSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _yamlToJsonSubFolder = 'yaml-to-json';

  /// Get directory for YAML to JSON outputs (under JSONConversion)
  static Future<Directory> getYamlToJsonDirectory() async {
    final jsonConversionsDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonConversionsDir.path}/$_yamlToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }


  /// Get or create a tool-specific directory
  static Future<Directory> getToolDirectory(String toolName) async {
    final smartConverterDir = await getSmartConverterDirectory();
    final toolDir = Directory('${smartConverterDir.path}/$toolName');

    if (!await toolDir.exists()) {
      print('DEBUG: Creating tool directory: ${toolDir.path}');
      await toolDir.create(recursive: true);
    }

    try {
      final exists = await toolDir.exists();
      print('DEBUG: Tool directory $toolName accessibility - Exists: $exists');
    } catch (e) {
      print('DEBUG: Error checking tool dir $toolName accessibility: $e');
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
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_splitPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for Compress PDF tool
  static Future<Directory> getCompressPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_compressPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for PDF to Word tool
  static Future<Directory> getPdfToWordDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfToWordFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for Word to PDF tool
  static Future<Directory> getWordToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_wordToPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for Image to PDF tool
  static Future<Directory> getImageToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_imageToPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for PDF to Image tool
  static Future<Directory> getPdfToImageDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfToImageFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _powerPointToPdfFolder = 'powerpoint-to-pdf';
  static Future<Directory> getPowerPointToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_powerPointToPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _excelToPdfFolder = 'excel-to-pdf';
  static Future<Directory> getExcelToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_excelToPdfFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
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

  static Future<Directory> _getVideoSubDir(String subFolder) async {
    final root = await getVideoConversionsDirectory();
    final dir = Directory('${root.path}/$subFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _movToMp4SubFolder = 'mov-to-mp4';
  static const String _mkvToMp4SubFolder = 'mkv-to-mp4';
  static const String _aviToMp4SubFolder = 'avi-to-mp4';
  static const String _mp4ToMp3VideoSubFolder = 'mp4-to-mp3';
  static const String _convertVideoFormatSubFolder = 'convert-video-format';
  static const String _videoToAudioSubFolder = 'video-to-audio';
  static const String _extractAudioSubFolder = 'extract-audio';
  static const String _resizeVideoSubFolder = 'resize-video';
  static const String _compressVideoSubFolder = 'compress-video';
  static const String _videoInfoSubFolder = 'get-video-info';

  static Future<Directory> getMovToMp4Directory() => _getVideoSubDir(_movToMp4SubFolder);
  static Future<Directory> getMkvToMp4Directory() => _getVideoSubDir(_mkvToMp4SubFolder);
  static Future<Directory> getAviToMp4Directory() => _getVideoSubDir(_aviToMp4SubFolder);
  static Future<Directory> getMp4ToMp3VideoDirectory() => _getVideoSubDir(_mp4ToMp3VideoSubFolder);
  static Future<Directory> getConvertVideoFormatDirectory() => _getVideoSubDir(_convertVideoFormatSubFolder);
  static Future<Directory> getVideoToAudioDirectory() => _getVideoSubDir(_videoToAudioSubFolder);
  static Future<Directory> getExtractAudioDirectory() => _getVideoSubDir(_extractAudioSubFolder);
  static Future<Directory> getResizeVideoDirectory() => _getVideoSubDir(_resizeVideoSubFolder);
  static Future<Directory> getCompressVideoDirectory() => _getVideoSubDir(_compressVideoSubFolder);
  static Future<Directory> getGetVideoInfoDirectory() => _getVideoSubDir(_videoInfoSubFolder);

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

  static const String _websiteHtmlToCsvSubFolder = 'html-table-to-csv';

  /// Get directory for HTML to CSV outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteHtmlToCsvDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteHtmlToCsvSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _websiteExcelToHtmlSubFolder = 'excel-to-html';

  /// Get directory for Excel to HTML outputs (under WebsiteConversion)
  static Future<Directory> getWebsiteExcelToHtmlDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websiteExcelToHtmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static const String _websitePdfToHtmlSubFolder = 'pdf-to-html';

  /// Get directory for PDF to HTML outputs (under WebsiteConversion)
  static Future<Directory> getWebsitePdfToHtmlDirectory() async {
    final websiteConversionsDir = await getWebsiteConversionsDirectory();
    final dir = Directory('${websiteConversionsDir.path}/$_websitePdfToHtmlSubFolder');
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

  static const String _ocrConversionsFolder = 'OCRConversion';

  static const String _ocrPngToTextSubFolder = 'png-to-text';
  static const String _ocrJpgToTextSubFolder = 'jpg-to-text';
  static const String _ocrImageToTextSubFolder = 'image-to-text';
  static const String _ocrPdfToTextSubFolder = 'pdf-to-text';
  static const String _ocrPdfImageToPdfTextSubFolder = 'pdf-image-to-pdf-text';
  static const String _ocrPngToPdfSubFolder = 'png-to-pdf';
  static const String _ocrJpgToPdfSubFolder = 'jpg-to-pdf';
  static const String _ocrScannedPdfToTextSubFolder = 'scanned-pdf-to-text';

  /// Get or create the OCR Conversions directory
  static Future<Directory> getOcrConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final ocrConversionsDir = Directory(
      '${smartConverterDir.path}/$_ocrConversionsFolder',
    );
    if (!await ocrConversionsDir.exists()) {
      await ocrConversionsDir.create(recursive: true);
    }
    return ocrConversionsDir;
  }

  /// Get directory for OCR PNG to Text
  static Future<Directory> getOcrPngToTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrPngToTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR JPG to Text
  static Future<Directory> getOcrJpgToTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrJpgToTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _ocrTextExtractionSubFolder = 'ocr-text-extraction';

  /// Get directory for OCR Text Extraction (Generic)
  static Future<Directory> getOcrTextExtractionDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrTextExtractionSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR Image to Text (General)
  static Future<Directory> getOcrImageToTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrImageToTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR PDF to Text
  static Future<Directory> getOcrPdfToTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrPdfToTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR PDF Image to PDF Text
  static Future<Directory> getOcrPdfImageToPdfTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrPdfImageToPdfTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR PNG to PDF
  static Future<Directory> getOcrPngToPdfDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrPngToPdfSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OCR JPG to PDF
  static Future<Directory> getOcrJpgToPdfDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrJpgToPdfSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

   /// Get directory for Scanned PDF to Text
  static Future<Directory> getOcrScannedPdfToTextDirectory() async {
    final ocrDir = await getOcrConversionsDirectory();
    final dir = Directory('${ocrDir.path}/$_ocrScannedPdfToTextSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // Deprecated usage mapping to new OCR structure
  static Future<Directory> getImageToTextDirectory() => getOcrImageToTextDirectory();
  static Future<Directory> getPdfToPdfDirectory() => getOcrPdfImageToPdfTextDirectory(); // Mapping to most likely candidate


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

  /// Get directory for Excel to XPS (PDF Category)
  static Future<Directory> getPdfExcelToXpsDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfExcelToXpsSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for ODS to PDF (PDF Category)
  static Future<Directory> getPdfOdsToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfOdsToPdfSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for OXPS to PDF (PDF Category)
  static Future<Directory> getOxpsToPdfDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfOxpsToPdfSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
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

  /// Get directory for PDF to JSON outputs (consolidated to JSONConversion)
  static Future<Directory> getPdfToJsonDirectory() async {
    final pdfConversionsDir = await getPdfConversionsDirectory();
    final dir = Directory('${pdfConversionsDir.path}/$_pdfToJsonSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
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

  /// Get directory for PDF to Word outputs


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
    return getToolDirectory(_imageConversionsFolder);
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



  static const String _jsonFormattedSubFolder = 'json-formatted';

  static Future<Directory> getJsonFormattedDirectory() async {
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_jsonFormattedSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _aiJpgToJsonSubFolder = 'jpg-to-json';

  static const String _jsonToExcelSubFolder = 'json-to-excel';

  static Future<Directory> getJsonToExcelDirectory() async {
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_jsonToExcelSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
  static const String _aiPngToJsonSubFolder = 'png-to-json';

  static const String _xmlConversionsFolder = 'XMLConversion';

  static const String _excelToXmlSubFolder = 'excel-to-xml';
  static const String _xmlToJsonSubFolder = 'xml-to-json';
  static const String _xmlToCsvSubFolder = 'xml-to-csv';
  static const String _xmlToExcelSubFolder = 'xml-to-excel';
  static const String _fixXmlEscapingSubFolder = 'fix-xml-escaping';

  static const String _xmlXsdValidatorSubFolder = 'xml-validation';
  static const String _jsonToXmlSubFolder = 'json-to-xml';

  /// Get or create the XML conversions directory
  static Future<Directory> getXmlConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final xmlConversionsDir = Directory(
      '${smartConverterDir.path}/$_xmlConversionsFolder',
    );
    if (!await xmlConversionsDir.exists()) {
      await xmlConversionsDir.create(recursive: true);
    }
    return xmlConversionsDir;
  }

  /// Get directory for Excel to XML outputs
  static Future<Directory> getExcelToXmlDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_excelToXmlSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for XML to JSON outputs
  static Future<Directory> getXmlToJsonDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_xmlToJsonSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for XML to CSV outputs
  static Future<Directory> getXmlToCsvDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_xmlToCsvSubFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get directory for XML to Excel outputs
  static Future<Directory> getXmlToExcelDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_xmlToExcelSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for Fix XML Escaping outputs
  static Future<Directory> getFixXmlEscapingDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_fixXmlEscapingSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for XML Validation outputs
  static Future<Directory> getXmlXsdValidatorDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_xmlXsdValidatorSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get directory for JSON to XML outputs (JSON Category now)
  static Future<Directory> getJsonToXmlDirectory() async {
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_jsonToXmlSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
  
  static const String _csvToXml = 'csv-to-xml';

  /// Get directory for CSV to XML outputs (XML Category)
  static Future<Directory> getCsvToXmlFromXmlCategoryDirectory() async {
    final xmlDir = await getXmlConversionsDirectory();
    final dir = Directory('${xmlDir.path}/$_csvToXml');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }


  static Future<Directory> getAiConvertJpgToJsonDirectory() async { // Fix analyzer
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_aiJpgToJsonSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> getAiConvertPngToJsonDirectory() async {
    final jsonDir = await getJsonConversionsDirectory();
    final dir = Directory('${jsonDir.path}/$_aiPngToJsonSubFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static const String _ebookConversionsFolder = 'EBookConversion';

  static const String _azw3ToPdfSubFolder = 'azw3-to-pdf';
  static const String _azwToEpubSubFolder = 'azw-to-epub';
  static const String _azwToMobiSubFolder = 'azw-to-mobi';
  static const String _azwToPdfSubFolder = 'azw-to-pdf';
  static const String _epubToAzwSubFolder = 'epub-to-azw';
  static const String _epubToMobiSubFolder = 'epub-to-mobi';
  static const String _epubToPdfSubFolder = 'epub-to-pdf';
  static const String _fb2ToPdfSubFolder = 'fb2-to-pdf';
  static const String _fbzToPdfSubFolder = 'fbz-to-pdf';
  static const String _markdownToEpubSubFolder = 'markdown-to-epub';
  static const String _mobiToAzwSubFolder = 'mobi-to-azw';
  static const String _mobiToEpubSubFolder = 'mobi-to-epub';
  static const String _mobiToPdfSubFolder = 'mobi-to-pdf';
  static const String _pdfToAzw3SubFolder = 'pdf-to-azw3';
  static const String _pdfToAzwSubFolder = 'pdf-to-azw';
  static const String _pdfToEpubSubFolder = 'pdf-to-epub';
  static const String _pdfToFb2SubFolder = 'pdf-to-fb2';
  static const String _pdfToFbzSubFolder = 'pdf-to-fbz';
  static const String _pdfToMobiSubFolder = 'pdf-to-mobi';

  /// Get or create the EBook conversions directory
  static Future<Directory> getEbookConversionsDirectory() async {
    final smartConverterDir = await getSmartConverterDirectory();
    final ebookConversionsDir = Directory(
      '${smartConverterDir.path}/$_ebookConversionsFolder',
    );
    if (!await ebookConversionsDir.exists()) {
      await ebookConversionsDir.create(recursive: true);
    }
    return ebookConversionsDir;
  }

  static Future<Directory> _getEbookSubDir(String subFolder) async {
    final root = await getEbookConversionsDirectory();
    final dir = Directory('${root.path}/$subFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> getAzw3ToPdfDirectory() => _getEbookSubDir(_azw3ToPdfSubFolder);
  static Future<Directory> getAzwToEpubDirectory() => _getEbookSubDir(_azwToEpubSubFolder);
  static Future<Directory> getAzwToMobiDirectory() => _getEbookSubDir(_azwToMobiSubFolder);
  static Future<Directory> getAzwToPdfDirectory() => _getEbookSubDir(_azwToPdfSubFolder);
  static Future<Directory> getEpubToAzwDirectory() => _getEbookSubDir(_epubToAzwSubFolder);
  static Future<Directory> getEpubToMobiDirectory() => _getEbookSubDir(_epubToMobiSubFolder);
  static Future<Directory> getEpubToPdfDirectory() => _getEbookSubDir(_epubToPdfSubFolder);
  static Future<Directory> getFb2ToPdfDirectory() => _getEbookSubDir(_fb2ToPdfSubFolder);
  static Future<Directory> getFbzToPdfDirectory() => _getEbookSubDir(_fbzToPdfSubFolder);
  static Future<Directory> getMarkdownToEpubDirectory() => _getEbookSubDir(_markdownToEpubSubFolder);
  static Future<Directory> getMobiToAzwDirectory() => _getEbookSubDir(_mobiToAzwSubFolder);
  static Future<Directory> getMobiToEpubDirectory() => _getEbookSubDir(_mobiToEpubSubFolder);
  static Future<Directory> getMobiToPdfDirectory() => _getEbookSubDir(_mobiToPdfSubFolder);
  static Future<Directory> getPdfToAzw3Directory() => _getEbookSubDir(_pdfToAzw3SubFolder);
  static Future<Directory> getPdfToAzwDirectory() => _getEbookSubDir(_pdfToAzwSubFolder);
  static Future<Directory> getPdfToEpubDirectory() => _getEbookSubDir(_pdfToEpubSubFolder);
  static Future<Directory> getPdfToFb2Directory() => _getEbookSubDir(_pdfToFb2SubFolder);
  static Future<Directory> getPdfToFbzDirectory() => _getEbookSubDir(_pdfToFbzSubFolder);
  static Future<Directory> getPdfToMobiDirectory() => _getEbookSubDir(_pdfToMobiSubFolder);
}
