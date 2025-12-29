import '../app_modules/imports_module.dart';

class ConversionHeaderCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData? iconSource;
  final IconData? iconTarget;
  final IconData? sourceIcon;
  final IconData? destinationIcon;

  const ConversionHeaderCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.iconSource,
    this.iconTarget,
    this.sourceIcon,
    this.destinationIcon,
  }) : assert(iconSource != null || sourceIcon != null, 'Must provide iconSource or sourceIcon'),
       assert(iconTarget != null || destinationIcon != null, 'Must provide iconTarget or destinationIcon');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(
                    iconSource ?? sourceIcon ?? Icons.error, // Fallback safely
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    iconTarget ?? destinationIcon ?? Icons.error, // Fallback safely
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
