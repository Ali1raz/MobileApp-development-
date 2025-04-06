import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  static const _isDarkModeKey = 'isDarkMode'; // Key for SharedPreferences

  ThemeNotifier() : super(_lightTheme) {
    _loadSavedTheme();
  }

  // Load saved theme preference
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    state = isDarkMode ? _darkTheme : _lightTheme;
  }

  // Toggle and save theme
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = state.brightness == Brightness.light;
    await prefs.setBool(_isDarkModeKey, isDarkMode);
    state = isDarkMode ? _darkTheme : _lightTheme;
  }


  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Lato',
    primarySwatch: Colors.blue,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Lato',
    primarySwatch: Colors.grey,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
    ),
  );
}
