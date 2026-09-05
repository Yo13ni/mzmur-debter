import 'package:flutter/material.dart';

class AppConfig extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Discrete font size levels matching settings UI: 0=small, 1=medium, 2=large
  int _fontSizeLevel = 1;
  int get fontSizeLevel => _fontSizeLevel;

  static const List<double> _scales = [0.85, 1.0, 1.25];
  double get fontSizeScale => _scales[_fontSizeLevel.clamp(0, 2)];

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDarkMode(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setFontSizeLevel(int level) {
    _fontSizeLevel = level.clamp(0, 2);
    notifyListeners();
  }

  void increaseFontSize() {
    if (_fontSizeLevel < 2) {
      _fontSizeLevel++;
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontSizeLevel > 0) {
      _fontSizeLevel--;
      notifyListeners();
    }
  }
}
