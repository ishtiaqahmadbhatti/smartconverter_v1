import '../app_controllers/core_controller.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * percentage;
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * percentage;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    double scaleFactor = 1.0;

    if (isMobile(context)) {
      scaleFactor = 1.0;
    } else if (isTablet(context)) {
      scaleFactor = 1.2;
    } else {
      scaleFactor = 1.4;
    }

    return baseFontSize * scaleFactor;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  static double getGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 1.1;
    } else if (isTablet(context)) {
      return 1.2;
    } else {
      return 1.3;
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static double getCardBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 18;
    } else {
      return 20;
    }
  }
}
