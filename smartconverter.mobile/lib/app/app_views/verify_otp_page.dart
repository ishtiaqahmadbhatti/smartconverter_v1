import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';
import '../app_services/auth_service.dart';
import '../app_services/auth_service.dart';
import 'reset_password_page.dart';
import 'package:provider/provider.dart';
import '../app_providers/subscription_provider.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;
  Timer? _timer;
  int _start = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  String get timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await AuthService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result['success']) {
        // Navigate to Reset Password Page with token
        final resetToken = result['reset_token'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(resetToken: resetToken),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Verification failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _resendCode() async {
    setState(() => _isSubmitting = true);
    try {
      final deviceId = await Provider.of<SubscriptionProvider>(context, listen: false).getDeviceId();
      await AuthService.sendOtp(
        email: widget.email,
        deviceId: deviceId,
      );
       if (!mounted) return;
       setState(() {
         _isSubmitting = false;
         _start = 180;
         startTimer();
       });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent successfully')),
      );
    } catch (e) {
       if (!mounted) return;
       setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          size: 60,
                          color: AppColors.primaryBlue,
                        ).animate().scale(duration: 500.ms),
                        const SizedBox(height: 24),
                        const Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary 
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit code sent to\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        
                        // OTP Input
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 24, 
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "______",
                            hintStyle: TextStyle(color: AppColors.textTertiary.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.textTertiary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Timer & Resend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              timerText,
                              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                        if (_start == 0)
                          TextButton(
                            onPressed: _isSubmitting ? null : _resendCode,
                            child: const Text('Resend Code', style: TextStyle(color: AppColors.primaryBlue)),
                          ),
                          
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _verify,
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                            ).copyWith(
                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              backgroundBuilder: (context, states, child) => Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: child,
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('VERIFY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
