import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class AppColors {
  // Dark theme colors
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color darkBlue = Color(0xFF1B263B);
  static const Color midBlue = Color(0xFF415A77);
  static const Color lightBlue = Color(0xFF778DA9);
  static const Color lightGray = Color(0xFFE0E1DD);
  static const Color white = Color(0xFFFFFFFF);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF415A77);
  static const Color lightSecondary = Color(0xFF778DA9);
  static const Color lightText = Color(0xFF2D3748);
  static const Color lightTextSecondary = Color(0xFF718096);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightShadow = Color(0x1A000000);

  // Common colors
  static const Color red = Color(0xFFE74C3C);
  static const Color selectedItem = Color(0xFFE74C3C); // Tanlangan uchun
  static const Color yellow = Color(0xFFFFD600);
  static const Color green = Color(0xFF2ECC71);

  // Theme-aware colors - automatically switch based on current theme
  static Color get backgroundColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkNavy : lightBackground;
    } catch (e) {
      return darkNavy; // Default to dark if controller not found
    }
  }

  static Color get surfaceColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkBlue : lightSurface;
    } catch (e) {
      return darkBlue; // Default to dark if controller not found
    }
  }

  static Color get primaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? midBlue : lightPrimary;
    } catch (e) {
      return midBlue; // Default to dark if controller not found
    }
  }

  static Color get secondaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightSecondary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }

  static Color get textColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightGray : lightText;
    } catch (e) {
      return lightGray; // Default to dark if controller not found
    }
  }

  static Color get textSecondaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightTextSecondary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }

  static Color get cardColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkBlue : lightCard;
    } catch (e) {
      return darkBlue; // Default to dark if controller not found
    }
  }

  static Color get dividerColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value
          ? lightBlue.withOpacity(0.3)
          : lightDivider;
    } catch (e) {
      return lightBlue.withOpacity(
        0.3,
      ); // Default to dark if controller not found
    }
  }

  static Color get shadowColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? Colors.black45 : lightShadow;
    } catch (e) {
      return Colors.black45; // Default to dark if controller not found
    }
  }

  static Color get iconColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightPrimary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }
}
