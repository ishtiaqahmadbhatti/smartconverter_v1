import '../app_modules/imports_module.dart';
import 'package:provider/provider.dart';
import '../app_providers/subscription_provider.dart';
import '../app_views/main_navigation.dart';

class DrawerMenuWidget extends StatefulWidget {
  const DrawerMenuWidget({super.key});

  @override
  State<DrawerMenuWidget> createState() => _DrawerMenuWidgetState();
}

class _DrawerMenuWidgetState extends State<DrawerMenuWidget> {
  bool _isCheckingHealth = false;
  String _healthStatus = '';
  Color _healthStatusColor = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).checkStatus();
    });
  }

  Future<void> _checkApiHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _healthStatus = 'Checking...';
      _healthStatusColor = AppColors.warning;
    });

    try {
      final conversionService = ConversionService();
      await conversionService.initialize();
      bool isHealthy = await conversionService.testConnection();

      setState(() {
        _isCheckingHealth = false;
        if (isHealthy) {
          _healthStatus = '✅ API is Online';
          _healthStatusColor = AppColors.success;
        } else {
          _healthStatus = '❌ API is Offline';
          _healthStatusColor = AppColors.error;
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingHealth = false;
        _healthStatus = '❌ Connection Failed';
        _healthStatusColor = AppColors.error;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog or just logout
    await AuthService.clearTokens();
    
    // Refresh state
    if (!mounted) return;
    await Provider.of<SubscriptionProvider>(context, listen: false).refresh();
    
    // Close drawer
    if (!mounted) return;
    Navigator.of(context).pop();
    
    // Navigate to Home
    try {
      MainNavigation.of(context).setSelectedIndex(0);
    } catch (e) {
      // Fallback if not in MainNavigation context structure
       Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundCard,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Consumer<SubscriptionProvider>(
                  builder: (context, subscription, _) {
                    if (!subscription.isGuest) return const SizedBox.shrink();
                    return Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.login,
                          title: 'Sign In',
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/signin');
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.person_add_alt,
                          title: 'Sign Up',
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/signup');
                          },
                        ),
                      ],
                    );
                  },
                ),
                const Divider(color: AppColors.textTertiary),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: AppStrings.dashboard,
                  onTap: () {
                    _closeDrawer(context);
                    MainNavigation.of(context).setSelectedIndex(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.folder_outlined,
                  title: AppStrings.myFiles,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyFilesPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_outlined,
                  title: AppStrings.conversionHistory,
                  onTap: () {
                    _closeDrawer(context);
                    MainNavigation.of(context).setSelectedIndex(3);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite_outline,
                  title: AppStrings.favorites,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    _closeDrawer(context);
                    MainNavigation.of(context).setSelectedIndex(4);
                  },
                ),
                const Divider(color: AppColors.textTertiary),
                _buildApiHealthItem(),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: AppStrings.help,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.privacy,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  title: AppStrings.terms,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsServicePage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: AppStrings.about,
                  onTap: () {
                    _closeDrawer(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        final isPremium = subscription.isPremium;
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subscription.userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  if (!subscription.isGuest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isPremium 
                            ? const LinearGradient(
                                colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.1)],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isPremium 
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                        border: isPremium 
                            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                            : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPremium) ...[
                             const Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                             const SizedBox(width: 4),
                          ],
                          Text(
                            isPremium ? 'PREMIUM' : 'FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPremium ? Colors.white : AppColors.textPrimary.withOpacity(0.7),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          onTap: onTap,
          hoverColor: AppColors.primaryBlue.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Divider(color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Consumer<SubscriptionProvider>(
                builder: (context, subscription, _) {
                  if (subscription.isGuest) return const SizedBox.shrink();
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text(AppStrings.logout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Version ${AppStrings.appVersion}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildApiHealthItem() {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isCheckingHealth ? Icons.refresh : Icons.api,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            title: const Text(
              'API Health Check',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: _healthStatus.isNotEmpty
                ? Text(
                    _healthStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: _healthStatusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const Text(
                    'Check API connection status',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
            trailing: _isCheckingHealth
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  )
                : Icon(
                    Icons.play_arrow,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
            onTap: _isCheckingHealth ? null : _checkApiHealth,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }
}
