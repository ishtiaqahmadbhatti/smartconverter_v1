import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
          'Help & Support',
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
                _buildSectionHeader('Contact Us', Icons.headset_mic_outlined, AppColors.primaryBlue),
                const SizedBox(height: 16),
                _buildContactCards(),
                const SizedBox(height: 30),
                _buildSectionHeader('Help Center', Icons.help_outline, AppColors.secondaryGreen),
                const SizedBox(height: 16),
                _buildFAQSection(
                  'What file formats are supported?',
                  'Smart Converter supports 100+ formats across PDF, Images, Videos, Audio, and Documents. We constantly add new formats based on user feedback.',
                ),
                _buildFAQSection(
                  'Is my data secure?',
                  'Yes! Most conversions happen locally on your device. For cloud-based conversions, files are encrypted during transfer and deleted immediately after processing.',
                ),
                _buildFAQSection(
                  'Can I use the app offline?',
                  'Core local conversion tools (like simple image or text edits) work offline. However, advanced conversions requiring cloud power need an internet connection.',
                ),
                _buildFAQSection(
                  'Where are my converted files?',
                  'All your converted files are saved in the "My Files" section of the app and also in your device\'s "Documents/SmartConverter" folder.',
                ),
                _buildFAQSection(
                  'How do I report a bug?',
                  'You can use the "Send Feedback" button below or email us directly at support@techmindsforge.com with details about the issue.',
                ),
                const SizedBox(height: 30),
                _buildSectionHeader('Share Feedback', Icons.rate_review_outlined, AppColors.primaryPurple),
                const SizedBox(height: 16),
                _buildFeedbackCard(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildContactCards() {
    return Column(
      children: [
        _buildContactItem(
          'Email Support',
          'support@techmindsforge.com',
          'We usually respond within 24 hours',
          Icons.mail_outline,
          AppColors.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          'Official Website',
          'www.techmindsforge.com',
          'Visit for more tools and updates',
          Icons.language_outlined,
          AppColors.primaryPurple,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildContactItem(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary.withOpacity(0.3), size: 14),
        ],
      ),
    );
  }

  Widget _buildFAQSection(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: AppColors.primaryBlue,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(
          question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              answer,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.thumb_up_alt_outlined, color: AppColors.primaryBlue, size: 30),
          const SizedBox(height: 12),
          const Text(
            'Enjoying Smart Converter?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your feedback helps us grow. Send us your suggestions or rate us on the Store!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'V 1.0.0 • TechMindsForge Support',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
