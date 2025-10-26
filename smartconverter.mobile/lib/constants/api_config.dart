/// API Configuration for Smart Converter
///
/// This file contains all API-related configuration including
/// base URLs, endpoints, and timeout settings.
class ApiConfig {
  // FastAPI Backend Configuration
  static const String baseUrl = 'http://10.69.37.35:8000';

  // API Endpoints
  static const String healthEndpoint = '/api/v1/health/health';
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
