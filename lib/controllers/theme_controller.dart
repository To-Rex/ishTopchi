import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_theme.dart';

/// ThemeController - Manages app theme state with GetX
/// Handles theme switching, persistence, and provides reactive theme updates
class ThemeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Observable theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  // Observable boolean for easier access
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  /// Load saved theme preference from storage
  void _loadThemePreference() {
    final savedTheme = _storage.read('theme_mode');
    if (savedTheme != null) {
      if (savedTheme == 'light') {
        setThemeMode(ThemeMode.light);
      } else {
        setThemeMode(ThemeMode.dark);
      }
    } else {
      // Default to dark mode
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Set theme mode and save to storage
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    isDarkMode.value = mode == ThemeMode.dark;

    // Save preference to storage
    _storage.write('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');

    // Update app theme
    Get.changeThemeMode(mode);
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = isDarkMode.value ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  /// Get current theme data based on theme mode
  ThemeData get currentTheme {
    return isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  /// Get light theme data
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// Get dark theme data
  ThemeData get darkTheme => AppTheme.darkTheme;
}
