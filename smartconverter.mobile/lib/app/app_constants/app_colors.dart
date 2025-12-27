import '../app_modules/imports_module.dart';

class AppColors {
  // Primary Colors - Futuristic Blue/Purple Gradient
  static const Color primaryBlue = Color(0xFF00D4FF);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF1E1B4B);

  // Secondary Colors - Electric Green/Cyan
  static const Color secondaryGreen = Color(0xFF00F5A0);
  static const Color secondaryCyan = Color(0xFF00E5FF);
  static const Color accentOrange = Color(0xFFFF6B35);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundSurface = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textTertiary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryGreen, secondaryCyan],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundSurface],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, backgroundSurface],
  );
}
