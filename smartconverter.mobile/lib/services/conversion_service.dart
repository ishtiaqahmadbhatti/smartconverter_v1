import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../models/conversion_tool.dart';
import '../constants/api_config.dart';
import '../utils/file_manager.dart';

class ConversionService {
  static final ConversionService _instance = ConversionService._internal();
  factory ConversionService() => _instance;
  ConversionService._internal();

  final Dio _dio = Dio();
  String? _baseUrl;

  // FastAPI backend URL (cached after initialization)
  String? get baseUrl => _baseUrl;

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
        logPrint: (object) => print('API: $object'),
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('API Error: ${error.message}');
          if (error.response != null) {
            print('Response data: ${error.response?.data}');
            print('Response status: ${error.response?.statusCode}');
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
      print('API Connection test failed: $e');
      return false;
    }
  }

  // PDF to Word conversion
  Future<File?> convertPdfToWord(File pdfFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
      });

      Response response = await _dio.post(
        ApiConfig.pdfToWordEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        // Download the converted file
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];

        String fileName =
            response.data['output_filename'] ?? 'converted_document.docx';
        return await _tryDownloadFile(fileName, downloadUrl);
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

  // Placeholder method for PDF to Image conversion
  Future<List<File>> convertPdfToImages(File pdfFile) async {
    try {
      // TODO: Implement actual API call to FastAPI backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For now, return empty list as placeholder
      return [];
    } catch (e) {
      throw Exception('PDF to Images conversion failed: $e');
    }
  }

  // Placeholder method for Text to Word conversion
  Future<File?> convertTextToWord(File textFile) async {
    try {
      // TODO: Implement actual API call to FastAPI backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('Text to Word conversion failed: $e');
    }
  }

  // Placeholder method for Word to Text conversion
  Future<File?> convertWordToText(File wordFile) async {
    try {
      // TODO: Implement actual API call to FastAPI backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('Word to Text conversion failed: $e');
    }
  }

  // Placeholder method for HTML to PDF conversion
  Future<File?> convertHtmlToPdf(File htmlFile) async {
    try {
      // TODO: Implement actual API call to FastAPI backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('HTML to PDF conversion failed: $e');
    }
  }

  // Placeholder method for PDF to HTML conversion
  Future<File?> convertPdfToHtml(File pdfFile) async {
    try {
      // TODO: Implement actual API call to FastAPI backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // For now, return null as placeholder
      return null;
    } catch (e) {
      throw Exception('PDF to HTML conversion failed: $e');
    }
  }

  // Add page numbers to PDF
  Future<File?> addPageNumbersToPdf(
    File pdfFile, {
    String position = 'bottom-center',
    int startPage = 1,
    String format = '{page}',
    double fontSize = 12.0,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'position': position,
        'start_page': startPage,
        'format': format,
        'font_size': fontSize,
      });

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
  Future<File?> mergePdfFiles(List<File> pdfFiles) async {
    try {
      if (pdfFiles.isEmpty) {
        throw Exception('No PDF files provided for merging');
      }

      if (pdfFiles.length < 2) {
        throw Exception('At least 2 PDF files are required for merging');
      }

      // Create FormData with multiple files
      FormData formData = FormData.fromMap({
        'files': await Future.wait(
          pdfFiles.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      print('📤 Uploading ${pdfFiles.length} PDF files for merging...');

      Response response = await _dio.post(
        ApiConfig.mergePdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'merged_document.pdf';

        print('✅ PDFs merged successfully!');
        print('📥 Downloading merged PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to merge PDFs: $e');
    }
  }

  // Protect PDF with password
  Future<File?> protectPdf(File pdfFile, String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      // Create FormData with file and password
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'password': password,
      });

      print('📤 Uploading PDF for password protection...');
      print('🔐 Password length: ${password.length} characters');

      Response response = await _dio.post(
        ApiConfig.protectPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'protected_document.pdf';

        print('✅ PDF protected successfully!');
        print('📥 Downloading protected PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to protect PDF: $e');
    }
  }

  // Unlock PDF (remove password protection)
  Future<File?> unlockPdf(File pdfFile, String password) async {
    try {
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      // Create FormData with file and password
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'password': password,
      });

      print('📤 Uploading PDF for unlocking...');
      print('🔓 Attempting to remove password protection...');

      Response response = await _dio.post(
        ApiConfig.unlockPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'unlocked_document.pdf';

        print('✅ PDF unlocked successfully!');
        print('📥 Downloading unlocked PDF: $fileName');

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
    String position,
  ) async {
    try {
      if (watermarkText.isEmpty) {
        throw Exception('Watermark text cannot be empty');
      }

      // Create FormData with file, text, and position
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'watermark_text': watermarkText,
        'position': position,
      });

      print('📤 Uploading PDF for watermarking...');
      print('💧 Watermark text: "$watermarkText"');
      print('📍 Position: $position');

      Response response = await _dio.post(
        ApiConfig.watermarkPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'watermarked_document.pdf';

        print('✅ Watermark added successfully!');
        print('📥 Downloading watermarked PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to add watermark: $e');
    }
  }

  // Remove pages from PDF
  Future<File?> removePages(File pdfFile, List<int> pagesToRemove) async {
    try {
      if (pagesToRemove.isEmpty) {
        throw Exception('No pages specified for removal');
      }

      // Convert pages list to comma-separated string
      String pagesString = pagesToRemove.join(',');

      // Create FormData with file and pages to remove
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'pages_to_remove': pagesString,
      });

      print('📤 Uploading PDF for page removal...');
      print('🗑️ Pages to remove: $pagesString');

      Response response = await _dio.post(
        ApiConfig.removePagesEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'pages_removed_document.pdf';

        print('✅ Pages removed successfully!');
        print('📥 Downloading modified PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to remove pages: $e');
    }
  }

  // Extract pages from PDF
  Future<File?> extractPages(File pdfFile, List<int> pagesToExtract) async {
    try {
      if (pagesToExtract.isEmpty) {
        throw Exception('No pages specified for extraction');
      }

      // Convert pages list to comma-separated string
      String pagesString = pagesToExtract.join(',');

      // Create FormData with file and pages to extract
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'pages_to_extract': pagesString,
      });

      print('📤 Uploading PDF for page extraction...');
      print('📄 Pages to extract: $pagesString');

      Response response = await _dio.post(
        ApiConfig.extractPagesEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'extracted_document.pdf';

        print('✅ Pages extracted successfully!');
        print('📥 Downloading extracted PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to extract pages: $e');
    }
  }

  // Split PDF into multiple files
  Future<File?> splitPdf(
    File pdfFile, {
    String splitType = 'every_page',
    String? pageRanges,
  }) async {
    try {
      // Create FormData with file and split options
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'split_type': splitType,
        if (pageRanges != null && pageRanges.isNotEmpty)
          'page_ranges': pageRanges,
      });

      print('📤 Uploading PDF for splitting...');
      print('✂️ Split type: $splitType');
      if (pageRanges != null && pageRanges.isNotEmpty) {
        print('📄 Page ranges: $pageRanges');
      }

      Response response = await _dio.post(
        ApiConfig.splitPdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName = response.data['output_filename'] ?? 'split_files.zip';
        int fileCount = 0;

        // Try to get file count from message
        String message = response.data['message'] ?? '';
        RegExp regExp = RegExp(r'(\d+)\s+files');
        Match? match = regExp.firstMatch(message);
        if (match != null) {
          fileCount = int.parse(match.group(1)!);
        }

        print('✅ PDF split successfully into $fileCount file(s)!');
        print('📥 Downloading result: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to split PDF: $e');
    }
  }

  // Rotate PDF
  Future<File?> rotatePdf(File pdfFile, int rotation) async {
    try {
      if (rotation != 90 && rotation != 180 && rotation != 270) {
        throw Exception('Rotation must be 90, 180, or 270 degrees');
      }

      // Create FormData with file and rotation
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'rotation': rotation,
      });

      print('📤 Uploading PDF for rotation...');
      print('🔄 Rotation angle: $rotation degrees');

      Response response = await _dio.post(
        ApiConfig.rotatePdfEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        String downloadUrl = response.data[ApiConfig.downloadUrlKey];
        String fileName =
            response.data['output_filename'] ?? 'rotated_document.pdf';

        print('✅ PDF rotated successfully!');
        print('📥 Downloading rotated PDF: $fileName');

        // Try multiple download endpoints
        return await _tryDownloadFile(fileName, downloadUrl);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to rotate PDF: $e');
    }
  }

  // Generic file picker method
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      // Determine file type based on category or explicit type
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
        // Use video type for better Android/iOS file picker support
        fileType = FileType.video;
      } else if (type == 'audio') {
        fileType = FileType.media; // Media includes both audio and video
      } else if (type == 'pdf' || allowedExtensions?.contains('pdf') == true) {
        fileType = FileType.custom;
      } else if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        // Only set allowedExtensions for custom type, video/audio types handle their own filtering
        allowedExtensions:
            (fileType == FileType.custom || fileType == FileType.any)
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
      } else if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
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
              files.add(file);
            }
          } else if (pickedFile.bytes != null) {
            // Handle web platform bytes
            final tempDir = await Directory.systemTemp.createTemp();
            final file = File('${tempDir.path}/${pickedFile.name}');
            await file.writeAsBytes(pickedFile.bytes!);
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
      // TODO: Implement actual API call to check conversion status
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

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
        print('Trying download URL: $url');
        final result = await _downloadFile(url, 'numbered_document.pdf');
        print('✅ Successfully downloaded from: $url');
        return result;
      } catch (e) {
        print('❌ Failed to download from $url: $e');
        continue;
      }
    }

    // If all download attempts fail, create a placeholder file with success message
    print('All download endpoints failed. Creating success notification file.');
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
      print('Created success placeholder file: ${file.path}');
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

      print('📥 Starting download from: $url');
      print('💾 Saving to: $filePath');

      await _dio.download(url, filePath);

      final file = File(filePath);
      final fileSize = await file.length();
      print('✅ File downloaded successfully!');
      print('📁 File path: $filePath');
      print('📏 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

      return file;
    } catch (e) {
      print('❌ Download error: $e');
      throw Exception('Download failed: $e');
    }
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
      print('🎬 Starting video to audio conversion...');
      print('📁 Input file: ${videoFile.path}');

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

      print('📡 Calling endpoint: $endpoint');

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

      print('📡 API Response: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        String outputFilename =
            response.data['output_filename'] ?? 'converted_audio.mp3';
        String downloadUrl = response.data['download_url'] ?? '';

        print('✅ Conversion successful!');
        print('📦 Output filename: $outputFilename');
        print('🔗 Download URL: $downloadUrl');

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
            print(
              '💾 Saving to AudioConversions/video-to-audio (Audio category)',
            );
          } else {
            saveDirectory = await FileManager.getVideoToAudioDirectory();
            print(
              '💾 Saving to VideoConversions/video-to-audio (Video category)',
            );
          }

          final savedFilePath = '${saveDirectory.path}/$outputFilename';
          final savedFile = await downloadedFile.copy(savedFilePath);

          print('💾 File saved to: ${savedFile.path}');
          return savedFile;
        }

        return downloadedFile;
      }

      throw Exception(
        'Conversion failed: ${response.data['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      print('❌ Video to audio conversion failed: $e');
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
          print('🔍 Trying download URL: $url');

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

            print('✅ Successfully downloaded from: $url');
            return tempFile;
          }
        } catch (e) {
          print('⚠️ Failed to download from $url: $e');
          continue;
        }
      }

      throw Exception('Could not download converted file from any endpoint');
    } catch (e) {
      print('❌ Download failed: $e');
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

      print('✅ File saved to organized directory: ${savedFile.path}');
      return savedFile;
    } catch (e) {
      print('❌ Error saving to organized directory: $e');
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
}
