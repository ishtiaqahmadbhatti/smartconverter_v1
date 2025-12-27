import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _allNotifications = true;
  bool _conversionAlerts = true;
  bool _appUpdates = true;
  bool _marketingTips = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allNotifications = prefs.getBool('all_notifications') ?? true;
      _conversionAlerts = prefs.getBool('conversion_alerts') ?? true;
      _appUpdates = prefs.getBool('app_updates') ?? true;
      _marketingTips = prefs.getBool('marketing_tips') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('all_notifications', _allNotifications);
    await prefs.setBool('conversion_alerts', _conversionAlerts);
    await prefs.setBool('app_updates', _appUpdates);
    await prefs.setBool('marketing_tips', _marketingTips);
  }

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
          'Notifications',
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
                _buildMasterToggle(),
                const SizedBox(height: 30),
                const Text(
                  'Preferences',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                _buildSettingsSection(),
                const SizedBox(height: 40),
                _buildNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Alerts',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Choose how we notify you about your conversions and updates.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildMasterToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _allNotifications 
              ? AppColors.primaryBlue.withOpacity(0.3) 
              : AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Allow Notifications',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch.adaptive(
            value: _allNotifications,
            activeColor: AppColors.primaryBlue,
            onChanged: (value) {
              setState(() {
                _allNotifications = value;
                if (!value) {
                  _conversionAlerts = false;
                  _appUpdates = false;
                  _marketingTips = false;
                } else {
                  _conversionAlerts = true;
                  _appUpdates = true;
                }
              });
              _saveAllSettings();
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildToggleItem(
          'Conversion Alerts',
          'Notify me when a file is ready',
          Icons.auto_awesome_outlined,
          _conversionAlerts,
          (value) {
            setState(() => _conversionAlerts = value);
            _saveSetting('conversion_alerts', value);
          },
        ),
        _buildToggleItem(
          'App Updates',
          'New features and tool releases',
          Icons.system_update_alt_outlined,
          _appUpdates,
          (value) {
            setState(() => _appUpdates = value);
            _saveSetting('app_updates', value);
          },
        ),
        _buildToggleItem(
          'Marketing & Tips',
          'Daily tips and special offers',
          Icons.lightbulb_outline,
          _marketingTips,
          (value) {
            setState(() => _marketingTips = value);
            _saveSetting('marketing_tips', value);
          },
        ),
      ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Opacity(
      opacity: _allNotifications ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            Switch.adaptive(
              value: value,
              activeColor: AppColors.primaryBlue,
              onChanged: _allNotifications ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Center(
      child: Text(
        'Some alerts may still be sent for critical account security.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.5),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}
