import 'package:flutter/material.dart';
import 'package:mid_proj/features/multiplication/screens/home_screen.dart';
import 'package:mid_proj/features/settings/screens/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
} 