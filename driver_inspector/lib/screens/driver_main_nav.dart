import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_app_drawer.dart';
import 'driver_home_screen.dart';
import 'driver_navigation_screen.dart';
import 'driver_notifications_screen.dart';
import 'driver_trip_details_screen.dart';
import 'driver_profile_screen.dart';

class DriverMainNav extends StatefulWidget {
  const DriverMainNav({super.key});

  @override
  State<DriverMainNav> createState() => _DriverMainNavState();
}

class _DriverMainNavState extends State<DriverMainNav> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DriverHomeScreen(
        onNavigateTab: (index) {
          setState(() => _currentIndex = index);
        },
        onOpenDrawer: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      DriverNavigationScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
      DriverNotificationsScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
      DriverTripDetailsScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
      DriverProfileScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: DriverAppDrawer(
              currentIndex: _currentIndex,
              onSelectTab: (index) {
                setState(() => _currentIndex = index);
              },
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_filled),
                  label: settings.tr('dashboard'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.navigation_outlined),
                  activeIcon: const Icon(Icons.navigation),
                  label: settings.tr('tracking'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications_none_rounded),
                  activeIcon: const Icon(Icons.notifications_rounded),
                  label: settings.tr('alerts'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.description_outlined),
                  activeIcon: const Icon(Icons.description_rounded),
                  label: settings.tr('containers'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: settings.tr('profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
