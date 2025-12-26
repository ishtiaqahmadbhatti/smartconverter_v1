import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConversionActionButtonWidget extends StatelessWidget {
  final VoidCallback onPickFile;
  final VoidCallback? onReset;
  final bool isFileSelected;
  final bool isConverting;
  final String buttonText;

  const ConversionActionButtonWidget({
    super.key,
    required this.onPickFile,
    this.onReset,
    this.isFileSelected = false,
    this.isConverting = false,
    this.buttonText = 'Select File',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isConverting ? null : onPickFile,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              isFileSelected ? 'Change File' : buttonText,
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
        ),
        if (isFileSelected && onReset != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: isConverting ? null : onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ],
    );
  }
}
