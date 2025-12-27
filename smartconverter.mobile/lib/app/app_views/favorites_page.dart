import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_constants/app_colors.dart';
import '../app_services/favorites_provider.dart';
import 'category_tools_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
          'My Favorites',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildFavoritesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.favorite, color: AppColors.primaryBlue, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Bookmarked Tools',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quickly access your most used conversion tools.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildFavoritesList() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No favorites yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any tool\nto add it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: provider.favorites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tool = provider.favorites[index];
            final icon = IconData(
              tool.iconCodePoint,
              fontFamily: tool.iconFontFamily,
            );

            return _buildFavoriteItem(context, tool, icon, provider);
          },
        ).animate().fadeIn().slideY(begin: 0.1);
      },
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    FavoriteTool tool,
    IconData icon,
    FavoritesProvider provider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () {
          // Navigation to tool action page requires the mapping logic from CategoryToolsPage
          // For now, we will use a workaround or move the mapping logic
          // Actually, we can navigate to CategoryToolsPage context if needed, 
          // but better to jump directly.
          _navigateToTool(context, tool, icon);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        title: Text(
          tool.toolName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tool.categoryId.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.primaryBlue, size: 22),
              onPressed: () => provider.toggleFavorite(
                categoryId: tool.categoryId,
                toolName: tool.toolName,
                categoryIcon: icon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTool(BuildContext context, FavoriteTool tool, IconData icon) {
    final page = CategoryToolsPage.resolveToolPage(
      context,
      tool.categoryId,
      tool.toolName,
      icon,
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
