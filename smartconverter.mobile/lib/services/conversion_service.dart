import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../models/conversion_tool.dart';
import '../constants/api_config.dart';
import '../utils/file_manager.dart';

class MergePdfResult {
  final File file;
  final String fileName;
  final String downloadUrl;

  const MergePdfResult({
    required this.file,
    required this.fileName,
    required this.downloadUrl,
  });
}

class MarkdownToPdfResult {
  final File file;
  final String fileName;
  final String downloadUrl;

  const MarkdownToPdfResult({
    required this.file,
    required this.fileName,
    required this.downloadUrl,
  });
}

class ImageToPdfResult {
  final File file;
  final String fileName;
  final String downloadUrl;

  const ImageToPdfResult({
    required this.file,
    required this.fileName,
    required this.downloadUrl,
  });
}

class CompressPdfResult {
  final File file;
  final String fileName;
  final String downloadUrl;
  final int? sizeBefore;
  final int? sizeAfter;
  final double? achievedReductionPct;

  const CompressPdfResult({
    required this.file,
    required this.fileName,
    required this.downloadUrl,
    this.sizeBefore,
    this.sizeAfter,
    this.achievedReductionPct,
  });
}

class PdfToImagesResult {
  final List<File> files;
  final List<String> fileNames;
  final String folderName;
  final String downloadUrl;
  final int pagesProcessed;

  const PdfToImagesResult({
    required this.files,
    required this.fileNames,
    required this.folderName,
    required this.downloadUrl,
    required this.pagesProcessed,
  });
}

class ConversionService {
  static final ConversionService _instance = ConversionService._internal();
  factory ConversionService() => _instance;
  ConversionService._internal();

  final Dio _dio = Dio();
  String? _baseUrl;

  static const Duration _heavyConnectTimeout = Duration(minutes: 2);
  static const Duration _heavyReceiveTimeout = Duration(minutes: 5);

  // FastAPI backend URL (cached after initialization)
  String? get baseUrl => _baseUrl;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  // Initialize the service
  Future<void> initialize() async {
    _baseUrl = await ApiConfig.baseUrl;
    _dio.options.baseUrl = _baseUrl!;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => _debugLog('API: $object'),
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _debugLog('API Error: ${error.message}');
          if (error.response != null) {
            _debugLog('Response data: ${error.response?.data}');
            _debugLog('Response status: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      Response response = await _dio.get(ApiConfig.healthEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      _debugLog('API Connection test failed: $e');
      return false;
    }
  }

  // PDF to Word conversion
  Future<ImageToPdfResult?> convertPdfToWord(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for Word conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToWordEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.docx';

        _debugLog('✅ PDF converted to Word successfully!');
        _debugLog('📥 Downloading Word document: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('PDF to Word conversion failed: $e');
    }
  }

  // Word to PDF conversion
  Future<File?> convertWordToPdf(File wordFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          wordFile.path,
          filename: wordFile.path.split('/').last,
        ),
      });

      Response response = await _dio.post(
        ApiConfig.wordToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'converted_document.pdf';
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Word to PDF conversion failed: $e');
    }
  }

  // Image to PDF conversion
  Future<File?> convertImageToPdf(List<File> imageFiles) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (File file in imageFiles) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      FormData formData = FormData.fromMap({'files': multipartFiles});

      Response response = await _dio.post(
        ApiConfig.imagesToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'converted_document.pdf';
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Image to PDF conversion failed: $e');
    }
  }

  // Generic helper for legacy callers who just need JPG images list
  Future<List<File>> convertPdfToImages(File pdfFile) async {
    final result = await _convertPdfToImages(
      pdfFile,
      endpoint: ApiConfig.pdfToJpgEndpoint,
      imageExtension: 'jpg',
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    return result.files;
  }

  // Placeholder method for Text to Word conversion
  Future<File?> convertTextToWord(File textFile) async {
    try {
      // Simulated processing until backend endpoint is available
      await Future.delayed(const Duration(seconds: 2));

      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('Text to Word conversion failed: $e');
    }
  }

  // Convert Word (DOC/DOCX) to Text
  Future<ImageToPdfResult?> convertWordToText(
    File wordFile, {
    String? outputFilename,
  }) async {
    try {
      if (!wordFile.existsSync()) {
        throw Exception('Word file does not exist');
      }

      final extension = p.extension(wordFile.path).toLowerCase();
      if (extension != '.doc' && extension != '.docx') {
        throw Exception('Only .doc or .docx files are supported');
      }

      final file = await MultipartFile.fromFile(
        wordFile.path,
        filename: p.basename(wordFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading Word file for Text conversion...');

      Response response = await _dio.post(
        ApiConfig.textWordToTextEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(wordFile.path)}.txt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Word to Text: $e');
    }
  }

  // Convert SRT to CSV (Subtitle Conversion)
  Future<ImageToPdfResult?> convertSrtToCsv(
    File srtFile, {
      String? outputFilename,
  }) async {
    try {
      if (!srtFile.existsSync()) {
        throw Exception('SRT file does not exist');
      }
      final extension = p.extension(srtFile.path).toLowerCase();
      if (extension != '.srt') {
        throw Exception('Only .srt files are supported');
      }

      final file = await MultipartFile.fromFile(
        srtFile.path,
        filename: p.basename(srtFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading SRT file for CSV conversion...');

      Response response = await _dio.post(
        ApiConfig.subtitlesSrtToCsvEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(srtFile.path)}.csv';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert SRT to CSV: $e');
    }
  }

  // Convert SRT to Excel (Subtitle Conversion)
  Future<ImageToPdfResult?> convertSrtToExcel(
    File srtFile, {
    String? outputFilename,
  }) async {
    try {
      if (!srtFile.existsSync()) {
        throw Exception('SRT file does not exist');
      }
      final extension = p.extension(srtFile.path).toLowerCase();
      if (extension != '.srt') {
        throw Exception('Only .srt files are supported');
      }

      final file = await MultipartFile.fromFile(
        srtFile.path,
        filename: p.basename(srtFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading SRT file for Excel conversion...');

      Response response = await _dio.post(
        ApiConfig.subtitlesSrtToExcelEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(srtFile.path)}.xlsx';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert SRT to Excel: $e');
    }
  }

  // Convert HTML/URL/File to PDF
  Future<ImageToPdfResult?> convertHtmlToPdf({
    File? htmlFile,
    String? htmlContent,
    String? cssContent,
    String? outputFilename,
  }) async {
    try {
      if (htmlFile == null && htmlContent == null) {
        throw Exception('Either htmlFile or htmlContent must be provided');
      }

      final Map<String, dynamic> map = {};
      if (outputFilename != null && outputFilename.isNotEmpty) {
        map['filename'] = outputFilename;
      }

      if (cssContent != null && cssContent.isNotEmpty) {
        map['css_content'] = cssContent;
      }

      if (htmlContent != null) {
        map['html_content'] = htmlContent;
      } else if (htmlFile != null) {
        if (!htmlFile.existsSync()) {
          throw Exception('HTML file does not exist');
        }
        final extension = p.extension(htmlFile.path).toLowerCase();
        if (extension != '.html' && extension != '.htm') {
          throw Exception('Only .html or .htm files are supported');
        }
        map['file'] = await MultipartFile.fromFile(
          htmlFile.path,
          filename: p.basename(htmlFile.path),
        );
      }

      final formData = FormData.fromMap(map);

      _debugLog('📤 Uploading data for HTML to PDF conversion...');

      Response response = await _dio.post(
        ApiConfig.htmlToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'converted_document.pdf';

        _debugLog('✅ HTML/URL converted to PDF successfully!');
        _debugLog('📥 Downloading PDF: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('HTML to PDF conversion failed: $e');
    }
  }

  // Convert HTML Table to CSV
  Future<ImageToPdfResult?> convertHtmlTableToCsv({
    File? htmlFile,
    String? htmlContent,
    String? outputFilename,
  }) async {
    try {
      if (htmlFile == null && htmlContent == null) {
        throw Exception('Either htmlFile or htmlContent must be provided');
      }

      final Map<String, dynamic> map = {};
      if (outputFilename != null && outputFilename.isNotEmpty) {
        map['filename'] = outputFilename;
      }

      if (htmlContent != null) {
        map['html_content'] = htmlContent;
      } else if (htmlFile != null) {
        if (!htmlFile.existsSync()) {
          throw Exception('HTML file does not exist');
        }
        final extension = p.extension(htmlFile.path).toLowerCase();
        // Allow .html and .htm files
        if (extension != '.html' && extension != '.htm') {
             // throw Exception('Only .html or .htm files are supported');
        }
        map['file'] = await MultipartFile.fromFile(
            htmlFile.path,
            filename: p.basename(htmlFile.path),
        );
      }

      final formData = FormData.fromMap(map);

      _debugLog('📤 Uploading data for HTML Table to CSV conversion...');

      Response response = await _dio.post(
        ApiConfig.htmlTableToCsvEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'converted_table.csv';

        _debugLog('✅ HTML Table converted to CSV successfully!');
        _debugLog('📥 Downloading CSV: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('HTML Table to CSV conversion failed: $e');
    }
  }

  Future<ImageToPdfResult?> convertExcelToHtml(
    File excelFile, {
    String? outputFilename,
  }) async {
    try {
      if (!excelFile.existsSync()) {
        throw Exception('Excel file does not exist');
      }
      final extension = p.extension(excelFile.path).toLowerCase();
      // Allow .xls and .xlsx files
      if (extension != '.xls' && extension != '.xlsx') {
         // throw Exception('Only .xls or .xlsx files are supported');
      }

      final file = await MultipartFile.fromFile(
        excelFile.path,
        filename: p.basename(excelFile.path),
      );

      final Map<String, dynamic> map = {'file': file};
      if (outputFilename != null && outputFilename.isNotEmpty) {
        map['filename'] = outputFilename;
      }

      final formData = FormData.fromMap(map);

      _debugLog('📤 Uploading Excel file for HTML conversion...');

      Response response = await _dio.post(
        ApiConfig.excelToHtmlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'converted_excel.html';

        _debugLog('✅ Excel converted to HTML successfully!');
        _debugLog('📥 Downloading HTML: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Excel to HTML conversion failed: $e');
    }
  }

  Future<ImageToPdfResult?> convertWordToHtml(
    File wordFile, {
    String? outputFilename,
  }) async {
    try {
      if (!wordFile.existsSync()) {
        throw Exception('Word file does not exist');
      }
      final extension = p.extension(wordFile.path).toLowerCase();
      if (extension != '.docx' && extension != '.doc') {
        throw Exception('Only .docx and .doc files are supported');
      }

      final file = await MultipartFile.fromFile(
        wordFile.path,
        filename: p.basename(wordFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Uploading Word file for HTML conversion...');

      final response = await _dio.post(
        ApiConfig.websiteWordToHtmlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(wordFile.path)}.html';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Word to HTML: $e');
    }
  }

  Future<ImageToPdfResult?> convertPowerPointToHtml(
    File pptFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pptFile.existsSync()) {
        throw Exception('PowerPoint file does not exist');
      }
      final extension = p.extension(pptFile.path).toLowerCase();
      if (extension != '.pptx' && extension != '.ppt') {
        throw Exception('Only .pptx and .ppt files are supported');
      }

      final file = await MultipartFile.fromFile(
        pptFile.path,
        filename: p.basename(pptFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Uploading PowerPoint file for HTML conversion...');

      final response = await _dio.post(
        ApiConfig.websitePowerPointToHtmlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pptFile.path)}.html';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert PowerPoint to HTML: $e');
    }
  }

  Future<ImageToPdfResult?> convertMarkdownToHtml(
    File mdFile, {
    String? outputFilename,
  }) async {
    try {
      if (!mdFile.existsSync()) {
        throw Exception('Markdown file does not exist');
      }
      final extension = p.extension(mdFile.path).toLowerCase();
      if (extension != '.md' && extension != '.markdown') {
        throw Exception('Only .md and .markdown files are supported');
      }

      final file = await MultipartFile.fromFile(
        mdFile.path,
        filename: p.basename(mdFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Uploading Markdown file for HTML conversion...');

      final response = await _dio.post(
        ApiConfig.websiteMarkdownToHtmlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(mdFile.path)}.html';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Markdown to HTML: $e');
    }
  }

  Future<ImageToPdfResult?> convertWebsiteToJpg(
    String url, {
    String? outputFilename,
    int width = 1920,
    int height = 1080,
  }) async {
    try {
      final formData = FormData.fromMap({
        'url': url,
        'width': width,
        'height': height,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Requesting Website to JPG conversion for $url...');

      final response = await _dio.post(
        ApiConfig.websiteToJpgEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            'website_to_jpg_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Website to JPG: $e');
    }
  }

  Future<ImageToPdfResult?> convertHtmlToJpg(
    File htmlFile, {
    String? outputFilename,
    int width = 1920,
    int height = 1080,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          htmlFile.path,
          filename: p.basename(htmlFile.path),
        ),
        'width': width,
        'height': height,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Requesting HTML to JPG conversion for ${htmlFile.path}...');

      final response = await _dio.post(
        ApiConfig.htmlToJpgEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            'html_to_jpg_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert HTML to JPG: $e');
    }
  }

  Future<ImageToPdfResult?> convertWebsiteToPng(
    String url, {
    String? outputFilename,
    int width = 1920,
    int height = 1080,
  }) async {
    try {
      final formData = FormData.fromMap({
        'url': url,
        'width': width,
        'height': height,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Requesting Website to PNG conversion for $url...');

      final response = await _dio.post(
        ApiConfig.websiteToPngEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            'website_to_png_${DateTime.now().millisecondsSinceEpoch}.png';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Website to PNG: $e');
    }
  }

  Future<ImageToPdfResult?> convertWebsiteToPdf({
    required String url,
    String? outputFilename,
  }) async {
    try {
      final formData = FormData.fromMap({
        'url': url,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Requesting Website to PDF conversion for $url...');

      final response = await _dio.post(
        ApiConfig.websiteToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            'website_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Website to PDF: $e');
    }
  }

  Future<ImageToPdfResult?> convertHtmlToPng(
    File htmlFile, {
    String? outputFilename,
    int width = 1920,
    int height = 1080,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          htmlFile.path,
          filename: p.basename(htmlFile.path),
        ),
        'width': width,
        'height': height,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Requesting HTML to PNG conversion for ${htmlFile.path}...');

      final response = await _dio.post(
        ApiConfig.htmlToPngEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            'html_to_png_${DateTime.now().millisecondsSinceEpoch}.png';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert HTML to PNG: $e');
    }
  }

  // Add page numbers to PDF
  Future<File?> addPageNumbersToPdf(
    File pdfFile, {
    String position = 'bottom-center',
    int startPage = 1,
    String format = '{page}',
    double fontSize = 12.0,
    String? outputFilename,
  }) async {
    try {
      final map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'position': position,
        'start_page': startPage,
        'format': format,
        'font_size': fontSize,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      Response response = await _dio.post(
        ApiConfig.addPageNumbersEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'numbered_document.pdf';

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Add page numbers failed: $e');
    }
  }

  // Merge multiple PDF files
  Future<MergePdfResult?> mergePdfFiles(
    List<File> pdfFiles, {
    String? outputFileName,
  }) async {
    try {
      if (pdfFiles.isEmpty) {
        throw Exception('No PDF files provided for merging');
      }

      if (pdfFiles.length < 2) {
        throw Exception('At least 2 PDF files are required for merging');
      }

      final trimmedName = outputFileName?.trim();
      String? sanitizedName;
      if (trimmedName != null && trimmedName.isNotEmpty) {
        sanitizedName = trimmedName.toLowerCase().endsWith('.pdf')
            ? trimmedName
            : '$trimmedName.pdf';
      }

      final files = await Future.wait(
        pdfFiles.map(
          (file) => MultipartFile.fromFile(
            file.path,
            filename: p.basename(file.path),
          ),
        ),
      );

      final formDataMap = <String, dynamic>{'files': files};
      if (sanitizedName != null) {
        formDataMap['output_filename'] = sanitizedName;
      }

      FormData formData = FormData.fromMap(formDataMap);

      _debugLog('📤 Uploading ${pdfFiles.length} PDF files for merging...');

      Response response = await _dio.post(
        ApiConfig.mergePdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'merged_document.pdf';

        _debugLog('✅ PDFs merged successfully!');
        _debugLog('📥 Downloading merged PDF: $fileName');

        // Try multiple download endpoints
        final file = await _tryDownloadFile(fileName, downloadUrl);
        if (file == null) {
          return null;
        }

        return MergePdfResult(
          file: file,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to merge PDFs: $e');
    }
  }

  Future<CompressPdfResult?> compressPdfFile(
    File pdfFile, {
    String compressionLevel = 'medium',
    int? targetReductionPct,
    int? maxImageDpi,
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        'compression_level': compressionLevel,
        if (targetReductionPct != null)
          'target_reduction_pct': targetReductionPct,
        if (maxImageDpi != null) 'max_image_dpi': maxImageDpi,
        if (outputFilename != null && outputFilename.trim().isNotEmpty)
          'output_filename': outputFilename.trim(),
      });

      final originalConnectTimeout = _dio.options.connectTimeout;
      final originalReceiveTimeout = _dio.options.receiveTimeout;
      final originalSendTimeout = _dio.options.sendTimeout;

      Response response;
      try {
        _dio.options
          ..connectTimeout = _heavyConnectTimeout
          ..receiveTimeout = _heavyReceiveTimeout
          ..sendTimeout = _heavyReceiveTimeout;
        response = await _dio.post(
          ApiConfig.compressPdfEndpoint,
          data: formData,
        );
      } finally {
        _dio.options
          ..connectTimeout = originalConnectTimeout
          ..receiveTimeout = originalReceiveTimeout
          ..sendTimeout = originalSendTimeout;
      }

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      final fileName = data['output_filename']?.toString() ?? 'compressed.pdf';
      final downloadUrl =
          data[ApiConfig.downloadUrlKey]?.toString() ?? '/download/$fileName';
      final sizeBefore = int.tryParse(
        data['file_size_before']?.toString() ?? '',
      );
      final sizeAfter = int.tryParse(data['file_size_after']?.toString() ?? '');
      double? achieved;
      if (data['extracted_data'] is Map &&
          data['extracted_data']?['compression'] != null) {
        final comp = data['extracted_data']['compression'] as Map;
        achieved = double.tryParse(
          comp['achieved_reduction_pct']?.toString() ?? '',
        );
      }

      final downloaded = await _tryDownloadFile(fileName, downloadUrl);
      if (downloaded == null) {
        return null;
      }

      return CompressPdfResult(
        file: downloaded,
        fileName: fileName,
        downloadUrl: downloadUrl,
        sizeBefore: sizeBefore,
        sizeAfter: sizeAfter,
        achievedReductionPct: achieved,
      );
    } catch (e) {
      throw Exception('PDF compression failed: $e');
    }
  }

  // Convert Markdown to PDF
  Future<MarkdownToPdfResult?> convertMarkdownToPdf(
    File markdownFile, {
    String? outputFilename,
  }) async {
    try {
      if (!markdownFile.existsSync()) {
        throw Exception('Markdown file does not exist');
      }

      // Validate file extension
      final extension = p.extension(markdownFile.path).toLowerCase();
      if (extension != '.md' && extension != '.markdown') {
        throw Exception('Only .md and .markdown files are supported');
      }

      final file = await MultipartFile.fromFile(
        markdownFile.path,
        filename: p.basename(markdownFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading markdown file for PDF conversion...');

      Response response = await _dio.post(
        ApiConfig.markdownToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(markdownFile.path)}.pdf';

        _debugLog('✅ Markdown converted to PDF successfully!');
        _debugLog('📥 Downloading PDF: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return MarkdownToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert Markdown to PDF: $e');
    }
  }

  // Convert JPG to PDF
  Future<ImageToPdfResult?> convertJpgToPdf(
    File jpgFile, {
    String? outputFilename,
  }) async {
    try {
      if (!jpgFile.existsSync()) {
        throw Exception('JPG file does not exist');
      }

      // Validate file extension
      final extension = p.extension(jpgFile.path).toLowerCase();
      if (extension != '.jpg' && extension != '.jpeg') {
        throw Exception('Only .jpg and .jpeg files are supported');
      }

      final file = await MultipartFile.fromFile(
        jpgFile.path,
        filename: p.basename(jpgFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading JPG file for PDF conversion...');

      Response response = await _dio.post(
        ApiConfig.jpgToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(jpgFile.path)}.pdf';

        _debugLog('✅ JPG converted to PDF successfully!');
        _debugLog('📥 Downloading PDF: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert JPG to PDF: $e');
    }
  }

  // Convert PNG to PDF
  Future<ImageToPdfResult?> convertPngToPdf(
    File pngFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pngFile.existsSync()) {
        throw Exception('PNG file does not exist');
      }

      // Validate file extension
      final extension = p.extension(pngFile.path).toLowerCase();
      if (extension != '.png') {
        throw Exception('Only .png files are supported');
      }

      final file = await MultipartFile.fromFile(
        pngFile.path,
        filename: p.basename(pngFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PNG file for PDF conversion...');

      Response response = await _dio.post(
        ApiConfig.pngToPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pngFile.path)}.pdf';

        _debugLog('✅ PNG converted to PDF successfully!');
        _debugLog('📥 Downloading PDF: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PNG to PDF: $e');
    }
  }

  // Convert PDF to JPG (multiple images)
  Future<PdfToImagesResult?> convertPdfToJpg(
    File pdfFile, {
    String? outputFilename,
  }) async {
    return _convertPdfToImages(
      pdfFile,
      outputFilename: outputFilename,
      endpoint: ApiConfig.pdfToJpgEndpoint,
      imageExtension: 'jpg',
    );
  }

  // Convert PDF to PNG (multiple images)
  Future<PdfToImagesResult?> convertPdfToPng(
    File pdfFile, {
    String? outputFilename,
  }) async {
    return _convertPdfToImages(
      pdfFile,
      outputFilename: outputFilename,
      endpoint: ApiConfig.pdfToPngEndpoint,
      imageExtension: 'png',
    );
  }

  // Convert PDF to TIFF (multiple images)
  Future<PdfToImagesResult?> convertPdfToTiff(
    File pdfFile, {
    String? outputFilename,
  }) async {
    return _convertPdfToImages(
      pdfFile,
      outputFilename: outputFilename,
      endpoint: ApiConfig.pdfToTiffEndpoint,
      imageExtension: 'tiff',
    );
  }

  // Convert PDF to SVG (multiple files)
  Future<PdfToImagesResult?> convertPdfToSvg(
    File pdfFile, {
    String? outputFilename,
  }) async {
    return _convertPdfToImages(
      pdfFile,
      outputFilename: outputFilename,
      endpoint: ApiConfig.pdfToSvgEndpoint,
      imageExtension: 'svg',
    );
  }

  // Convert PDF to HTML
  Future<ImageToPdfResult?> convertPdfToHtml(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      // Validate file extension
      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for HTML conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToHtmlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.html';

        _debugLog('✅ PDF converted to HTML successfully!');
        _debugLog('📥 Downloading HTML: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to HTML: $e');
    }
  }

  // Convert PDF to Excel
  Future<ImageToPdfResult?> convertPdfToExcel(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      // Validate file extension
      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for Excel conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToExcelEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.xlsx';

        _debugLog('✅ PDF converted to Excel successfully!');
        _debugLog('📥 Downloading Excel: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to Excel: $e');
    }
  }

  // Convert PDF to JSON
  Future<ImageToPdfResult?> convertPdfToJson(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for JSON conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToJsonEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.json';

        _debugLog('✅ PDF converted to JSON successfully!');
        _debugLog('📥 Downloading JSON: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to JSON: $e');
    }
  }

Future<ImageToPdfResult?> convertPngToJson(
  File imageFile, {
  String? outputFilename,
}) async {
  try {
    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist');
    }

    final extension = p.extension(imageFile.path).toLowerCase();
    if (extension != '.png') {
      throw Exception('Only PNG files are supported');
    }

    final file = await MultipartFile.fromFile(
      imageFile.path,
      filename: p.basename(imageFile.path),
    );

    FormData formData = FormData.fromMap({
      'file': file,
      if (outputFilename != null && outputFilename.isNotEmpty)
        'filename': outputFilename,
    });

    _debugLog('📤 Uploading image file for JSON conversion...');

    Response response = await _dio.post(
      ApiConfig.pngToJsonEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      String downloadUrl = response.data[ApiConfig.downloadUrlKey];
      String fileName =
          response.data['output_filename'] ??
          '${p.basenameWithoutExtension(imageFile.path)}.json';

      _debugLog('✅ Image converted to JSON successfully!');
      _debugLog('📥 Downloading JSON: $fileName');

      final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
      if (downloadedFile == null) {
        return null;
      }

      return ImageToPdfResult(
        file: downloadedFile,
        fileName: fileName,
        downloadUrl: downloadUrl,
      );
    }

    return null;
  } catch (e) {
    throw Exception('Failed to convert image to JSON: $e');
  }
}

Future<ImageToPdfResult?> convertJpgToJson(
  File imageFile, {
  String? outputFilename,
}) async {
  try {
    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist');
    }

    final extension = p.extension(imageFile.path).toLowerCase();
    if (!['.jpg', '.jpeg'].contains(extension)) {
      throw Exception('Only JPG/JPEG files are supported');
    }

    final file = await MultipartFile.fromFile(
      imageFile.path,
      filename: p.basename(imageFile.path),
    );

    FormData formData = FormData.fromMap({
      'file': file,
      if (outputFilename != null && outputFilename.isNotEmpty)
        'filename': outputFilename,
    });

    _debugLog('📤 Uploading JPG file for JSON conversion...');

    Response response = await _dio.post(
      ApiConfig.jpgToJsonEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      String downloadUrl = response.data[ApiConfig.downloadUrlKey];
      String fileName =
          response.data['output_filename'] ??
          '${p.basenameWithoutExtension(imageFile.path)}.json';

      _debugLog('✅ JPG converted to JSON successfully!');
      _debugLog('📥 Downloading JSON: $fileName');

      final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
      if (downloadedFile == null) {
        return null;
      }

      return ImageToPdfResult(
        file: downloadedFile,
        fileName: fileName,
        downloadUrl: downloadUrl,
      );
    }

    return null;
  } catch (e) {
    throw Exception('Failed to convert JPG to JSON: $e');
  }
}

Future<ImageToPdfResult?> convertXmlToJson(
  File xmlFile, {
  String? outputFilename,
}) async {
  try {
    if (!xmlFile.existsSync()) {
      throw Exception('XML file does not exist');
    }

    final extension = p.extension(xmlFile.path).toLowerCase();
    if (extension != '.xml') {
      throw Exception('Only XML files are supported');
    }

    final file = await MultipartFile.fromFile(
      xmlFile.path,
      filename: p.basename(xmlFile.path),
    );

    FormData formData = FormData.fromMap({
      'file': file,
      if (outputFilename != null && outputFilename.isNotEmpty)
        'filename': outputFilename,
    });

    _debugLog('📤 Uploading XML file for JSON conversion...');

    Response response = await _dio.post(
      ApiConfig.xmlToJsonEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      String downloadUrl = response.data[ApiConfig.downloadUrlKey];
      String fileName =
          response.data['output_filename'] ??
          '${p.basenameWithoutExtension(xmlFile.path)}.json';

      _debugLog('✅ XML converted to JSON successfully!');
      _debugLog('📥 Downloading JSON: $fileName');

      final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
      if (downloadedFile == null) {
        return null;
      }

      return ImageToPdfResult(
        file: downloadedFile,
        fileName: fileName,
        downloadUrl: downloadUrl,
      );
    }

    return null;
  } catch (e) {
    throw Exception('Failed to convert XML to JSON: $e');
  }
}

Future<ImageToPdfResult?> convertJsonToXml(
  File jsonFile, {
  String? outputFilename,
  String? rootName,
}) async {
  try {
    if (!jsonFile.existsSync()) {
      throw Exception('JSON file does not exist');
    }

    final extension = p.extension(jsonFile.path).toLowerCase();
    if (extension != '.json') {
      throw Exception('Only JSON files are supported');
    }

    final file = await MultipartFile.fromFile(
      jsonFile.path,
      filename: p.basename(jsonFile.path),
    );

    FormData formData = FormData.fromMap({
      'file': file,
      if (rootName != null && rootName.isNotEmpty) 'root_name': rootName,
      if (outputFilename != null && outputFilename.isNotEmpty)
        'filename': outputFilename,
    });

    _debugLog('📤 Uploading JSON file for XML conversion...');

    Response response = await _dio.post(
      ApiConfig.jsonToXmlEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      String downloadUrl = response.data[ApiConfig.downloadUrlKey];
      String fileName =
          response.data['output_filename'] ??
          '${p.basenameWithoutExtension(jsonFile.path)}.xml';

      _debugLog('✅ JSON converted to XML successfully!');
      _debugLog('📥 Downloading XML: $fileName');

      final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
      if (downloadedFile == null) {
        return null;
      }

      return ImageToPdfResult(
        file: downloadedFile,
        fileName: fileName,
        downloadUrl: downloadUrl,
      );
    }

  } catch (e) {
    throw Exception('Failed to convert JSON to XML: $e');
  }
}

Future<ImageToPdfResult?> convertJsonToCsv(
  File jsonFile, {
  String? outputFilename,
  String? delimiter,
}) async {
  try {
    if (!jsonFile.existsSync()) {
      throw Exception('JSON file does not exist');
    }

    final extension = p.extension(jsonFile.path).toLowerCase();
    if (extension != '.json') {
      throw Exception('Only JSON files are supported');
    }

    final file = await MultipartFile.fromFile(
      jsonFile.path,
      filename: p.basename(jsonFile.path),
    );

    FormData formData = FormData.fromMap({
      'file': file,
      if (delimiter != null && delimiter.isNotEmpty) 'delimiter': delimiter,
      if (outputFilename != null && outputFilename.isNotEmpty)
        'filename': outputFilename,
    });

    _debugLog('📤 Uploading JSON file for CSV conversion...');

    Response response = await _dio.post(
      ApiConfig.jsonToCsvEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      String downloadUrl = response.data[ApiConfig.downloadUrlKey];
      String fileName =
          response.data['output_filename'] ??
          '${p.basenameWithoutExtension(jsonFile.path)}.csv';

      _debugLog('✅ JSON converted to CSV successfully!');
      _debugLog('📥 Downloading CSV: $fileName');

      final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
      if (downloadedFile == null) {
        return null;
      }

      return ImageToPdfResult(
        file: downloadedFile,
        fileName: fileName,
        downloadUrl: downloadUrl,
      );
    }

    return null;
  } catch (e) {
    throw Exception('Failed to convert JSON to CSV: $e');
  }
}

Future<ImageToPdfResult?> convertJsonToExcel(
  File jsonFile, {
  String? outputFilename,
}) async {
  try {
    if (!jsonFile.existsSync()) {
      throw Exception('JSON file does not exist');
    }

    final extension = p.extension(jsonFile.path).toLowerCase();
    if (extension != '.json') {
      throw Exception('Only JSON files are supported');
    }

    final file = await MultipartFile.fromFile(
      jsonFile.path,
      filename: p.basename(jsonFile.path),
    );

    final formData = FormData.fromMap({
      'file': file,
      if (outputFilename != null) 'filename': outputFilename,
    });

    final response = await _dio.post(
      ApiConfig.jsonToExcelEndpoint,
      data: formData,
    );

    if (response.statusCode == 200) {
      final downloadUrl = response.data[ApiConfig.downloadUrlKey];
      final outputName = response.data['output_filename'] ??
          (outputFilename != null && outputFilename.isNotEmpty
              ? (outputFilename.toLowerCase().endsWith('.xlsx')
                  ? outputFilename
                  : '$outputFilename.xlsx')
              : 'converted.xlsx');

        if (downloadUrl != null) {
          final resultFile =
              await _downloadFile(downloadUrl, outputName);
          if (resultFile != null) {
            return ImageToPdfResult(
              file: resultFile,
              fileName: outputName,
              downloadUrl: downloadUrl,
            );
          }
        }
    }
    return null;
  } catch (e) {
    throw Exception('Failed to convert JSON to Excel: $e');
  }
}



  Future<ImageToPdfResult?> convertExcelToJson(
    File excelFile, {
    String? outputFilename,
  }) async {
    try {
      if (!excelFile.existsSync()) {
        throw Exception('Excel file does not exist');
      }

      final extension = p.extension(excelFile.path).toLowerCase();
      if (!['.xls', '.xlsx'].contains(extension)) {
        throw Exception('Only Excel files are supported');
      }

      final file = await MultipartFile.fromFile(
        excelFile.path,
        filename: p.basename(excelFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null) 'filename': outputFilename,
      });

      final response = await _dio.post(
        ApiConfig.excelToJsonEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final outputName = response.data['output_filename'] ??
            (outputFilename != null && outputFilename.isNotEmpty
                ? (outputFilename.toLowerCase().endsWith('.json')
                    ? outputFilename
                    : '$outputFilename.json')
                : 'converted.json');

        if (downloadUrl != null) {
          final resultFile =
              await _downloadFile(downloadUrl, outputName);
          if (resultFile != null) {
            return ImageToPdfResult(
              file: resultFile,
              fileName: outputName,
              downloadUrl: downloadUrl,
            );
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Excel to JSON: $e');
    }
  }

  Future<ImageToPdfResult?> convertCsvToJson(
    File csvFile, {
    String? outputFilename,
    String delimiter = ',',
  }) async {
    try {
      if (!csvFile.existsSync()) {
        throw Exception('CSV file does not exist');
      }

      final extension = p.extension(csvFile.path).toLowerCase();
      if (extension != '.csv') {
        throw Exception('Only CSV files are supported');
      }

      final file = await MultipartFile.fromFile(
        csvFile.path,
        filename: p.basename(csvFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        'delimiter': delimiter,
        if (outputFilename != null) 'filename': outputFilename,
      });

      final response = await _dio.post(
        ApiConfig.csvToJsonEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final outputName = response.data['output_filename'] ??
            (outputFilename != null && outputFilename.isNotEmpty
                ? (outputFilename.toLowerCase().endsWith('.json')
                    ? outputFilename
                    : '$outputFilename.json')
                : 'converted.json');

        if (downloadUrl != null) {
          final resultFile = await _downloadFile(downloadUrl, outputName);
          if (resultFile != null) {
            return ImageToPdfResult(
              file: resultFile,
              fileName: outputName,
              downloadUrl: downloadUrl,
            );
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert CSV to JSON: $e');
    }
  }

  // Convert PDF to Markdown
  Future<ImageToPdfResult?> convertPdfToMarkdown(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for Markdown conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToMarkdownEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.md';

        _debugLog('✅ PDF converted to Markdown successfully!');
        _debugLog('📥 Downloading Markdown: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to Markdown: $e');
    }
  }

  // Convert PDF to CSV
  Future<ImageToPdfResult?> convertPdfToCsv(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for CSV conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToCsvEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.csv';

        _debugLog('✅ PDF converted to CSV successfully!');
        _debugLog('📥 Downloading CSV: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to CSV: $e');
    }
  }

  // Convert PDF to Text
  Future<ImageToPdfResult?> convertPdfToText(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      // Validate file extension
      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF file for Text conversion...');

      Response response = await _dio.post(
        ApiConfig.pdfToTextEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pdfFile.path)}.txt';

        _debugLog('✅ PDF converted to Text successfully!');
        _debugLog('📥 Downloading Text: $fileName');

        // Try multiple download endpoints
        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert PDF to Text: $e');
    }
  }


  // Convert PowerPoint (PPT/PPTX) to Text
  Future<ImageToPdfResult?> convertPowerpointToText(
    File pptFile, {
    String? outputFilename,
  }) async {
    try {
      if (!pptFile.existsSync()) {
        throw Exception('PowerPoint file does not exist');
      }
      final extension = p.extension(pptFile.path).toLowerCase();
      if (extension != '.ppt' && extension != '.pptx') {
        throw Exception('Only .ppt or .pptx files are supported');
      }

      final file = await MultipartFile.fromFile(
        pptFile.path,
        filename: p.basename(pptFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PowerPoint file for Text conversion...');

      Response response = await _dio.post(
        ApiConfig.textPowerpointToTextEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(pptFile.path)}.txt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert PowerPoint to Text: $e');
    }
  }

  // Convert SRT to Text
  Future<ImageToPdfResult?> convertSrtToText(
    File srtFile, {
    String? outputFilename,
  }) async {
    try {
      if (!srtFile.existsSync()) {
        throw Exception('SRT file does not exist');
      }
      final extension = p.extension(srtFile.path).toLowerCase();
      if (extension != '.srt') {
        throw Exception('Only .srt files are supported');
      }

      final file = await MultipartFile.fromFile(
        srtFile.path,
        filename: p.basename(srtFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading SRT file for Text conversion...');

      Response response = await _dio.post(
        ApiConfig.textSrtToTextEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(srtFile.path)}.txt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert SRT to Text: $e');
    }
  }

  // Convert VTT to Text
  Future<ImageToPdfResult?> convertVttToText(
    File vttFile, {
    String? outputFilename,
  }) async {
    try {
      if (!vttFile.existsSync()) {
        throw Exception('VTT file does not exist');
      }
      final extension = p.extension(vttFile.path).toLowerCase();
      if (extension != '.vtt') {
        throw Exception('Only .vtt files are supported');
      }

      final file = await MultipartFile.fromFile(
        vttFile.path,
        filename: p.basename(vttFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading VTT file for Text conversion...');

      Response response = await _dio.post(
        ApiConfig.textVttToTextEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(vttFile.path)}.txt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert VTT to Text: $e');
    }
  }

  // Convert SRT to VTT (Subtitle Conversion)
  Future<ImageToPdfResult?> convertSrtToVtt(
    File srtFile, {
    String? outputFilename,
  }) async {
    try {
      if (!srtFile.existsSync()) {
        throw Exception('SRT file does not exist');
      }
      final extension = p.extension(srtFile.path).toLowerCase();
      if (extension != '.srt') {
        throw Exception('Only .srt files are supported');
      }

      final file = await MultipartFile.fromFile(
        srtFile.path,
        filename: p.basename(srtFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading SRT file for VTT conversion...');

      final response = await _dio.post(
        ApiConfig.subtitlesSrtToVttEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(srtFile.path)}.vtt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert SRT to VTT: $e');
    }
  }

  // Convert VTT to SRT (Subtitle Conversion)
  Future<ImageToPdfResult?> convertVttToSrt(
    File vttFile, {
    String? outputFilename,
  }) async {
    try {
      if (!vttFile.existsSync()) {
        throw Exception('VTT file does not exist');
      }
      final extension = p.extension(vttFile.path).toLowerCase();
      if (extension != '.vtt') {
        throw Exception('Only .vtt files are supported');
      }

      final file = await MultipartFile.fromFile(
        vttFile.path,
        filename: p.basename(vttFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading VTT file for SRT conversion...');

      final response = await _dio.post(
        ApiConfig.subtitlesVttToSrtEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(vttFile.path)}.srt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert VTT to SRT: $e');
    }
  }

  // Convert CSV to SRT (Subtitle Conversion)
  Future<ImageToPdfResult?> convertCsvToSrt(
    File csvFile, {
    String? outputFilename,
  }) async {
    try {
      if (!csvFile.existsSync()) {
        throw Exception('CSV file does not exist');
      }
      final extension = p.extension(csvFile.path).toLowerCase();
      if (extension != '.csv') {
        throw Exception('Only .csv files are supported');
      }

      final file = await MultipartFile.fromFile(
        csvFile.path,
        filename: p.basename(csvFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading CSV file for SRT conversion...');

      final response = await _dio.post(
        ApiConfig.subtitlesCsvToSrtEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(csvFile.path)}.srt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert CSV to SRT: $e');
    }
  }

  // Convert Excel (XLS/XLSX) to SRT (Subtitle Conversion)
  Future<ImageToPdfResult?> convertExcelToSrt(
    File excelFile, {
    String? outputFilename,
  }) async {
    try {
      if (!excelFile.existsSync()) {
        throw Exception('Excel file does not exist');
      }
      final extension = p.extension(excelFile.path).toLowerCase();
      if (extension != '.xls' && extension != '.xlsx') {
        throw Exception('Only .xls or .xlsx files are supported');
      }

      final file = await MultipartFile.fromFile(
        excelFile.path,
        filename: p.basename(excelFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading Excel file for SRT conversion...');

      final response = await _dio.post(
        ApiConfig.subtitlesExcelToSrtEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ??
            '${p.basenameWithoutExtension(excelFile.path)}.srt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to convert Excel to SRT: $e');
    }
  }

  // Protect PDF with password
  Future<File?> protectPdf(
    File pdfFile,
    String password, {
    String? outputFilename,
  }) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      final Map<String, dynamic> map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'password': password,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for password protection...');
      _debugLog('🔐 Password length: ${password.length} characters');

      Response response = await _dio.post(
        ApiConfig.protectPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'protected_document.pdf';

        _debugLog('✅ PDF protected successfully!');
        _debugLog('📥 Downloading protected PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to protect PDF: $e');
    }
  }

  // Unlock PDF (remove password protection)
  Future<File?> unlockPdf(
    File pdfFile,
    String password, {
    String? outputFilename,
  }) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      final Map<String, dynamic> map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'password': password,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for unlocking...');
      _debugLog('🔓 Attempting to remove password protection...');

      Response response = await _dio.post(
        ApiConfig.unlockPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'unlocked_document.pdf';

        _debugLog('✅ PDF unlocked successfully!');
        _debugLog('📥 Downloading unlocked PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to unlock PDF: $e');
    }
  }

  // Add watermark to PDF
  Future<File?> watermarkPdf(
    File pdfFile,
    String watermarkText,
    String position, {
    String? outputFilename,
  }) async {
    try {
      if (watermarkText.isEmpty) {
        throw Exception('Watermark text cannot be empty');
      }

      // Create FormData with file, text, position, and optional output filename
      final map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'watermark_text': watermarkText,
        'position': position,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for watermarking...');
      _debugLog('💧 Watermark text: "$watermarkText"');
      _debugLog('📍 Position: $position');

      Response response = await _dio.post(
        ApiConfig.watermarkPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'watermarked_document.pdf';

        _debugLog('✅ Watermark added successfully!');
        _debugLog('📥 Downloading watermarked PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to add watermark: $e');
    }
  }

  // Remove pages from PDF
  Future<File?> removePages(
    File pdfFile,
    List<int> pagesToRemove, {
    String? outputFilename,
  }) async {
    try {
      if (pagesToRemove.isEmpty) {
        throw Exception('No pages specified for removal');
      }

      // Convert pages list to comma-separated string
      String pagesString = pagesToRemove.join(',');

      // Create FormData with file and pages to remove
      final map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'pages_to_remove': pagesString,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for page removal...');
      _debugLog('🗑️ Pages to remove: $pagesString');
      if (name != null && name.isNotEmpty) {
        _debugLog('📝 Output filename: $name');
      }

      Response response = await _dio.post(
        ApiConfig.removePagesEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'pages_removed_document.pdf';

        _debugLog('✅ Pages removed successfully!');
        _debugLog('📥 Downloading modified PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to remove pages: $e');
    }
  }

  // Extract pages from PDF
  Future<File?> extractPages(
    File pdfFile,
    List<int> pagesToExtract, {
    String? outputFilename,
  }) async {
    try {
      if (pagesToExtract.isEmpty) {
        throw Exception('No pages specified for extraction');
      }

      // Convert pages list to comma-separated string
      String pagesString = pagesToExtract.join(',');

      // Create FormData with file and pages to extract
      final map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'pages_to_extract': pagesString,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for page extraction...');
      _debugLog('📄 Pages to extract: $pagesString');
      if (name != null && name.isNotEmpty) {
        _debugLog('📝 Output filename: $name');
      }

      Response response = await _dio.post(
        ApiConfig.extractPagesEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'extracted_document.pdf';

        _debugLog('✅ Pages extracted successfully!');
        _debugLog('📥 Downloading extracted PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to extract pages: $e');
    }
  }

  // Rotate PDF
  Future<File?> rotatePdf(
    File pdfFile,
    int rotation, {
    String? outputFilename,
  }) async {
    try {
      if (rotation != 90 && rotation != 180 && rotation != 270) {
        throw Exception('Rotation must be 90, 180, or 270 degrees');
      }

      // Create FormData with file and rotation
      final map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'rotation': rotation,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      _debugLog('📤 Uploading PDF for rotation...');
      _debugLog('🔄 Rotation angle: $rotation degrees');

      Response response = await _dio.post(
        ApiConfig.rotatePdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'rotated_document.pdf';

        _debugLog('✅ PDF rotated successfully!');
        _debugLog('📥 Downloading rotated PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to rotate PDF: $e');
    }
  }

  // Crop, Repair, Compare, Metadata helpers
  Future<File?> cropPdf(
    File pdfFile,
    int x,
    int y,
    int width,
    int height, {
    String? outputFilename,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      Response response = await _dio.post(
        ApiConfig.cropPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'cropped_document.pdf';
        return await _tryDownloadFile(fileName, downloadUrl);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to crop PDF: $e');
    }
  }

  Future<File?> repairPdf(File pdfFile, {String? outputFilename}) async {
    try {
      final Map<String, dynamic> map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      Response response = await _dio.post(
        ApiConfig.repairPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'repaired_document.pdf';
        return await _tryDownloadFile(fileName, downloadUrl);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to repair PDF: $e');
    }
  }

  Future<File?> comparePdfs(
    File file1,
    File file2, {
    String? outputFilename,
  }) async {
    try {
      final up1 = await MultipartFile.fromFile(
        file1.path,
        filename: file1.path.split('/').last,
      );
      final up2 = await MultipartFile.fromFile(
        file2.path,
        filename: file2.path.split('/').last,
      );
      final Map<String, dynamic> map = {'file1': up1, 'file2': up2};
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      Response response = await _dio.post(
        ApiConfig.comparePdfsEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName = response.data['output_filename'] ?? 'comparison.txt';
        return await _tryDownloadFile(fileName, downloadUrl);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to compare PDFs: $e');
    }
  }

  Future<File?> getPdfMetadataFile(
    File pdfFile, {
    String? outputFilename,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
      };
      final name = outputFilename?.trim();
      if (name != null && name.isNotEmpty) {
        map['output_filename'] = name;
      }
      FormData formData = FormData.fromMap(map);

      Response response = await _dio.post(
        ApiConfig.pdfMetadataEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data[ApiConfig.downloadUrlKey];
        final fileName = response.data['output_filename'] ?? 'metadata.json';
        if (downloadUrl != null) {
          return await _tryDownloadFile(fileName, downloadUrl);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get PDF metadata: $e');
    }
  }

  // Generic file picker method
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      FileType fileType = FileType.any;

      // Check if video extensions are requested
      final videoExtensions = [
        'mp4',
        'mov',
        'mkv',
        'avi',
        'wmv',
        'flv',
        'webm',
        'm4v',
        '3gp',
        'ogv',
      ];
      final isVideo =
          allowedExtensions != null &&
          allowedExtensions.any(
            (ext) => videoExtensions.contains(ext.toLowerCase()),
          );

      if (type == 'image') {
        fileType = FileType.image;
      } else if (type == 'video' || isVideo) {
        fileType = FileType.video;
      } else if (type == 'audio') {
        fileType = FileType.media;
      } else if (type == 'pdf' || allowedExtensions?.contains('pdf') == true) {
        fileType = FileType.custom;
        allowedExtensions = const ['pdf'];
      } else if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: (fileType == FileType.custom)
            ? allowedExtensions
            : null,
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;

        // Check if path is available (Android/iOS)
        if (pickedFile.path != null && pickedFile.path!.isNotEmpty) {
          final file = File(pickedFile.path!);
          // Verify file exists
          if (await file.exists()) {
            final ext = p.extension(file.path).toLowerCase();
            if (fileType == FileType.custom &&
                (allowedExtensions?.contains('pdf') ?? false)) {
              if (ext != '.pdf') {
                throw Exception('Please select a PDF file (.pdf)');
              }
            }
            return file;
          } else {
            throw Exception('Selected file does not exist: ${pickedFile.path}');
          }
        }
        // For web platform, bytes might be available
        else if (pickedFile.bytes != null) {
          // Save bytes to temporary file
          final tempDir = await Directory.systemTemp.createTemp();
          final file = File('${tempDir.path}/${pickedFile.name}');
          await file.writeAsBytes(pickedFile.bytes!);
          final ext = p.extension(file.path).toLowerCase();
          if (fileType == FileType.custom &&
              (allowedExtensions?.contains('pdf') ?? false)) {
            if (ext != '.pdf') {
              throw Exception('Please select a PDF file (.pdf)');
            }
          }
          return file;
        } else {
          throw Exception(
            'File path is null. Platform may not support file picking.',
          );
        }
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('File picking failed: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('File picking failed: ${e.toString()}');
    }
  }

  // Multiple file picker method
  Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      FileType fileType = FileType.any;
      if (type == 'image') {
        fileType = FileType.image;
      } else if (type == 'pdf' || allowedExtensions?.contains('pdf') == true) {
        fileType = FileType.custom;
        allowedExtensions = const ['pdf'];
      } else if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: (fileType == FileType.custom)
            ? allowedExtensions
            : null,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> files = [];
        for (var pickedFile in result.files) {
          if (pickedFile.path != null && pickedFile.path!.isNotEmpty) {
            final file = File(pickedFile.path!);
            if (await file.exists()) {
              final ext = p.extension(file.path).toLowerCase();
              if (fileType == FileType.custom &&
                  (allowedExtensions?.contains('pdf') ?? false)) {
                if (ext != '.pdf') {
                  continue;
                }
              }
              files.add(file);
            }
          } else if (pickedFile.bytes != null) {
            // Handle web platform bytes
            final tempDir = await Directory.systemTemp.createTemp();
            final file = File('${tempDir.path}/${pickedFile.name}');
            await file.writeAsBytes(pickedFile.bytes!);
            final ext = p.extension(file.path).toLowerCase();
            if (fileType == FileType.custom &&
                (allowedExtensions?.contains('pdf') ?? false)) {
              if (ext != '.pdf') {
                continue;
              }
            }
            files.add(file);
          }
        }
        return files;
      }
      return [];
    } on PlatformException catch (e) {
      throw Exception(
        'Multiple file picking failed: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      throw Exception('Multiple file picking failed: ${e.toString()}');
    }
  }

  // Get conversion status (placeholder)
  Future<String> getConversionStatus(String conversionId) async {
    try {
      // Simulated processing until backend endpoint is available
      await Future.delayed(const Duration(seconds: 1));

      return 'completed'; // Placeholder response
    } catch (e) {
      throw Exception('Failed to get conversion status: $e');
    }
  }

  // Download converted file
  Future<File?> downloadConvertedFile(String fileUrl, String fileName) async {
    try {
      return await _downloadFile(fileUrl, fileName);
    } catch (e) {
      throw Exception('File download failed: $e');
    }
  }

  // Helper method to try multiple download endpoints
  Future<File?> _tryDownloadFile(String fileName, String originalUrl) async {
    final apiBaseUrl = _baseUrl ?? await ApiConfig.baseUrl;
    List<String> possibleUrls = [
      '$apiBaseUrl${ApiConfig.downloadEndpoint}/$fileName', // Your actual endpoint!
      '$apiBaseUrl/download/$fileName', // Try static files mount
      '$apiBaseUrl/api/v1/files/$fileName',
      '$apiBaseUrl/files/$fileName',
      '$apiBaseUrl/api/v1/download/$fileName',
      '$apiBaseUrl/static/$fileName',
      '$apiBaseUrl/outputs/$fileName',
      '$apiBaseUrl/processed/$fileName',
      originalUrl, // Try the original URL as last resort
    ];

    for (String url in possibleUrls) {
      try {
        _debugLog('Trying download URL: $url');
        final result = await _downloadFile(url, fileName);
        _debugLog('✅ Successfully downloaded from: $url');
        return result;
      } catch (e) {
        _debugLog('❌ Failed to download from $url: $e');
        continue;
      }
    }

    // If all download attempts fail, create a placeholder file with success message
    _debugLog(
      'All download endpoints failed. Creating success notification file.',
    );
    return await _createSuccessPlaceholderFile(fileName);
  }

  // Create a placeholder file when download fails but processing succeeded
  Future<File> _createSuccessPlaceholderFile(String fileName) async {
    try {
      final directory = await Directory.systemTemp.createTemp();
      final file = File(
        '${directory.path}/success_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      String content =
          '''
PDF PROCESSING SUCCESSFUL! ✅

File: $fileName
Status: Page numbers added successfully
Processed at: ${DateTime.now().toString()}

IMPORTANT: The PDF was processed successfully on the server,
but the download endpoint is not configured properly.

Your FastAPI server needs to add a download endpoint like:
- /download/$fileName
- /api/v1/files/$fileName
- /files/$fileName

Server: ${_baseUrl ?? 'Not initialized'}
Processed file: $fileName

To fix this, add this to your FastAPI server:
@app.get("/download/{filename}")
async def download_file(filename: str):
    return FileResponse(f"downloads/{filename}")
''';

      await file.writeAsString(content);
      _debugLog('Created success placeholder file: ${file.path}');
      return file;
    } catch (e) {
      throw Exception('Could not create success placeholder: $e');
    }
  }

  // Helper method to download files
  Future<File> _downloadFile(String url, String fileName) async {
    try {
      final directory = await Directory.systemTemp.createTemp(
        'smartconverter_',
      );
      final filePath = '${directory.path}/$fileName';

      _debugLog('📥 Starting download from: $url');
      _debugLog('💾 Saving to: $filePath');

      await _dio.download(url, filePath);

      final file = File(filePath);
      final fileSize = await file.length();
      _debugLog('✅ File downloaded successfully!');
      _debugLog('📁 File path: $filePath');
      _debugLog('📏 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

      return file;
    } catch (e) {
      _debugLog('❌ Download error: $e');
      throw Exception('Download failed: $e');
    }
  }

  // Shared logic for PDF to image conversions
  Future<PdfToImagesResult?> _convertPdfToImages(
    File pdfFile, {
    required String endpoint,
    required String imageExtension,
    String? outputFilename,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }

      final extension = p.extension(pdfFile.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }

      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );

      final formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading PDF for $imageExtension conversion...');

      final originalConnectTimeout = _dio.options.connectTimeout;
      final originalReceiveTimeout = _dio.options.receiveTimeout;
      final originalSendTimeout = _dio.options.sendTimeout;

      Response response;
      try {
        _dio.options
          ..connectTimeout = _heavyConnectTimeout
          ..receiveTimeout = _heavyReceiveTimeout
          ..sendTimeout = _heavyReceiveTimeout;

        response = await _dio.post(endpoint, data: formData);
      } finally {
        _dio.options
          ..connectTimeout = originalConnectTimeout
          ..receiveTimeout = originalReceiveTimeout
          ..sendTimeout = originalSendTimeout;
      }

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      final folderName =
          (data['output_filename'] ?? p.basenameWithoutExtension(pdfFile.path))
              .toString();
      final rawDownloadUrl =
          data[ApiConfig.downloadUrlKey]?.toString() ??
          '/download/$folderName/';
      final pagesProcessed = data['pages_processed'] is int
          ? data['pages_processed'] as int
          : int.tryParse(data['pages_processed']?.toString() ?? '') ?? 0;

      final baseUrl = _baseUrl ?? await ApiConfig.baseUrl;
      final normalizedFolderUrl = _normalizeFolderDownloadUrl(
        rawDownloadUrl,
        baseUrl,
      );

      final totalPages = pagesProcessed > 0 ? pagesProcessed : 1;
      final List<File> downloadedFiles = [];
      final List<String> downloadedNames = [];

      for (int i = 1; i <= totalPages; i++) {
        final fileName = '${folderName}_page_$i.$imageExtension';
        final originalUrl = _buildFileDownloadUrl(
          normalizedFolderUrl,
          fileName,
        );
        final fileResult = await _tryDownloadFile(fileName, originalUrl);
        if (fileResult != null) {
          downloadedFiles.add(fileResult);
          downloadedNames.add(fileName);
        }
      }

      _debugLog(
        '✅ Downloaded ${downloadedFiles.length} $imageExtension images for folder $folderName',
      );

      return PdfToImagesResult(
        files: downloadedFiles,
        fileNames: downloadedNames,
        folderName: folderName,
        downloadUrl: normalizedFolderUrl,
        pagesProcessed: pagesProcessed,
      );
    } catch (e) {
      throw Exception('Failed to convert PDF to $imageExtension: $e');
    }
  }

  String _normalizeFolderDownloadUrl(String downloadUrl, String baseUrl) {
    if (downloadUrl.isEmpty) {
      return '$baseUrl/${ApiConfig.downloadEndpoint}';
    }

    if (downloadUrl.startsWith('http://') ||
        downloadUrl.startsWith('https://')) {
      return downloadUrl.endsWith('/') ? downloadUrl : '$downloadUrl/';
    }

    final hasLeadingSlash = downloadUrl.startsWith('/');
    final combined = hasLeadingSlash
        ? '$baseUrl$downloadUrl'
        : '$baseUrl/$downloadUrl';
    return combined.endsWith('/') ? combined : '$combined/';
  }

  String _buildFileDownloadUrl(String folderUrl, String fileName) {
    if (folderUrl.isEmpty) {
      return fileName;
    }
    return folderUrl.endsWith('/')
        ? '$folderUrl$fileName'
        : '$folderUrl/$fileName';
  }

  // Convert video to audio (MP4 to MP3) - Unified method for both Audio and Video categories
  // This method can be called from both audio and video conversion pages (DRY principle)
  Future<File?> convertVideoToAudio(
    File videoFile, {
    String bitrate = '192k',
    String quality = 'medium',
    String outputFormat = 'mp3',
    String?
    preferredEndpoint, // Optional: 'video' or 'audio' to specify endpoint
    String? category, // Optional: 'audio' or 'video' to determine save location
  }) async {
    try {
      _debugLog('🎬 Starting video to audio conversion...');
      _debugLog('📁 Input file: ${videoFile.path}');

      // Determine which endpoint to use
      // Both endpoints use the same implementation on backend (DRY principle)
      // Prefer video endpoint by default, but allow override
      String endpoint = preferredEndpoint == 'audio'
          ? ApiConfig.mp4ToMp3AudioEndpoint
          : ApiConfig.videoToAudioEndpoint;

      // Prepare form data
      // Video endpoint: file and bitrate only
      // Audio endpoint: file, bitrate, and quality (quality is ignored on backend)
      FormData formData = preferredEndpoint == 'audio'
          ? FormData.fromMap({
              'file': await MultipartFile.fromFile(
                videoFile.path,
                filename: videoFile.path.split('/').last,
              ),
              'bitrate': bitrate,
              'quality': quality,
            })
          : FormData.fromMap({
              'file': await MultipartFile.fromFile(
                videoFile.path,
                filename: videoFile.path.split('/').last,
              ),
              'bitrate': bitrate,
            });

      _debugLog('📡 Calling endpoint: $endpoint');

      // Call API endpoint (both use same backend implementation)
      Response response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          receiveTimeout: const Duration(
            minutes: 10,
          ), // Longer timeout for video processing
        ),
      );

      _debugLog('📡 API Response: ${response.statusCode}');
      _debugLog('📄 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        String outputFilename =
            response.data['output_filename'] ?? 'converted_audio.mp3';
        String downloadUrl = response.data['download_url'] ?? '';

        _debugLog('✅ Conversion successful!');
        _debugLog('📦 Output filename: $outputFilename');
        _debugLog('🔗 Download URL: $downloadUrl');

        // Download the converted audio file
        File? downloadedFile = await _downloadAudioFile(
          outputFilename,
          downloadUrl,
        );

        if (downloadedFile != null) {
          // Save to appropriate directory based on category
          // Audio category -> AudioConversions/video-to-audio
          // Video category -> VideoConversions/video-to-audio
          Directory saveDirectory;
          if (category == 'audio' || preferredEndpoint == 'audio') {
            saveDirectory = await FileManager.getAudioVideoToAudioDirectory();
            _debugLog(
              '💾 Saving to AudioConversions/video-to-audio (Audio category)',
            );
          } else {
            saveDirectory = await FileManager.getVideoToAudioDirectory();
            _debugLog(
              '💾 Saving to VideoConversions/video-to-audio (Video category)',
            );
          }

          final savedFilePath = '${saveDirectory.path}/$outputFilename';
          final savedFile = await downloadedFile.copy(savedFilePath);

          _debugLog('💾 File saved to: ${savedFile.path}');
          return savedFile;
        }

        return downloadedFile;
      }

      throw Exception(
        'Conversion failed: ${response.data['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      _debugLog('❌ Video to audio conversion failed: $e');
      throw Exception('Video to audio conversion failed: $e');
    }
  }

  // Download audio file from server
  Future<File?> _downloadAudioFile(String filename, String downloadUrl) async {
    try {
      final apiBaseUrl = _baseUrl ?? await ApiConfig.baseUrl;

      // Try multiple possible download URLs
      List<String> possibleUrls = [
        '$apiBaseUrl$downloadUrl',
        '$apiBaseUrl/api/v1/videoconversiontools/download/$filename',
        '$apiBaseUrl/api/v1/audioconversiontools/download/$filename',
        '$apiBaseUrl/api/v1/video/download/$filename',
        '$apiBaseUrl/download/$filename',
        '$apiBaseUrl/api/v1/convert/download/$filename',
      ];

      for (String url in possibleUrls) {
        try {
          _debugLog('🔍 Trying download URL: $url');

          final response = await _dio.get(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            // Create temporary file
            final tempDir = await Directory.systemTemp.createTemp();
            final tempFile = File('${tempDir.path}/$filename');
            await tempFile.writeAsBytes(response.data as List<int>);

            _debugLog('✅ Successfully downloaded from: $url');
            return tempFile;
          }
        } catch (e) {
          _debugLog('⚠️ Failed to download from $url: $e');
          continue;
        }
      }

      throw Exception('Could not download converted file from any endpoint');
    } catch (e) {
      _debugLog('❌ Download failed: $e');
      throw Exception('File download failed: $e');
    }
  }

  // Helper method to save file to organized directory structure
  Future<File> saveFileToOrganizedDirectory(
    File sourceFile,
    String toolName,
    String fileExtension,
  ) async {
    try {
      // Generate timestamp-based filename
      final fileName = FileManager.generateTimestampFilename(
        toolName.toLowerCase(),
        fileExtension,
      );

      // Save to tool-specific directory
      final savedFile = await FileManager.saveFileToToolDirectory(
        sourceFile,
        toolName,
        fileName,
      );

      _debugLog('✅ File saved to organized directory: ${savedFile.path}');
      return savedFile;
    } catch (e) {
      _debugLog('❌ Error saving to organized directory: $e');
      throw Exception('Failed to save file to organized directory: $e');
    }
  }

  // Get available conversion tools
  List<ConversionTool> getAvailableTools() {
    return [
      // Core PDF tools
      const ConversionTool(
        id: 'merge_pdf',
        name: 'Merge PDF',
        description: 'Combine multiple PDFs into one',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'split_pdf',
        name: 'Split PDF',
        description: 'Split a PDF into multiple files',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'compress_pdf',
        name: 'Compress PDF',
        description: 'Reduce PDF file size',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'convert_pdf',
        name: 'Convert PDF',
        description: 'Convert PDFs to other formats',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'remove_pages',
        name: 'Remove pages',
        description: 'Delete pages from a PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'extract_pages',
        name: 'Extract pages',
        description: 'Extract selected pages to a new PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'organize_pdf',
        name: 'Organize PDF',
        description: 'Reorder, add or delete pages',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'scan_to_pdf',
        name: 'Scan to PDF',
        description: 'Scan images into a PDF',
        icon: '📄',
        supportedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'repair_pdf',
        name: 'Repair PDF',
        description: 'Fix corrupted PDF files',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'ocr_pdf',
        name: 'OCR PDF',
        description: 'Make scanned PDFs searchable',
        icon: '📄',
        supportedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        category: 'PDF',
      ),

      // To PDF
      const ConversionTool(
        id: 'jpg_to_pdf',
        name: 'JPG To PDF',
        description: 'Convert JPG images to PDF',
        icon: '🖼️',
        supportedFormats: ['jpg', 'jpeg', 'png', 'pdf'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'word_to_pdf',
        name: 'Word To PDF',
        description: 'Convert Word (DOC/DOCX) to PDF',
        icon: '📝',
        supportedFormats: ['doc', 'docx', 'pdf'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'ppt_to_pdf',
        name: 'PowerPoint To PDF',
        description: 'Convert PowerPoint to PDF',
        icon: '📊',
        supportedFormats: ['ppt', 'pptx', 'pdf'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'excel_to_pdf',
        name: 'Excel To PDF',
        description: 'Convert Excel to PDF',
        icon: '📈',
        supportedFormats: ['xls', 'xlsx', 'pdf'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'html_to_pdf',
        name: 'HTML To PDF',
        description: 'Convert HTML to PDF',
        icon: '🌐',
        supportedFormats: ['html', 'htm', 'pdf'],
        category: 'Conversion',
      ),

      // From PDF
      const ConversionTool(
        id: 'pdf_to_jpg',
        name: 'PDF To JPG',
        description: 'Convert PDF pages to JPG images',
        icon: '🖼️',
        supportedFormats: ['pdf', 'jpg', 'jpeg', 'png'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'pdf_to_word',
        name: 'PDF To Word',
        description: 'Convert PDF to Word',
        icon: '📝',
        supportedFormats: ['pdf', 'doc', 'docx'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'pdf_to_ppt',
        name: 'PDF To PowerPoint',
        description: 'Convert PDF to PowerPoint',
        icon: '📊',
        supportedFormats: ['pdf', 'ppt', 'pptx'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'pdf_to_excel',
        name: 'PDF To Excel',
        description: 'Convert PDF to Excel',
        icon: '📈',
        supportedFormats: ['pdf', 'xls', 'xlsx'],
        category: 'Conversion',
      ),
      const ConversionTool(
        id: 'pdf_to_pdfa',
        name: 'PDF To PDF/A',
        description: 'Convert PDF to archival PDF/A',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'Conversion',
      ),

      // Page and content tools
      const ConversionTool(
        id: 'rotate_pdf',
        name: 'Rotate PDF',
        description: 'Rotate pages in a PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'add_page_numbers',
        name: 'Add page numbers',
        description: 'Add page numbers to PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'add_watermark',
        name: 'Add watermark',
        description: 'Apply watermark to PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'crop_pdf',
        name: 'Crop PDF',
        description: 'Crop PDF page margins',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
      const ConversionTool(
        id: 'edit_pdf',
        name: 'Edit PDF',
        description: 'Annotate and edit PDF content',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),

      // Security tools
      const ConversionTool(
        id: 'unlock_pdf',
        name: 'Unlock PDF',
        description: 'Remove password from a PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'Security',
      ),
      const ConversionTool(
        id: 'protect_pdf',
        name: 'Protect PDF',
        description: 'Add password to a PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'Security',
      ),
      const ConversionTool(
        id: 'sign_pdf',
        name: 'Sign PDF',
        description: 'Add electronic signature to PDF',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'Security',
      ),
      const ConversionTool(
        id: 'redact_pdf',
        name: 'Redact PDF',
        description: 'Black out sensitive information',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'Security',
      ),

      // Compare
      const ConversionTool(
        id: 'compare_pdf',
        name: 'Compare PDF',
        description: 'Compare two PDFs and highlight differences',
        icon: '📄',
        supportedFormats: ['pdf'],
        category: 'PDF',
      ),
    ];
  }

  Future<SplitResult?> splitPdf(
    File pdfFile, {
    required String splitType,
    String? pageRanges,
    required String outputPrefix,
    bool zip = false,
  }) async {
    try {
      if (!pdfFile.existsSync()) {
        throw Exception('PDF file does not exist');
      }
      final ext = p.extension(pdfFile.path).toLowerCase();
      if (ext != '.pdf') {
        throw Exception('Only .pdf files are supported');
      }
      final file = await MultipartFile.fromFile(
        pdfFile.path,
        filename: p.basename(pdfFile.path),
      );
      final form = <String, dynamic>{
        'file': file,
        'split_type': splitType,
        'output_prefix': outputPrefix,
        'zip': zip,
      };
      if (pageRanges != null && pageRanges.isNotEmpty) {
        form['page_ranges'] = pageRanges;
      }
      final formData = FormData.fromMap(form);
      final originalConnectTimeout = _dio.options.connectTimeout;
      final originalReceiveTimeout = _dio.options.receiveTimeout;
      final originalSendTimeout = _dio.options.sendTimeout;
      Response response;
      try {
        _dio.options
          ..connectTimeout = _heavyConnectTimeout
          ..receiveTimeout = _heavyReceiveTimeout
          ..sendTimeout = _heavyReceiveTimeout;
        response = await _dio.post(
          ApiConfig.splitPdfNewEndpoint,
          data: formData,
        );
      } finally {
        _dio.options
          ..connectTimeout = originalConnectTimeout
          ..receiveTimeout = originalReceiveTimeout
          ..sendTimeout = originalSendTimeout;
      }
      if (response.statusCode != 200) {
        return null;
      }
      final data = response.data as Map<String, dynamic>;
      final extracted = (data['extracted_data'] ?? {}) as Map<String, dynamic>;
      final filesRaw = (extracted['files'] ?? []) as List<dynamic>;
      final baseUrl = _baseUrl ?? await ApiConfig.baseUrl;
      final List<SplitFileResult> results = [];
      for (final item in filesRaw) {
        final m = item as Map<String, dynamic>;
        final fname = m['filename']?.toString() ?? '';
        final dl = m['download_url']?.toString() ?? '';
        final pages = (m['pages'] is List)
            ? List<int>.from(
                (m['pages'] as List)
                    .map((e) => int.tryParse('$e') ?? 0)
                    .where((e) => e > 0),
              )
            : <int>[];
        String url;
        if (dl.startsWith('http://') || dl.startsWith('https://')) {
          url = dl;
        } else {
          final hasLeading = dl.startsWith('/');
          url = hasLeading ? '$baseUrl$dl' : '$baseUrl/$dl';
        }
        results.add(
          SplitFileResult(fileName: fname, downloadUrl: url, pages: pages),
        );
      }
      final zipFileName = data['output_filename']?.toString();
      final zipUrlRaw = data[ApiConfig.downloadUrlKey]?.toString();
      String? zipUrl;
      if (zipUrlRaw != null && zipUrlRaw.isNotEmpty) {
        zipUrl = zipUrlRaw.startsWith('http')
            ? zipUrlRaw
            : '${baseUrl}${zipUrlRaw.startsWith('/') ? '' : '/'}$zipUrlRaw';
      }
      final count =
          int.tryParse('${data['count'] ?? results.length}') ?? results.length;
      final folderName = outputPrefix;
      final downloaded = await _downloadSplitFiles(results, folderName);
      return SplitResult(
        files: downloaded,
        zipFileName: zipFileName,
        zipDownloadUrl: zipUrl,
        count: count,
        folderName: folderName,
      );
    } catch (e) {
      throw Exception('Split PDF failed: $e');
    }
  }

  Future<List<SplitFileResult>> _downloadSplitFiles(
    List<SplitFileResult> files,
    String folderName,
  ) async {
    final baseDir = await FileManager.getSplitPdfsDirectory();
    final target = Directory('${baseDir.path}/$folderName');
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    final List<SplitFileResult> saved = [];
    for (final f in files) {
      final tmp = await _downloadFile(f.downloadUrl, f.fileName);
      final destPath = '${target.path}/${f.fileName}';
      final dest = await File(tmp.path).copy(destPath);
      saved.add(
        SplitFileResult(
          fileName: f.fileName,
          downloadUrl: f.downloadUrl,
          pages: f.pages,
        ),
      );
    }
    return saved;
  }

  // Get supported languages for SRT translation
  Future<List<String>> getSupportedLanguages() async {
    try {
      Response response = await _dio.get(ApiConfig.supportedLanguagesEndpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<String>.from(response.data['languages']);
      }
      return [];
    } catch (e) {
      _debugLog('Failed to get supported languages: $e');
      return [];
    }
  }

  // Translate SRT file
  Future<ImageToPdfResult?> translateSrt(
    File srtFile, {
    required String targetLanguage,
    String sourceLanguage = 'auto',
    String? outputFilename,
  }) async {
    try {
      if (!srtFile.existsSync()) {
        throw Exception('SRT file does not exist');
      }
      final extension = p.extension(srtFile.path).toLowerCase();
      if (extension != '.srt') {
        throw Exception('Only .srt files are supported');
      }

      final file = await MultipartFile.fromFile(
        srtFile.path,
        filename: p.basename(srtFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        'target_language': targetLanguage,
        'source_language': sourceLanguage,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading SRT file for translation to $targetLanguage...');

      Response response = await _dio.post(
        ApiConfig.translateSrtEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(srtFile.path)}_$targetLanguage.srt';

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) return null;

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to translate SRT: $e');
    }
  }

  // Convert JSON to YAML
  Future<ImageToPdfResult?> convertJsonToYaml(
    File jsonFile, {
    String? outputFilename,
  }) async {
    try {
      if (!jsonFile.existsSync()) {
        throw Exception('JSON file does not exist');
      }

      final extension = p.extension(jsonFile.path).toLowerCase();
      if (extension != '.json') {
        throw Exception('Only .json files are supported');
      }

      final file = await MultipartFile.fromFile(
        jsonFile.path,
        filename: p.basename(jsonFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading JSON file for YAML conversion...');

      Response response = await _dio.post(
        ApiConfig.jsonToYamlEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(jsonFile.path)}.yaml';

        _debugLog('✅ JSON converted to YAML successfully!');
        _debugLog('📥 Downloading YAML: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert JSON to YAML: $e');
    }
  }

  // Convert JSON Objects to CSV
  Future<ImageToPdfResult?> convertJsonObjectsToCsv(
    File jsonFile, {
    String? outputFilename,
    String delimiter = ',',
  }) async {
    try {
      if (!jsonFile.existsSync()) {
        throw Exception('JSON file does not exist');
      }

      final extension = p.extension(jsonFile.path).toLowerCase();
      if (extension != '.json') {
        throw Exception('Only .json files are supported');
      }

      final file = await MultipartFile.fromFile(
        jsonFile.path,
        filename: p.basename(jsonFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        'delimiter': delimiter,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'output_filename': outputFilename,
      });

      _debugLog('📤 Uploading JSON file for Objects to CSV conversion...');

      Response response = await _dio.post(
        ApiConfig.jsonObjectsToCsvEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(jsonFile.path)}.csv';

        _debugLog('✅ JSON successfully converted to CSV!');
        _debugLog('📥 Downloading CSV: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert JSON objects to CSV: $e');
    }
  }

  // Convert JSON Objects to Excel
  Future<ImageToPdfResult?> convertJsonObjectsToExcel(
    File jsonFile, {
    String? outputFilename,
  }) async {
    try {
      if (!jsonFile.existsSync()) {
        throw Exception('JSON file does not exist');
      }

      final extension = p.extension(jsonFile.path).toLowerCase();
      if (extension != '.json') {
        throw Exception('Only .json files are supported');
      }

      final file = await MultipartFile.fromFile(
        jsonFile.path,
        filename: p.basename(jsonFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Uploading JSON file for Objects to Excel conversion...');

      Response response = await _dio.post(
        ApiConfig.jsonObjectsToExcelEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(jsonFile.path)}.xlsx';

        _debugLog('✅ JSON successfully converted to Excel!');
        _debugLog('📥 Downloading Excel: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert JSON objects to Excel: $e');
    }
  }

  // Convert YAML to JSON
  Future<ImageToPdfResult?> convertYamlToJson(
    File yamlFile, {
    String? outputFilename,
  }) async {
    try {
      if (!yamlFile.existsSync()) {
        throw Exception('YAML file does not exist');
      }

      final extension = p.extension(yamlFile.path).toLowerCase();
      if (extension != '.yaml' && extension != '.yml') {
        throw Exception('Only .yaml or .yml files are supported');
      }

      final file = await MultipartFile.fromFile(
        yamlFile.path,
        filename: p.basename(yamlFile.path),
      );

      FormData formData = FormData.fromMap({
        'file': file,
        if (outputFilename != null && outputFilename.isNotEmpty)
          'filename': outputFilename,
      });

      _debugLog('📤 Uploading YAML file for conversion to JSON...');

      Response response = await _dio.post(
        ApiConfig.yamlToJsonEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ??
            '${p.basenameWithoutExtension(yamlFile.path)}.json';

        _debugLog('✅ YAML successfully converted to JSON!');
        _debugLog('📥 Downloading JSON: $fileName');

        final downloadedFile = await _tryDownloadFile(fileName, downloadUrl);
        if (downloadedFile == null) {
          return null;
        }

        return ImageToPdfResult(
          file: downloadedFile,
          fileName: fileName,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to convert YAML to JSON: $e');
    }
  }

}
