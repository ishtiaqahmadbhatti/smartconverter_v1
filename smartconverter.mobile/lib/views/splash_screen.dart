import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/admob_service.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';
import 'sign_in_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Background animations
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _backgroundOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    // Progress bar controller (3 seconds)
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  void _startSplashSequence() async {
    // Start background animation
    _backgroundController.forward();

    // Wait a bit, then start logo animation
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // Wait a bit, then start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Start progress and wait 3s, then navigate
    _progressController.forward();
    await Future.delayed(const Duration(seconds: 3));
    await AdMobService.showAppOpenAdIfAvailable();
    _navigateToHome();
  }

  void _navigateToHome() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const MainNavigation() : const SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Animated background elements
            _buildAnimatedBackground(size),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value * 2 * 3.14159,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: _buildAppTitle(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value * 0.8,
                        child: _buildTagline(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading indicator
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Opacity(opacity: 1.0, child: _buildLoadingIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Opacity(
          opacity: _backgroundOpacityAnimation.value,
          child: Stack(
            children: [
              // Floating orbs
              Positioned(
                top: size.height * 0.1,
                left: size.width * 0.1,
                child: _buildFloatingOrb(AppColors.primaryBlue, 60),
              ),
              Positioned(
                top: size.height * 0.3,
                right: size.width * 0.15,
                child: _buildFloatingOrb(AppColors.secondaryGreen, 40),
              ),
              Positioned(
                bottom: size.height * 0.2,
                left: size.width * 0.2,
                child: _buildFloatingOrb(AppColors.primaryPurple, 80),
              ),
              Positioned(
                bottom: size.height * 0.4,
                right: size.width * 0.1,
                child: _buildFloatingOrb(AppColors.accentOrange, 50),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingOrb(Color color, double size) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: 2000.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 110,
            color: Colors.white,
          ),
          Positioned(
            top: 40,
            child: const Icon(
              Icons.sync,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      AppStrings.splashTitle,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      AppStrings.splashSubtitle,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: _progressAnimation.value,
            backgroundColor: AppColors.backgroundSurface,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.loading,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
