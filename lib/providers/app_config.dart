// lib/providers/app_config.dart

import 'package:flutter/material.dart';

class AppConfig extends ChangeNotifier {
  // Use a default theme mode.
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Use a scaling factor for font size.
  double _fontSizeScale = 1.0;
  double get fontSizeScale => _fontSizeScale;

  // Define limits for font size scaling
  static const double _minFontSizeScale = 0.7;
  static const double _maxFontSizeScale = 2.0;

  // Toggle dark/light theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Set theme to system default
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  // Increase font size
  void increaseFontSize() {
    if (_fontSizeScale < _maxFontSizeScale) {
      _fontSizeScale += 0.1;
      notifyListeners();
    }
  }

  // Decrease font size
  void decreaseFontSize() {
    if (_fontSizeScale > _minFontSizeScale) {
      _fontSizeScale -= 0.1;
      notifyListeners();
    }
  }
}