import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class TermsServicePage extends StatelessWidget {
  const TermsServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        leading: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildSection(
                  '1. Acceptance of Terms',
                  'By accessing or using Smart Converter, you agree to be bound by these Terms of Service. If you do not agree to all of these terms, do not use the application.',
                  Icons.check_circle_outline,
                ),
                _buildSection(
                  '2. License to Use',
                  'We grant you a personal, non-exclusive, non-transferable, limited license to use the app for your personal or professional file conversion needs, subject to these terms.',
                  Icons.vpn_key_outlined,
                ),
                _buildSection(
                  '3. User Responsibilities',
                  'You are responsible for all files you upload and convert. You must not use the service for any illegal purposes, including the processing of copyrighted material without authorization.',
                  Icons.person_outline,
                ),
                _buildSection(
                  '4. Intellectual Property',
                  'The app, including its original content, features, and functionality, are owned by TechMindsForge and are protected by international copyright, trademark, and other laws.',
                  Icons.copyright_outlined,
                ),
                _buildSection(
                  '5. Service Limitations',
                  'We strive for 100% accuracy in conversions, but we do not guarantee that the output will always be perfect. We reserve the right to modify or discontinue the service at any time.',
                  Icons.error_outline,
                ),
                _buildSection(
                  '6. Limitation of Liability',
                  'TechMindsForge shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use of or inability to use the service.',
                  Icons.gavel_outlined,
                ),
                _buildSection(
                  '7. Termination',
                  'We may terminate or suspend your access to the service immediately, without prior notice or liability, for any reason, including breach of these Terms.',
                  Icons.exit_to_app_outlined,
                ),
                _buildSection(
                  '8. Governing Law',
                  'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which TechMindsForge operates, without regard to its conflict of law provisions.',
                  Icons.language_outlined,
                ),
                _buildContactInfo(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryGreen.withOpacity(0.2)),
          ),
          child: const Text(
            'Last Updated: January 1, 2024',
            style: TextStyle(
              color: AppColors.secondaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secondaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1);
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryGreen.withOpacity(0.1),
            AppColors.secondaryCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreen.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Text(
            'Legal Inquiries',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'For any questions regarding these Terms, please reach out to us:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'legal@techmindsforge.com',
            style: TextStyle(
              color: AppColors.secondaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'Smart Converter Terms of Service',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© ${DateTime.now().year} TechMindsForge',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
