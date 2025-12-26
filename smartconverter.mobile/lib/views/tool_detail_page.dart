import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/conversion_tool.dart';
import '../services/conversion_service.dart';
import '../app_widgets/futuristic_card_widget.dart';
import '../utils/file_manager.dart';

class ToolDetailPage extends StatefulWidget {
  final ConversionTool tool;

  const ToolDetailPage({super.key, required this.tool});

  @override
  State<ToolDetailPage> createState() => _ToolDetailPageState();
}

class _ToolDetailPageState extends State<ToolDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ConversionService _conversionService = ConversionService();
  File? _selectedFile;
  File? _convertedFile;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      List<String> allowedExtensions = [];

      switch (widget.tool.id) {
        case 'pdf_word':
          allowedExtensions = ['pdf', 'doc', 'docx'];
          break;
        case 'image_pdf':
          allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
          break;
        case 'text_word':
          allowedExtensions = ['txt', 'doc', 'docx'];
          break;
        case 'word_text':
          allowedExtensions = ['doc', 'docx', 'txt'];
          break;
        case 'html_pdf':
          allowedExtensions = ['html', 'htm', 'pdf'];
          break;
      }

      final file = await _conversionService.pickFile(
        allowedExtensions: allowedExtensions,
      );

      if (file != null) {
        setState(() {
          _selectedFile = file;
          _statusMessage = 'File selected: ${file.path.split('/').last}';
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick file: $e');
    }
  }

  Future<void> _convertFile() async {
    if (_selectedFile == null) {
      _showErrorDialog('Please select a file first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing...';
    });

    try {
      File? result;

      switch (widget.tool.id) {
        case 'pdf_word':
          final pdfWordResult = await _conversionService.convertPdfToWord(
            _selectedFile!,
          );
          result = pdfWordResult?.file;
          break;
        case 'image_pdf':
          result = await _conversionService.convertImageToPdf([_selectedFile!]);
          break;
        case 'text_word':
          result = await _conversionService.convertTextToWord(_selectedFile!);
          break;
        case 'word_text':
          final wordResult = await _conversionService.convertWordToText(
            _selectedFile!,
          );
          result = wordResult?.file;
          break;
        case 'html_pdf':
          final htmlResult = await _conversionService.convertHtmlToPdf(
            htmlFile: _selectedFile!,
          );
          result = htmlResult?.file;
          break;
      }

      setState(() {
        _isProcessing = false;
        _convertedFile = result;
        _statusMessage = result != null
            ? 'Conversion completed successfully!'
            : 'Conversion completed! (Demo mode)';
      });

      if (result != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Conversion failed: $e';
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Error',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Success',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your file has been converted successfully!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          if (_convertedFile != null) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _saveConvertedFile();
              },
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Save to Documents'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConvertedFile() async {
    if (_convertedFile == null) return;

    try {
      // Get tool name for folder organization
      String toolName = _getToolNameForFolder(widget.tool.id);
      String fileExtension = _getFileExtensionForTool(widget.tool.id);

      // Save to organized directory
      await FileManager.saveFileToToolDirectory(
        _convertedFile!,
        toolName,
        FileManager.generateTimestampFilename(
          toolName.toLowerCase(),
          fileExtension,
        ),
      );

      _showSuccessMessage('File saved to Documents/SmartConverter/$toolName');
    } catch (e) {
      _showErrorDialog('Save Error: $e');
    }
  }

  String _getToolNameForFolder(String toolId) {
    switch (toolId) {
      case 'pdf_word':
        return 'PdfToWord';
      case 'image_pdf':
        return 'ImageToPdf';
      case 'text_word':
        return 'TextToWord';
      case 'word_text':
        return 'WordToText';
      case 'html_pdf':
        return 'HtmlToPdf';
      case 'word_pdf':
        return 'WordToPdf';
      case 'merge_pdf':
        return 'MergePDF';
      case 'split_pdf':
        return 'SplitPDF';
      case 'compress_pdf':
        return 'CompressPDF';
      case 'rotate_pdf':
        return 'RotatePDF';
      case 'protect_pdf':
        return 'ProtectPDF';
      case 'unlock_pdf':
        return 'UnlockPDF';
      default:
        return 'ConvertedFiles';
    }
  }

  String _getFileExtensionForTool(String toolId) {
    switch (toolId) {
      case 'pdf_word':
        return 'docx';
      case 'image_pdf':
      case 'html_pdf':
      case 'word_pdf':
        return 'pdf';
      case 'text_word':
        return 'docx';
      case 'word_text':
        return 'txt';
      default:
        return 'pdf';
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.tool.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolInfo(),
          const SizedBox(height: 24),
          _buildFileSelection(),
          const SizedBox(height: 24),
          _buildConversionButton(),
          const SizedBox(height: 24),
          _buildStatusSection(),

        ],
      ),
    );
  }

  Widget _buildToolInfo() {
    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  widget.tool.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tool.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tool.category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.tool.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tool.supportedFormats
                .map(
                  (format) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      format.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelection() {
    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select File',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFile != null
                        ? Icons.check_circle
                        : Icons.cloud_upload,
                    size: 48,
                    color: _selectedFile != null
                        ? AppColors.success
                        : AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFile != null
                        ? 'File Selected'
                        : 'Tap to select file',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedFile != null
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _convertFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text(
                AppStrings.convert,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusSection() {
    if (_statusMessage.isEmpty) return const SizedBox.shrink();

    return FuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isProcessing
                  ? AppColors.warning.withOpacity(0.1)
                  : _statusMessage.contains('success') ||
                        _statusMessage.contains('completed')
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isProcessing
                    ? AppColors.warning
                    : _statusMessage.contains('success') ||
                          _statusMessage.contains('completed')
                    ? AppColors.success
                    : AppColors.info,
                width: 1,
              ),
            ),
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: _isProcessing
                    ? AppColors.warning
                    : _statusMessage.contains('success') ||
                          _statusMessage.contains('completed')
                    ? AppColors.success
                    : AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
