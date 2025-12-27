import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Subscription Plans',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Choose Your Journey',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryBlue.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Unlock premium features and higher limits',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 40),
                
                // Plans List
                _buildPlanCard(
                  context: context,
                  title: 'FREE',
                  price: '\$0',
                  subtitle: 'Perfect for casual use',
                  features: [
                    '5 Daily Conversions',
                    '50MB Max File Size',
                    'Basic Tools Access',
                    'Watch Ads for More Conversions',
                  ],
                  icon: Icons.flash_on_outlined,
                  color: AppColors.textTertiary,
                  index: 0,
                ),
                
                const SizedBox(height: 20),
                
                _buildPlanCard(
                  context: context,
                  title: 'MONTHLY',
                  price: '\$3',
                  period: '/month',
                  subtitle: 'Ideal for power users',
                  features: [
                    '100 Daily Conversions',
                    '200MB Max File Size',
                    'Ad-Free Experience',
                    'Priority Support',
                    'All Premium Tools',
                  ],
                  icon: Icons.auto_awesome_outlined,
                  color: AppColors.primaryBlue,
                  isPopular: true,
                  index: 1,
                ),
                
                const SizedBox(height: 20),
                
                _buildPlanCard(
                  context: context,
                  title: 'YEARLY',
                  price: '\$50',
                  period: '/year',
                  subtitle: 'Ultimate value & freedom',
                  features: [
                    'Unlimited Conversions',
                    'Unlimited File Size',
                    'Ad-Free Experience',
                    'VIP Priority Support',
                    'Full Cloud Integration',
                  ],
                  icon: Icons.workspace_premium_outlined,
                  color: AppColors.secondaryGreen,
                  index: 2,
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Payments are securely processed. Cancel anytime.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ).animate().fadeIn(delay: 1.seconds),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    String? period,
    required String subtitle,
    required List<String> features,
    required IconData icon,
    required Color color,
    bool isPopular = false,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? color : AppColors.primaryBlue.withOpacity(0.1),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (period != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6, left: 4),
                                child: Text(
                                  period,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.textTertiary, height: 1, thickness: 0.5),
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Implementation for plan selection
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected $title Plan'),
                        backgroundColor: color,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? color : Colors.transparent,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: color, width: 2),
                    ),
                    elevation: isPopular ? 8 : 0,
                    shadowColor: color.withOpacity(0.5),
                  ),
                  child: Text(
                    isPopular ? 'GET STARTED' : 'SELECT PLAN',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: (index * 200).ms).slideX(begin: 0.1);
  }
}
