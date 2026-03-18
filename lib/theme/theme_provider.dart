import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/theme/dark_mode.dart';

import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Initially, light mode
  ThemeData _themeData = lightMode;

  // Get current theme
  ThemeData get themeData => _themeData;

  // Is current theme dark mode
  bool get isDarkMode => _themeData == darkMode;

  // Toggle theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners(); // Notify listeners after changing the theme
  }
}
