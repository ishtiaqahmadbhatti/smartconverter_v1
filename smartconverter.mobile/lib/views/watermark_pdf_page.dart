import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../services/conversion_service.dart';
import '../widgets/futuristic_card.dart';
import '../utils/file_manager.dart';
import 'package:file_picker/file_picker.dart';

class WatermarkPdfPage extends StatefulWidget {
  const WatermarkPdfPage({super.key});

  @override
  State<WatermarkPdfPage> createState() => _WatermarkPdfPageState();
}

class _WatermarkPdfPageState extends State<WatermarkPdfPage> {
  final ConversionService _conversionService = ConversionService();
  final TextEditingController _watermarkTextController =
      TextEditingController();

  File? _selectedFile;
  bool _isProcessing = false;
  File? _processedFile;
  String _position = 'center';

  final List<Map<String, dynamic>> _positions = [
    {
      'value': 'center',
      'label': 'Center',
      'icon': Icons.crop_square,
      'description': 'Center of page',
    },
    {
      'value': 'top-left',
      'label': 'Top Left',
      'icon': Icons.north_west,
      'description': 'Top-left corner',
    },
    {
      'value': 'top-right',
      'label': 'Top Right',
      'icon': Icons.north_east,
      'description': 'Top-right corner',
    },
    {
      'value': 'bottom-left',
      'label': 'Bottom Left',
      'icon': Icons.south_west,
      'description': 'Bottom-left corner',
    },
    {
      'value': 'bottom-right',
      'label': 'Bottom Right',
      'icon': Icons.south_east,
      'description': 'Bottom-right corner',
    },
    {
      'value': 'diagonal',
      'label': 'Diagonal',
      'icon': Icons.trending_up,
      'description': '45° angle',
    },
    {
      'value': 'diagonal-reverse',
      'label': 'Diagonal Reverse',
      'icon': Icons.trending_down,
      'description': '-45° angle',
    },
  ];

  @override
  void dispose() {
    _watermarkTextController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorDialog('File Selection Error', e.toString());
    }
  }

  Future<void> _addWatermark() async {
    // Validate inputs
    if (_selectedFile == null) {
      _showErrorDialog('No File Selected', 'Please select a PDF file first');
      return;
    }

    if (_watermarkTextController.text.isEmpty) {
      _showErrorDialog('No Watermark Text', 'Please enter watermark text');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _conversionService.watermarkPdf(
        _selectedFile!,
        _watermarkTextController.text,
        _position,
      );

      setState(() {
        _isProcessing = false;
        _processedFile = result;
      });

      if (result != null) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
          'Watermark Failed',
          'Could not add watermark to PDF. Please try again.',
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
              'Watermark Added!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ Watermark added successfully!',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your PDF now has a watermark.',
              style: TextStyle(color: AppColors.textSecondary),
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
      final fileName = FileManager.generateTimestampFilename(
        'watermarked',
        'pdf',
      );

      // Save file to the specific folder
      await FileManager.saveFileToToolDirectory(
        _processedFile!,
        'WatermarkPDF',
        fileName,
      );

      _showSuccessMessage(
        'File saved to Documents/SmartConverter/WatermarkPDF: $fileName',
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

  void _resetPage() {
    setState(() {
      _selectedFile = null;
      _processedFile = null;
      _isProcessing = false;
      _watermarkTextController.clear();
      _position = 'center';
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
          'Add Watermark',
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.waterfall_chart,
                      color: AppColors.primaryBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Watermark to PDF',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add custom text watermark to your PDF',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Content
            if (_processedFile == null) ...[
              // File Selection
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickPdfFile,
                icon: const Icon(Icons.upload_file, size: 24),
                label: Text(
                  _selectedFile == null ? 'Select PDF File' : 'Change PDF',
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

              if (_selectedFile != null) ...[
                const SizedBox(height: 16),

                // Selected File Display
                FuturisticCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected File:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Watermark Text Section
                FuturisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.text_fields,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Watermark Text',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Watermark Text Input
                      TextField(
                        controller: _watermarkTextController,
                        enabled: !_isProcessing,
                        maxLines: 2,
                        maxLength: 100,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Watermark Text',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          hintText: 'e.g., CONFIDENTIAL, DRAFT, © 2025',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.create,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          counterText: '', // Hide character counter
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Position Selection
                FuturisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Watermark Position',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Position Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: _positions.length,
                        itemBuilder: (context, index) {
                          final positionData = _positions[index];
                          final isSelected = _position == positionData['value'];

                          return GestureDetector(
                            onTap: _isProcessing
                                ? null
                                : () {
                                    setState(() {
                                      _position = positionData['value'];
                                    });
                                  },
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 60,
                                maxHeight: 80,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue.withOpacity(0.2)
                                    : AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryBlue.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      positionData['icon'],
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            positionData['label'],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppColors.primaryBlue
                                                  : AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Flexible(
                                          child: Text(
                                            positionData['description'],
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 9,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Add Watermark Button
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _addWatermark,
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
                      : const Icon(Icons.branding_watermark, size: 24),
                  label: Text(
                    _isProcessing ? 'Adding Watermark...' : 'Add Watermark',
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Watermark "${_watermarkTextController.text}" added!',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                            label: const Text('Add Another'),
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
