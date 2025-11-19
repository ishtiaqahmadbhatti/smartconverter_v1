import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'services/conversion_service.dart';
import 'services/admob_service.dart';
import 'views/splash_screen.dart';
import 'views/sign_in_page.dart';
import 'views/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdMobService.initialize();

  // Initialize services
  final conversionService = ConversionService();
  await conversionService.initialize();
  await AdMobService.loadAppOpenAd();

  // Preload rewarded ad
  final admobService = AdMobService();
  admobService.preloadAd();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [Provider<ConversionService>.value(value: conversionService)],
      child: const SmartConverterApp(),
    ),
  );
}

class SmartConverterApp extends StatelessWidget {
  const SmartConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
