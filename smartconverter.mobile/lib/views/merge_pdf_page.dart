import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../services/conversion_service.dart';
import '../widgets/futuristic_card.dart';
import '../utils/file_manager.dart';
import 'package:file_picker/file_picker.dart';

class MergePdfPage extends StatefulWidget {
  const MergePdfPage({super.key});

  @override
  State<MergePdfPage> createState() => _MergePdfPageState();
}

class _MergePdfPageState extends State<MergePdfPage> {
  final ConversionService _conversionService = ConversionService();

  List<File> _selectedFiles = [];
  bool _isProcessing = false;
  File? _processedFile;

  Future<void> _pickPdfFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.files
              .map((file) => File(file.path!))
              .toList();
        });
      }
    } catch (e) {
      _showErrorDialog('File Selection Error', e.toString());
    }
  }

  Future<void> _mergePdfs() async {
    if (_selectedFiles.length < 2) {
      _showErrorDialog(
        'Insufficient Files',
        'Please select at least 2 PDF files to merge',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _conversionService.mergePdfFiles(_selectedFiles);

      setState(() {
        _isProcessing = false;
        _processedFile = result;
      });

      if (result != null) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
          'Merge Failed',
          'Could not merge PDF files. Please try again.',
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Processing Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
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
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Merge Complete!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ PDFs merged successfully!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedFiles.length} PDF files have been merged into one.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it!',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFileToDocuments() async {
    if (_processedFile == null) return;

    try {
      // Generate filename with timestamp
      final fileName = FileManager.generateTimestampFilename('merged', 'pdf');

      // Save file to the specific folder
      await FileManager.saveFileToToolDirectory(
        _processedFile!,
        'MergePDF',
        fileName,
      );

      _showSuccessMessage(
        'File saved to Documents/SmartConverter/MergePDF: $fileName',
      );
    } catch (e) {
      _showErrorDialog('Save Error', e.toString());
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

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _moveFileUp(int index) {
    if (index > 0) {
      setState(() {
        final file = _selectedFiles.removeAt(index);
        _selectedFiles.insert(index - 1, file);
      });
    }
  }

  void _moveFileDown(int index) {
    if (index < _selectedFiles.length - 1) {
      setState(() {
        final file = _selectedFiles.removeAt(index);
        _selectedFiles.insert(index + 1, file);
      });
    }
  }

  void _resetPage() {
    setState(() {
      _selectedFiles = [];
      _processedFile = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Merge PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            FuturisticCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.merge_type,
                          color: AppColors.primaryBlue,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merge PDF Files',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Combine multiple PDFs into one',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // File Selection Section
            if (_processedFile == null) ...[
              // Select Files Button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickPdfFiles,
                icon: const Icon(Icons.add_circle_outline, size: 24),
                label: Text(
                  _selectedFiles.isEmpty ? 'Select PDF Files' : 'Add More PDFs',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Files List
              if (_selectedFiles.isNotEmpty) ...[
                FuturisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selected Files (${_selectedFiles.length})',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Drag to reorder • Files will be merged in this order',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_selectedFiles.length, (index) {
                        final file = _selectedFiles[index];
                        final fileName = file.path.split('/').last;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Order number
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // File icon and name
                              const Icon(
                                Icons.picture_as_pdf,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Reorder buttons
                              IconButton(
                                icon: const Icon(Icons.arrow_upward, size: 18),
                                color: index > 0
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary.withOpacity(0.3),
                                onPressed: index > 0
                                    ? () => _moveFileUp(index)
                                    : null,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_downward,
                                  size: 18,
                                ),
                                color: index < _selectedFiles.length - 1
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary.withOpacity(0.3),
                                onPressed: index < _selectedFiles.length - 1
                                    ? () => _moveFileDown(index)
                                    : null,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                              // Remove button
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: AppColors.error,
                                onPressed: () => _removeFile(index),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Merge Button
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _mergePdfs,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.merge_type, size: 24),
                  label: Text(
                    _isProcessing ? 'Merging PDFs...' : 'Merge PDFs',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],

            // Success Section
            if (_processedFile != null) ...[
              FuturisticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${_selectedFiles.length} PDFs merged successfully!',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveFileToDocuments,
                            icon: const Icon(Icons.download, size: 20),
                            label: const Text('Save to Documents'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _resetPage,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Merge More'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
