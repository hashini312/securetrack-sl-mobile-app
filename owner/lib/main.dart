import 'package:flutter/material.dart';
import 'services/app_settings.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/owner_main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsController.instance.init();
  runApp(const OwnerApp());
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'SecureTrack SL - Container Owner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/role-selection': (context) => const RoleSelectionScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/owner-home': (context) => const OwnerMainNav(),
          },
        );
      },
    );
  }
}
