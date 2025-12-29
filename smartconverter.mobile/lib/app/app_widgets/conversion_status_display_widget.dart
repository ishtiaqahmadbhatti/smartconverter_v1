import '../app_modules/imports_module.dart';

class ConversionStatusDisplayWidget extends StatelessWidget {
  final bool isConverting;
  final bool isSuccess;
  final String message;

  const ConversionStatusDisplayWidget({
    super.key,
    required this.isConverting,
    required this.isSuccess,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors and icons based on state
    final Color stateColor = isConverting
        ? AppColors.warning
        : isSuccess
            ? AppColors.success
            : AppColors.textSecondary;

    final IconData stateIcon = isConverting
        ? Icons.hourglass_empty
        : isSuccess
            ? Icons.check_circle
            : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            stateIcon,
            color: stateColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: stateColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper for ConversionStatusDisplayWidget to support refactored usage pattern
class ConversionStatusWidget extends StatelessWidget {
  final String statusMessage;
  final bool isConverting;
  final dynamic conversionResult;

  const ConversionStatusWidget({
    super.key,
    required this.statusMessage,
    required this.isConverting,
    this.conversionResult,
  });

  @override
  Widget build(BuildContext context) {
    return ConversionStatusDisplayWidget(
      isConverting: isConverting,
      message: statusMessage,
      isSuccess: conversionResult != null,
    );
  }
}
