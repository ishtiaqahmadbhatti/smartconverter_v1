import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// API Configuration for Smart Converter
///
/// This file contains all API-related configuration including
/// base URLs, endpoints, and timeout settings.
class ApiConfig {
  // FastAPI Backend Configuration
  // Network IP for physical devices (change if your server IP is different)
  static const String networkIp = '192.168.8.100';
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
  static const String compressPdfEndpoint = '/convert/compress-pdf';
  static const String rotatePdfEndpoint = '/api/v1/pdf/rotate';
  static const String addPageNumbersEndpoint = '/api/v1/pdf/add-page-numbers';
  static const String mergePdfEndpoint = '/api/v1/pdf/merge';
  static const String protectPdfEndpoint = '/api/v1/pdf/protect';
  static const String unlockPdfEndpoint = '/api/v1/pdf/unlock';
  static const String watermarkPdfEndpoint = '/api/v1/pdf/add-watermark';
  static const String removePagesEndpoint = '/api/v1/pdf/remove-pages';
  static const String extractPagesEndpoint = '/api/v1/pdf/extract-pages';
  static const String splitPdfEndpoint = '/api/v1/pdf/split';
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
  static const List<String> allowedHtmlFormats = ['html', 'htm'];

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
}
