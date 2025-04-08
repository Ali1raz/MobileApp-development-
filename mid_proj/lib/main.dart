import 'package:flutter/material.dart';
import 'package:mid_proj/screens/home_screen.dart';
import 'package:mid_proj/screens/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String title = 'Multi';
  ThemeMode _themeMode = ThemeMode.light;

  void _updateThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/settings') {
          return MaterialPageRoute(
            builder:
                (context) => SettingsPage(
                  isDarkMode: _themeMode == ThemeMode.dark,
                  onDarkModeChanged: _updateThemeMode,
                ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => HomeScreen(title: title),
        );
      },
    );
  }
}
