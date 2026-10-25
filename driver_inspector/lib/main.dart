import 'package:flutter/material.dart';
import 'services/app_settings.dart';
import 'theme/app_theme.dart';
import 'screens/driver_login_screen.dart';
import 'screens/driver_register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/driver_main_nav.dart';
import 'screens/inspector_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsController.instance.init();
  runApp(const DriverInspectorApp());
}

class DriverInspectorApp extends StatelessWidget {
  const DriverInspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'SecureTrack SL - Driver & Inspector',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const DriverLoginScreen(),
          routes: {
            '/login': (context) => const DriverLoginScreen(),
            '/register': (context) => const DriverRegisterScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/driver-home': (context) => const DriverMainNav(),
            '/inspector-home': (context) => const InspectorDashboardScreen(),
          },
        );
      },
    );
  }
}
