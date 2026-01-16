import 'package:flutter/material.dart';
import '../app_constants/app_colors.dart';
import '../app_services/auth_service.dart';
import 'sign_in_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;

  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
  
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    // Simplified strength check as per request context, but good to keep basic check
    return true; 
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final result = await AuthService.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _passController.text,
      );
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      
      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.backgroundCard,
            title: const Text('Success', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text(
              'Your password has been reset successfully.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Navigate to SignInPage and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (route) => false,
                  );
                },
                child: const Text('Login Now', style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ],
          ),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to reset password'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password'), backgroundColor: Colors.transparent),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Enter New Password',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // Password
                          TextFormField(
                            controller: _passController,
                            obscureText: _isObscure,
                            style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                labelStyle: const TextStyle(fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                                  onPressed: () => setState(() => _isObscure = !_isObscure),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 8) return 'Min 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Confirm
                          TextFormField(
                            controller: _confirmPassController,
                            obscureText: _isConfirmObscure,
                            style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: const TextStyle(fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(_isConfirmObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                                  onPressed: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v != _passController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
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
                                : const Text('RESET PASSWORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
