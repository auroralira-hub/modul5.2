import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ThemeController themeController;

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  final SharedPreferences _prefs;
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    unawaited(_prefs.setBool(_themeKey, value));
    notifyListeners();
  }

  void toggleTheme() => setDarkMode(!_isDarkMode);
}
