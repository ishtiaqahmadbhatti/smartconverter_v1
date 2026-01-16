import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';
import '../app_services/auth_service.dart';
import 'sign_up_page.dart';
import '../app_services/auth_service.dart';
import 'sign_up_page.dart';
import 'verify_otp_page.dart';
import 'package:provider/provider.dart';
import '../app_providers/subscription_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final deviceId = await Provider.of<SubscriptionProvider>(context, listen: false).getDeviceId();
      final result = await AuthService.sendOtp(
        email: _emailController.text.trim(),
        deviceId: deviceId,
      );
      
      if (!mounted) return;
      
      setState(() => _isSubmitting = false);
      
      if (result['success']) {
        // Navigate to OTP Verification Page
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerifyOtpPage(email: _emailController.text.trim()),
          ),
        );
      } else {
        final message = result['message'] ?? 'Failed to reset password';
        
        if (message.contains('No account found')) {
           // Show Sign Up Dialog
           showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              title: const Text('Account Not Found', style: TextStyle(color: AppColors.textPrimary)),
              content: const Text(
                'No account exists with this email address.\nWould you like to create a new account?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close dialog
                    // Navigate to Sign Up Page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const SignUpPage(), // Pass email if possible, but SignUpPage might not accept it yet
                      ),
                    );
                  },
                  child: const Text('Sign Up', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: AppColors.backgroundCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset,
                                    color: AppColors.textPrimary,
                                    size: 40,
                                  ),
                                )
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 2000.ms, color: AppColors.textPrimary.withOpacity(0.3))
                                .animate()
                                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                                
                                const SizedBox(height: 16),
                                const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1,
                                  ),
                                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
                                
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'Please enter your registered email address. We will send a secure 6-digit OTP to verify your identity and reset your password',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 500.ms),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primaryBlue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                            validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!v.contains('@')) return 'Invalid email address';
                                return null;
                            },
                          )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideX(begin: -0.2, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 32),
                          
                          // Submit Button
                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textPrimary,
                                      ),
                                    )
                                  : const Text(
                                      'FORGOT PASSWORD',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
