import '../app_modules/imports_module.dart';

class ConversionConvertButtonWidget extends StatelessWidget {
  final VoidCallback? onConvert;
  final bool isConverting;
  final bool isEnabled;
  final String buttonText;
  
  // Aliases for refactored pages
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool? isLoading;

  const ConversionConvertButtonWidget({
    super.key,
    this.onConvert,
    this.isConverting = false,
    this.isEnabled = true,
    this.buttonText = 'Convert to Text',
    this.label,
    this.icon,
    this.onPressed,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = label ?? buttonText;
    final effectiveAction = onPressed ?? onConvert;
    final effectiveLoading = isLoading ?? isConverting;
    final effectiveEnabled = isEnabled && !effectiveLoading;

    final childWidget = effectiveLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textPrimary,
              ),
            ),
          )
        : Text(
            effectiveText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.textPrimary,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    );

    return SizedBox(
      width: double.infinity,
      child: icon != null && !effectiveLoading
          ? ElevatedButton.icon(
              onPressed: effectiveEnabled ? effectiveAction : null,
              style: buttonStyle,
              icon: Icon(icon),
              label: childWidget,
            )
          : ElevatedButton(
              onPressed: effectiveEnabled ? effectiveAction : null,
              style: buttonStyle,
              child: childWidget,
            ),
    );
  }

}
