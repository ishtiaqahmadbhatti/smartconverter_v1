import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isOldObscure = true;
  bool _isNewObscure = true;
  bool _isConfirmObscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
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
                                    Icons.lock_reset_rounded,
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
                                  'Security Update',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1,
                                  ),
                                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
                                
                                const Text(
                                  'Enter details to update your password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ).animate().fadeIn(delay: 500.ms),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Old Password
                          TextFormField(
                            controller: _oldPasswordController,
                            obscureText: _isOldObscure,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.lock_person_outlined, color: AppColors.primaryBlue),
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
                              suffixIcon: IconButton(
                                icon: Icon(_isOldObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                                onPressed: () => setState(() => _isOldObscure = !_isOldObscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Current password is required' : null,
                          )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideX(begin: -0.2, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 16),
                          
                          // New Password
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _isNewObscure,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.lock_open_outlined, color: AppColors.primaryBlue),
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
                              suffixIcon: IconButton(
                                icon: Icon(_isNewObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                                onPressed: () => setState(() => _isNewObscure = !_isNewObscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'New password is required';
                              if (v.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          )
                          .animate()
                          .fadeIn(delay: 700.ms)
                          .slideX(begin: -0.2, curve: Curves.easeOutCubic),
                          
                          const SizedBox(height: 16),
                          
                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _isConfirmObscure,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.primaryBlue),
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
                              suffixIcon: IconButton(
                                icon: Icon(_isConfirmObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                                onPressed: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                              ),
                            ),
                            validator: (v) {
                              if (v != _newPasswordController.text) return 'Passwords do not match';
                              return null;
                            },
                          )
                          .animate()
                          .fadeIn(delay: 800.ms)
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
                                      'UPDATE PASSWORD',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.9, 0.9)),
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
