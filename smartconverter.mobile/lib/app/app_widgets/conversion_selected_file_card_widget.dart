import '../app_modules/imports_module.dart';

class ConversionSelectedFileCardWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final IconData fileIcon;
  final String? fileTypeLabel;
  final VoidCallback? onRemove;

  const ConversionSelectedFileCardWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    this.fileIcon = Icons.description,
    this.fileTypeLabel,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fileIcon,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fileTypeLabel != null)
                 Text(
                   fileTypeLabel!,
                   style: const TextStyle(
                     color: AppColors.textSecondary,
                     fontSize: 10,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileSize,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              tooltip: 'Remove File',
            ),
          ],
        ],
      ),
    );
  }
}

/// Alias for ConversionSelectedFileCardWidget to support refactored usage
typedef ConversionFileCardWidget = ConversionSelectedFileCardWidget;
