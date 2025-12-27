import 'package:flutter/material.dart';
import '../app_constants/app_colors.dart';
import 'home_page.dart';
import 'tools_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../app_widgets/drawer_menu_widget.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static MainNavigationState of(BuildContext context) {
    final state = context.findAncestorStateOfType<MainNavigationState>();
    if (state == null) {
      throw Exception('MainNavigationState not found in context');
    }
    return state;
  }

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  late List<Widget> _pages;

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ToolsPage(),
      const ProfilePage(),
      const HistoryPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: const DrawerMenuWidget(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: IndexedStack(index: selectedIndex, children: _pages),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = 'Smart Converter';
    IconData titleIcon = Icons.auto_awesome;
    LinearGradient iconGradient = AppColors.primaryGradient;

    switch (selectedIndex) {
      case 0:
        title = 'Smart Converter';
        titleIcon = Icons.auto_awesome;
        iconGradient = AppColors.primaryGradient;
        break;
      case 1:
        title = 'All Tools';
        titleIcon = Icons.build_outlined;
        iconGradient = AppColors.primaryGradient;
        break;
      case 2:
        title = 'Profile';
        titleIcon = Icons.person;
        iconGradient = AppColors.primaryGradient;
        break;
      case 3:
        title = 'History';
        titleIcon = Icons.history;
        iconGradient = AppColors.secondaryGradient;
        break;
      case 4:
        title = 'Settings';
        titleIcon = Icons.settings;
        iconGradient = AppColors.secondaryGradient;
        break;
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 50,
      leading: Builder(
        builder: (context) => Container(
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
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (selectedIndex == 0) {
      return [
        Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ),
      ];
    }
    return [];
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
