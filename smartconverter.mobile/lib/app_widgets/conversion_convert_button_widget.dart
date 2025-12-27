import '../app_modules/imports_module.dart';

class ConversionConvertButtonWidget extends StatelessWidget {
  final VoidCallback onConvert;
  final bool isConverting;
  final bool isEnabled;
  final String buttonText;

  const ConversionConvertButtonWidget({
    super.key,
    required this.onConvert,
    required this.isConverting,
    this.isEnabled = true,
    this.buttonText = 'Convert to Text',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onConvert : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: isConverting
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
                buttonText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
