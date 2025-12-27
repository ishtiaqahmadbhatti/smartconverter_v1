import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English (United States)', 'flag': '🇺🇸', 'status': 'Stable'},
    {'code': 'ur', 'name': 'Urdu (Coming Soon)', 'flag': '🇵🇰', 'status': 'Development'},
    {'code': 'hi', 'name': 'Hindi (Coming Soon)', 'flag': '🇮🇳', 'status': 'Development'},
    {'code': 'ar', 'name': 'Arabic (Coming Soon)', 'flag': '🇸🇦', 'status': 'Development'},
    {'code': 'es', 'name': 'Spanish (Coming Soon)', 'flag': '🇪🇸', 'status': 'Planned'},
    {'code': 'fr', 'name': 'French (Coming Soon)', 'flag': '🇫🇷', 'status': 'Planned'},
  ];

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
          'Language Settings',
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
                _buildDynamicRoadmapCard(),
                const SizedBox(height: 30),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                _buildLanguageList(),
                const SizedBox(height: 40),
                _buildDevNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicRoadmapCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_fix_high_outlined, color: AppColors.secondaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Language Roadmap',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Our development team is actively working on localized support. You will receive a notification as soon as new languages are available!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildLanguageList() {
    return Column(
      children: _languages
          .map((lang) => _buildLanguageItem(lang))
          .toList()
          .animate(interval: 50.ms)
          .fadeIn()
          .slideY(begin: 0.1),
    );
  }

  Widget _buildLanguageItem(Map<String, String> lang) {
    final bool isSelected = _selectedLanguage == lang['code'];
    final bool isComingSoon = lang['status'] != 'Stable';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? AppColors.primaryBlue.withOpacity(0.5) 
              : AppColors.textSecondary.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: isComingSoon ? null : () => setState(() => _selectedLanguage = lang['code']!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(
          lang['flag']!,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          lang['name']!,
          style: TextStyle(
            color: isComingSoon ? AppColors.textSecondary : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: isComingSoon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(color: AppColors.secondaryGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20)
                : null,
      ),
    );
  }

  Widget _buildDevNote() {
    return Column(
      children: [
        const Icon(Icons.info_outline, color: AppColors.textTertiary, size: 20),
        const SizedBox(height: 12),
        Text(
          'Your feedback helps us prioritize new languages. Contact support to request a specific translation!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
