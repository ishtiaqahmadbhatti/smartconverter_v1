import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../app_constants/app_colors.dart';
import '../app_constants/api_config.dart';
import 'change_password_page.dart';
import 'subscription_page.dart';
import 'edit_profile_page.dart';
import '../app_services/auth_service.dart';
import 'package:provider/provider.dart';
import '../app_providers/subscription_provider.dart';
import 'main_navigation.dart';
import '../app_services/conversion_service.dart';
import '../app_models/history_model.dart';
import '../app_utils/file_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isBiometricEnabled = false;
  final LocalAuthentication auth = LocalAuthentication();

  UsageStats? _stats;
  bool _isStatsLoading = true;
  final ConversionService _conversionService = ConversionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).checkStatus();
      _checkBiometricStatus();
      _fetchStats();
    });
  }

  Future<void> _fetchStats() async {
    if (mounted) setState(() => _isStatsLoading = true);
    final stats = await _conversionService.getUserStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isStatsLoading = false;
      });
    }
  }

  Future<void> _checkBiometricStatus() async {
    final enabled = await AuthService.isBiometricEnabled();
    if (mounted) setState(() => _isBiometricEnabled = enabled);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Enabling: Ask for password to save credentials
      final password = await _showPasswordDialog();
      if (password != null && password.isNotEmpty) {
        // Optional: Verify password with an API call here if strict security needed,
        // or just rely on current valid session + user knowing the password.
        // For better security, let's just save valid email/pass.
        // We need the email from SubscriptionProvider
        final email = Provider.of<SubscriptionProvider>(
          context,
          listen: false,
        ).userEmail;
        await AuthService.saveCredentialsForBiometric(email, password);
        await AuthService.setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric login enabled')),
          );
        }
      }
    } else {
      // Disabling
      await AuthService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  Future<String?> _showPasswordDialog() async {
    String password = '';
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Confirm Password',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to enable biometric login.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              onChanged: (v) => password = v,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, password),
            child: const Text(
              'Enable',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody()
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.1, duration: 800.ms);
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildAccountSection(),
          const SizedBox(height: 32),
          Consumer<SubscriptionProvider>(
            builder: (context, subscription, _) {
              if (subscription.isGuest) return const SizedBox.shrink();
              return Column(
                children: [_buildLogoutButton(), const SizedBox(height: 24)],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.error.withOpacity(0.8), AppColors.error],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              title: const Text(
                'Log Out',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: const Text(
                'Are you sure you want to log out?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await AuthService.clearTokens();
            if (!mounted) return;

            // Update subscription provider
            Provider.of<SubscriptionProvider>(context, listen: false).refresh();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed out successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Redirect to Home Page (Index 0)
            try {
              MainNavigation.of(context).setSelectedIndex(0);
            } catch (e) {
              debugPrint('Navigation error: $e');
            }
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.textPrimary),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.secondaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Consumer<SubscriptionProvider>(
        builder: (context, subscription, child) {
          final isPremium = subscription.isPremium;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: subscription.profileImageUrl != null
                      ? FutureBuilder<String>(
                          future: ApiConfig
                              .baseUrl, // We need base URL to construct full path
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // Handle relative path
                              final fullUrl =
                                  subscription.profileImageUrl!.startsWith(
                                    'http',
                                  )
                                  ? subscription.profileImageUrl!
                                  : '${snapshot.data}/${subscription.profileImageUrl!}';
                              return Image.network(
                                fullUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.textPrimary,
                                  );
                                },
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textPrimary,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subscription.userName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subscription.userEmail,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (!subscription.isGuest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isPremium
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFFC107),
                              Color(0xFFFF9800),
                            ], // Gold to Orange
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.textSecondary.withOpacity(0.2),
                              AppColors.textSecondary.withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isPremium
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                    border: isPremium
                        ? Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          )
                        : Border.all(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            width: 1,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPremium) ...[
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isPremium ? 'PREMIUM MEMBER' : 'FREE ACCOUNT',
                        style: TextStyle(
                          color: isPremium
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Usage Statistics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                _isStatsLoading
                    ? '...'
                    : (_stats?.filesConverted.toString() ?? '0'),
                'Files Converted',
                Icons.file_copy_outlined,
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                _isStatsLoading
                    ? '...'
                    : FileManager.formatBytes(_stats?.dataProcessedBytes ?? 0),
                'Data Processed',
                Icons.storage_outlined,
                AppColors.secondaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                _isStatsLoading
                    ? '...'
                    : (_stats?.daysActive.toString() ?? '0'),
                'Days Active',
                Icons.calendar_today_outlined,
                AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        // Build list of settings based on login status
        final List<Widget> settingItems = [];

        // Only show these options for logged-in users
        if (!subscription.isGuest) {
          settingItems.addAll([
            _buildSettingItem(
              'Personal Information',
              'Update your profile details',
              Icons.person_outline,
              () => _showEditProfileDialog(),
            ),
            _buildSettingItem(
              'Change Password',
              'Update your account password',
              Icons.lock_outline,
              () => _showChangePasswordPage(),
            ),
            SwitchListTile(
              value: _isBiometricEnabled,
              onChanged: _toggleBiometric,
              title: const Text(
                'Biometric Login',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Use fingerprint/face ID to sign in',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              activeColor: AppColors.primaryBlue,
              activeTrackColor: AppColors.primaryBlue.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
          ]);
        }

        // Subscription is always visible
        settingItems.add(
          _buildSettingItem(
            'Subscription',
            'Manage your subscription plan',
            Icons.card_membership_outlined,
            () => _showSubscriptionPage(),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(settingItems),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundCard, AppColors.backgroundSurface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          final index = items.indexOf(item);
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Divider(color: AppColors.backgroundSurface, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
  }

  void _showChangePasswordPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
  }

  void _showSubscriptionPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SubscriptionPage()));
  }
}
