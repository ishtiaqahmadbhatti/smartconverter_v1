import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';
import '../app_constants/app_strings.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
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
                  'Introduction',
                  'Welcome to Smart Converter. We value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safe-keep your information when you use our mobile application and related services.',
                  Icons.info_outline,
                ),
                _buildSection(
                  'Information We Collect',
                  'We may collect information you provide directly to us, such as your email address when you create an account. Additionally, we collect technical data like device information, operating system, and app usage statistics to improve our services.',
                  Icons.storage_outlined,
                ),
                _buildSection(
                  'File Processing & Privacy',
                  'Your files are processed locally whenever possible. For advanced features requiring cloud processing, files are transferred over secure, encrypted channels (HTTPS) and are automatically deleted from our servers immediately after the conversion is completed. We do not store your documents permanently.',
                  Icons.security,
                ),
                _buildSection(
                  'Information Usage',
                  'We use the collected information to:\n• Provide and maintain our services.\n• Personalize your user experience.\n• Process conversion requests efficiently.\n• Comply with legal obligations.',
                  Icons.assignment_outlined,
                ),
                _buildSection(
                  'Third-Party Services',
                  'Our app may use third-party services like AdMob for advertising. These services may collect data used to identify you. We recommend reviewing their respective privacy policies to understand their data practices.',
                  Icons.cloud_outlined,
                ),
                _buildSection(
                  'Data Security',
                  'We implement industry-standard security measures to protect your information. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
                  Icons.admin_panel_settings_outlined,
                ),
                _buildSection(
                  'Your Rights',
                  'You have the right to access, update, or delete your personal information within the app. If you wish to delete your account or have any privacy-related concerns, please contact our support team.',
                  Icons.how_to_reg_outlined,
                ),
                _buildSection(
                  'Children\'s Privacy',
                  'Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.',
                  Icons.child_care_outlined,
                ),
                _buildSection(
                  'Changes to This Policy',
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.',
                  Icons.update_outlined,
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
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
          ),
          child: const Text(
            'Effective Date: January 1, 2024',
            style: TextStyle(
              color: AppColors.primaryBlue,
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
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Text(
            'Questions or Feedback?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'If you have any questions about this Privacy Policy, please contact us at:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'support@techmindsforge.com',
            style: TextStyle(
              color: AppColors.primaryBlue,
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
            'Smart Converter Privacy Policy',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Updated: ${DateTime.now().year}',
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
