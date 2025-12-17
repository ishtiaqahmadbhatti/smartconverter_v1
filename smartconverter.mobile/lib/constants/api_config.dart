import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// API Configuration for Smart Converter
///
/// This file contains all API-related configuration including
/// base URLs, endpoints, and timeout settings.
class ApiConfig {
  // FastAPI Backend Configuration
  // Network IP for physical devices (change if your server IP is different)
  static const String networkIp = '192.168.8.101';
  static const int networkPort = 8000;

  // For Android Emulator: Use 10.0.2.2 to access host machine's localhost
  // For Physical Device: Use the network IP address
  static Future<String> get baseUrl async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Check if running on emulator
        // Emulators typically have specific model/manufacturer/brand strings
        final model = androidInfo.model.toLowerCase();
        final manufacturer = androidInfo.manufacturer.toLowerCase();
        final brand = androidInfo.brand.toLowerCase();
        final device = androidInfo.device.toLowerCase();

        final isEmulator =
            model.contains('sdk') ||
            model.contains('emulator') ||
            model.contains('google_sdk') ||
            manufacturer.contains('genymotion') ||
            brand.contains('generic') ||
            device.contains('generic') ||
            manufacturer.contains('unknown') ||
            androidInfo.fingerprint.contains('generic') ||
            androidInfo.hardware.contains('goldfish') ||
            androidInfo.hardware.contains('ranchu');

        if (isEmulator) {
          // Android Emulator uses 10.0.2.2 to access host machine's localhost
          return 'http://10.0.2.2:$networkPort';
        } else {
          // Physical Android device - use network IP
          return 'http://$networkIp:$networkPort';
        }
      } catch (e) {
        // If detection fails, default to network IP for physical devices
        print('Warning: Could not detect device type, using network IP: $e');
        return 'http://$networkIp:$networkPort';
      }
    } else {
      // iOS Simulator or Physical Device - use network IP
      return 'http://$networkIp:$networkPort';
    }
  }

  // API Endpoints
  static const String healthEndpoint = '/api/v1/health';
  static const String pdfToWordEndpoint = '/convert/pdf-to-word';
  static const String wordToPdfEndpoint = '/convert/word-to-pdf';
  static const String imagesToPdfEndpoint = '/convert/images-to-pdf';
  static const String pdfToImagesEndpoint = '/convert/pdf-to-images';
  static const String compressPdfEndpoint =
      '/api/v1/pdfconversiontools/compress';
  static const String rotatePdfEndpoint = '/api/v1/pdfconversiontools/rotate';
  static const String addPageNumbersEndpoint =
      '/api/v1/pdfconversiontools/add-page-numbers';
  static const String mergePdfEndpoint = '/api/v1/pdfconversiontools/merge';
  static const String markdownToPdfEndpoint =
      '/api/v1/pdfconversiontools/markdown-to-pdf';
  static const String jpgToPdfEndpoint =
      '/api/v1/pdfconversiontools/jpg-to-pdf';
  static const String pngToPdfEndpoint =
      '/api/v1/pdfconversiontools/png-to-pdf';
  // PDF to HTML conversion endpoint
  static const String pdfToHtmlEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-html';
  static const String websiteToPdfEndpoint =
      '/api/v1/websiteconversiontools/website-to-pdf';
  static const String htmlToPdfEndpoint =
      '/api/v1/websiteconversiontools/html-to-pdf';
  static const String websiteWordToHtmlEndpoint =
      '/api/v1/websiteconversiontools/word-to-html';
  static const String websitePowerPointToHtmlEndpoint =
      '/api/v1/websiteconversiontools/powerpoint-to-html';
  static const String websiteMarkdownToHtmlEndpoint =
      '/api/v1/websiteconversiontools/markdown-to-html';
  static const String websiteToJpgEndpoint =
      '/api/v1/websiteconversiontools/website-to-jpg';
  static const String htmlToJpgEndpoint =
      '/api/v1/websiteconversiontools/html-to-jpg';
  static const String websiteToPngEndpoint =
      '/api/v1/websiteconversiontools/website-to-png';
  static const String htmlToPngEndpoint =
      '/api/v1/websiteconversiontools/html-to-png';
  static const String pdfToMarkdownEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-markdown';
  static const String pdfToJsonEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-json';
  static const String pdfToCsvEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-csv';
  static const String pdfToExcelEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-excel';
  // PDF to Text conversion endpoint
  static const String pdfToTextEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-text';
  // Text Conversion endpoints
  static const String textWordToTextEndpoint =
      '/api/v1/textconversiontools/word-to-text';
  static const String textPowerpointToTextEndpoint =
      '/api/v1/textconversiontools/powerpoint-to-text';
  static const String textSrtToTextEndpoint =
      '/api/v1/textconversiontools/srt-to-text';
  static const String textVttToTextEndpoint =
      '/api/v1/textconversiontools/vtt-to-text';
  // Subtitle Conversion endpoints
  static const String subtitlesSrtToCsvEndpoint =
      '/api/v1/subtitlesconversiontools/srt-to-csv';
  static const String subtitlesSrtToExcelEndpoint =
      '/api/v1/subtitlesconversiontools/srt-to-excel';
  static const String subtitlesSrtToVttEndpoint =
      '/api/v1/subtitlesconversiontools/srt-to-vtt';
  static const String subtitlesVttToSrtEndpoint =
      '/api/v1/subtitlesconversiontools/vtt-to-srt';
  static const String subtitlesCsvToSrtEndpoint =
      '/api/v1/subtitlesconversiontools/csv-to-srt';
  static const String subtitlesExcelToSrtEndpoint =
      '/api/v1/subtitlesconversiontools/excel-to-srt';
  static const String translateSrtEndpoint =
      '/api/v1/subtitlesconversiontools/translate-srt';
  static const String supportedLanguagesEndpoint =
      '/api/v1/subtitlesconversiontools/supported-languages';
  // PDF to image conversion endpoints
  static const String pdfToJpgEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-jpg';
  static const String pdfToPngEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-png';
  static const String pdfToTiffEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-tiff';
  static const String pdfToSvgEndpoint =
      '/api/v1/pdfconversiontools/pdf-to-svg';
  static const String protectPdfEndpoint = '/api/v1/pdfconversiontools/protect';
  static const String unlockPdfEndpoint = '/api/v1/pdfconversiontools/unlock';
  static const String cropPdfEndpoint = '/api/v1/pdfconversiontools/crop';
  static const String repairPdfEndpoint = '/api/v1/pdfconversiontools/repair';
  static const String comparePdfsEndpoint =
      '/api/v1/pdfconversiontools/compare';
  static const String pdfMetadataEndpoint =
      '/api/v1/pdfconversiontools/metadata';
  static const String watermarkPdfEndpoint =
      '/api/v1/pdfconversiontools/add-watermark';
  static const String removePagesEndpoint =
      '/api/v1/pdfconversiontools/remove-pages';
  static const String extractPagesEndpoint =
      '/api/v1/pdfconversiontools/extract-pages';
  static const String splitPdfEndpoint = '/api/v1/pdfconversiontools/split';
  static const String splitPdfNewEndpoint = '/api/v1/pdfconversiontools/split';
  static const String downloadEndpoint = '/api/v1/convert/download';
  static const String videoToAudioEndpoint =
      '/api/v1/videoconversiontools/mp4-to-mp3';
  static const String mp4ToMp3AudioEndpoint =
      '/api/v1/audioconversiontools/mp4-to-mp3';

  // Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // File Upload Configuration
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
  ];
  static const List<String> allowedPdfFormats = ['pdf'];
  static const List<String> allowedWordFormats = ['doc', 'docx'];
  static const List<String> allowedExcelFormats = ['xls', 'xlsx'];
  static const List<String> allowedPowerPointFormats = ['ppt', 'pptx'];
  static const String htmlTableToCsvEndpoint = '/api/v1/websiteconversiontools/html-table-to-csv';
  static const String excelToHtmlEndpoint = '/api/v1/websiteconversiontools/excel-to-html';
  static const List<String> allowedHtmlFormats = ['html', 'htm'];
  static const String pngToJsonEndpoint = '/api/v1/jsonconversiontools/ai/png-to-json';
  static const String jpgToJsonEndpoint = '/api/v1/jsonconversiontools/ai/jpg-to-json';
  static const String xmlToJsonEndpoint = '/api/v1/jsonconversiontools/xml-to-json';
  static const String jsonToXmlEndpoint = '/api/v1/jsonconversiontools/json-to-xml';
  static const String jsonToCsvEndpoint = '/api/v1/jsonconversiontools/json-to-csv';
  static const String jsonToExcelEndpoint = '/api/v1/jsonconversiontools/json-to-excel';
  static const String excelToJsonEndpoint = '/api/v1/jsonconversiontools/excel-to-json';
  static const String csvToJsonEndpoint = '/api/v1/jsonconversiontools/csv-to-json';
  static const String jsonToYamlEndpoint = '/api/v1/jsonconversiontools/json-to-yaml';
  static const String yamlToJsonEndpoint = '/api/v1/jsonconversiontools/yaml-to-json';
  static const String jsonObjectsToCsvEndpoint = '/api/v1/jsonconversiontools/json-objects-to-csv';
  static const String jsonObjectsToExcelEndpoint = '/api/v1/jsonconversiontools/json-objects-to-excel';
  static const String jsonFormatterEndpoint = '/api/v1/jsonconversiontools/json-formatter';
  static const String jsonValidatorEndpoint = '/api/v1/jsonconversiontools/json-validator';
  
  // XML Conversion Endpoints
  static const String csvToXmlEndpoint = '/api/v1/xmlconversiontools/csv-to-xml';
  static const String excelToXmlEndpoint = '/api/v1/xmlconversiontools/excel-to-xml';
  static const String xmlToJsonXmlToolsEndpoint = '/api/v1/xmlconversiontools/xml-to-json';
  static const String xmlToCsvEndpoint = '/api/v1/xmlconversiontools/xml-to-csv';
  static const String xmlToExcelEndpoint = '/api/v1/xmlconversiontools/xml-to-excel';
  static const String fixXmlEscapingEndpoint = '/api/v1/xmlconversiontools/fix-xml-escaping';

  static const String xmlXsdValidatorEndpoint = '/api/v1/xmlconversiontools/xml-xsd-validator';
  static const String jsonToXmlXmlToolsEndpoint = '/api/v1/xmlconversiontools/json-to-xml';

  // CSV Conversion Endpoints
  static const String csvHtmlTableToCsvEndpoint = '/api/v1/csvconversiontools/html-table-to-csv';
  static const String csvExcelToCsvEndpoint = '/api/v1/csvconversiontools/excel-to-csv';
  static const String csvOdsToCsvEndpoint = '/api/v1/csvconversiontools/ods-to-csv';
  static const String csvCsvToExcelEndpoint = '/api/v1/csvconversiontools/csv-to-excel';
  static const String csvCsvToXmlEndpoint = '/api/v1/csvconversiontools/csv-to-xml';
  static const String csvXmlToCsvEndpoint = '/api/v1/csvconversiontools/xml-to-csv';
  static const String csvPdfToCsvEndpoint = '/api/v1/csvconversiontools/pdf-to-csv';
  static const String csvJsonToCsvEndpoint = '/api/v1/csvconversiontools/json-to-csv';
  static const String csvCsvToJsonEndpoint = '/api/v1/csvconversiontools/csv-to-json';
  static const String csvJsonObjectsToCsvEndpoint = '/api/v1/csvconversiontools/json-objects-to-csv';
  static const String csvBsonToCsvEndpoint = '/api/v1/csvconversiontools/bson-to-csv';
  static const String csvSrtToCsvEndpoint = '/api/v1/csvconversiontools/srt-to-csv';
  static const String csvCsvToSrtEndpoint = '/api/v1/csvconversiontools/csv-to-srt';

  // Response Configuration
  static const String downloadUrlKey = 'download_url';
  static const String statusKey = 'status';
  static const String messageKey = 'message';
  static const String errorKey = 'error';

  // Conversion Status Values
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusPending = 'pending';

  // Office Document Conversion Endpoints
  static const String officePdfToCsvEndpoint = '/api/v1/officedocumentsconversiontools/pdf-to-csv';
  static const String officePdfToExcelEndpoint = '/api/v1/officedocumentsconversiontools/pdf-to-excel';
  static const String officePdfToWordEndpoint = '/api/v1/officedocumentsconversiontools/pdf-to-word';
  static const String officeWordToPdfEndpoint = '/api/v1/officedocumentsconversiontools/word-to-pdf';
  static const String officeWordToHtmlEndpoint = '/api/v1/officedocumentsconversiontools/word-to-html';
  static const String officeWordToTextEndpoint = '/api/v1/officedocumentsconversiontools/word-to-text';
  static const String officePowerPointToPdfEndpoint = '/api/v1/officedocumentsconversiontools/powerpoint-to-pdf';
  static const String officePowerPointToHtmlEndpoint = '/api/v1/officedocumentsconversiontools/powerpoint-to-html';
  static const String officePowerPointToTextEndpoint = '/api/v1/officedocumentsconversiontools/powerpoint-to-text';
  static const String officeExcelToPdfEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-pdf';
  static const String officeExcelToXpsEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-xps';
  static const String officeExcelToHtmlEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-html';
  static const String officeExcelToCsvEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-csv';
  static const String officeExcelToOdsEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-ods';
  static const String officeExcelToXmlEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-xml';
  static const String officeOdsToCsvEndpoint = '/api/v1/officedocumentsconversiontools/ods-to-csv';
  static const String officeOdsToPdfEndpoint = '/api/v1/officedocumentsconversiontools/ods-to-pdf';
  static const String officeOdsToExcelEndpoint = '/api/v1/officedocumentsconversiontools/ods-to-excel';
  static const String officeCsvToExcelEndpoint = '/api/v1/officedocumentsconversiontools/csv-to-excel';
  static const String officeXmlToCsvEndpoint = '/api/v1/officedocumentsconversiontools/xml-to-csv';
  static const String officeXmlToExcelEndpoint = '/api/v1/officedocumentsconversiontools/xml-to-excel';
  static const String officeJsonToExcelEndpoint = '/api/v1/officedocumentsconversiontools/json-to-excel';
  static const String officeExcelToJsonEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-json';
  static const String officeJsonObjectsToExcelEndpoint = '/api/v1/officedocumentsconversiontools/json-objects-to-excel';
  static const String officeBsonToExcelEndpoint = '/api/v1/officedocumentsconversiontools/bson-to-excel';
  static const String officeSrtToExcelEndpoint = '/api/v1/officedocumentsconversiontools/srt-to-excel';
  static const String officeSrtToXlsxEndpoint = '/api/v1/officedocumentsconversiontools/srt-to-xlsx';
  static const String officeSrtToXlsEndpoint = '/api/v1/officedocumentsconversiontools/srt-to-xls';
  static const String officeExcelToSrtEndpoint = '/api/v1/officedocumentsconversiontools/excel-to-srt';
  static const String officeXlsxToSrtEndpoint = '/api/v1/officedocumentsconversiontools/xlsx-to-srt';
  static const String officeXlsToSrtEndpoint = '/api/v1/officedocumentsconversiontools/xls-to-srt';

  // Image Conversion Endpoints
  static const String aiPngToJsonEndpoint = '/api/v1/imageconversiontools/ai-png-to-json';
  static const String aiJpgToJsonEndpoint = '/api/v1/imageconversiontools/ai-jpg-to-json';
  static const String imageJpgToPdfEndpoint = '/api/v1/imageconversiontools/jpg-to-pdf';
  static const String imagePngToPdfEndpoint = '/api/v1/imageconversiontools/png-to-pdf';
  static const String imageWebsiteToJpgEndpoint = '/api/v1/imageconversiontools/website-to-jpg';
  static const String imageHtmlToJpgEndpoint = '/api/v1/imageconversiontools/html-to-jpg';
  static const String imageWebsiteToPngEndpoint = '/api/v1/imageconversiontools/website-to-png';
  static const String imageHtmlToPngEndpoint = '/api/v1/imageconversiontools/html-to-png';
  static const String imagePdfToJpgEndpoint = '/api/v1/imageconversiontools/pdf-to-jpg';
  static const String imagePdfToPngEndpoint = '/api/v1/imageconversiontools/pdf-to-png';
  static const String imagePdfToTiffEndpoint = '/api/v1/imageconversiontools/pdf-to-tiff';
  static const String imagePdfToSvgEndpoint = '/api/v1/imageconversiontools/pdf-to-svg';
  static const String imageAiToSvgEndpoint = '/api/v1/imageconversiontools/ai-to-svg';
  static const String imagePngToSvgEndpoint = '/api/v1/imageconversiontools/png-to-svg';
  static const String imagePngToAvifEndpoint = '/api/v1/imageconversiontools/png-to-avif';
  static const String imageJpgToAvifEndpoint = '/api/v1/imageconversiontools/jpg-to-avif';
  static const String imageWebpToAvifEndpoint = '/api/v1/imageconversiontools/webp-to-avif';
  static const String imageAvifToPngEndpoint = '/api/v1/imageconversiontools/avif-to-png';
  static const String imageAvifToJpegEndpoint = '/api/v1/imageconversiontools/avif-to-jpeg';
  static const String imageAvifToWebpEndpoint = '/api/v1/imageconversiontools/avif-to-webp';
  static const String imagePngToWebpEndpoint = '/api/v1/imageconversiontools/png-to-webp';
  static const String imageJpgToWebpEndpoint = '/api/v1/imageconversiontools/jpg-to-webp';
  static const String imageTiffToWebpEndpoint = '/api/v1/imageconversiontools/tiff-to-webp';
  static const String imageGifToWebpEndpoint = '/api/v1/imageconversiontools/gif-to-webp';
  static const String imageWebpToPngEndpoint = '/api/v1/imageconversiontools/webp-to-png';
  static const String imageWebpToJpegEndpoint = '/api/v1/imageconversiontools/webp-to-jpeg';
  static const String imageWebpToTiffEndpoint = '/api/v1/imageconversiontools/webp-to-tiff';
  static const String imageWebpToBmpEndpoint = '/api/v1/imageconversiontools/webp-to-bmp';
  static const String imageWebpToYuvEndpoint = '/api/v1/imageconversiontools/webp-to-yuv';
  static const String imageWebpToPamEndpoint = '/api/v1/imageconversiontools/webp-to-pam';
  static const String imageWebpToPgmEndpoint = '/api/v1/imageconversiontools/webp-to-pgm';
  static const String imageWebpToPpmEndpoint = '/api/v1/imageconversiontools/webp-to-ppm';
  static const String imagePngToJpgEndpoint = '/api/v1/imageconversiontools/png-to-jpg';
  static const String imagePngToPgmEndpoint = '/api/v1/imageconversiontools/png-to-pgm';
  static const String imagePngToPpmEndpoint = '/api/v1/imageconversiontools/png-to-ppm';
  static const String imageJpgToPngEndpoint = '/api/v1/imageconversiontools/jpg-to-png';
  static const String imageJpegToPgmEndpoint = '/api/v1/imageconversiontools/jpeg-to-pgm';
  static const String imageJpegToPpmEndpoint = '/api/v1/imageconversiontools/jpeg-to-ppm';
  static const String imageHeicToPngEndpoint = '/api/v1/imageconversiontools/heic-to-png';
  static const String imageHeicToJpgEndpoint = '/api/v1/imageconversiontools/heic-to-jpg';
  static const String imageSvgToPngEndpoint = '/api/v1/imageconversiontools/svg-to-png';
  static const String imageSvgToJpgEndpoint = '/api/v1/imageconversiontools/svg-to-jpg';
  static const String imageRemoveExifEndpoint = '/api/v1/imageconversiontools/remove-exif';
}
