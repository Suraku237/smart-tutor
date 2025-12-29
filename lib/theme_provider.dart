import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Initial state is Light Mode
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // This triggers the app to rebuild with new colors
  }
}