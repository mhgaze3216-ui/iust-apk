import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme controller managing application-wide Light / Dark mode.
///
/// Follows a lightweight ValueNotifier pattern with SharedPreferences persistence.
/// All main application roles (Student, Doctor, Admin, Staff, Guest) share this
/// single global controller.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _prefKey = 'iust_global_theme_mode';

  /// ValueNotifier holding the current global [ThemeMode].
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Current [ThemeMode].
  ThemeMode get themeMode => themeModeNotifier.value;

  /// True if currently in dark mode.
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  /// Initializes the saved theme mode from persistent storage.
  /// Defaults to [ThemeMode.light] if no preference is saved.
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {
      // Safe fallback to light mode on error or during tests
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  /// Toggles between Light and Dark mode globally.
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Sets the global [ThemeMode] and persists the selection.
  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Ignore persistence errors in headless test environments
    }
  }
}
