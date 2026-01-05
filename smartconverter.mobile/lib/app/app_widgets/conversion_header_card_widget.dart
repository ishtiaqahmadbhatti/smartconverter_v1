import '../app_modules/imports_module.dart';

class ConversionHeaderCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData? iconSource;
  final IconData? iconTarget;
  final IconData? sourceIcon;
  final IconData? destinationIcon;
  final IconData? icon;

  const ConversionHeaderCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.iconSource,
    this.iconTarget,
    this.sourceIcon,
    this.destinationIcon,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Determine effective icons
    final effectiveSource = iconSource ?? sourceIcon ?? icon ?? Icons.error;
    final effectiveTarget = iconTarget ?? destinationIcon ?? icon ?? Icons.error;
    
    // If only one icon is provided (via 'icon'), we might want a different layout,
    // but for consistency we'll use it for both slots or just rely on the fallback logic above.
    // If 'icon' is provided and others are null, effectiveSource and effectiveTarget will be 'icon'.

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
                    effectiveSource,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    effectiveTarget,
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
