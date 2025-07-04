import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/config/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShowToast {
  static void show(String title, String message, int status, int position, {int duration = 2, IconData icon = LucideIcons.info}) {
    Get.snackbar(
        title,
        message,
        duration: Duration(seconds: duration),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(12),
        icon: Icon(icon, color: AppColors.white),
        borderRadius: 16,
        dismissDirection: DismissDirection.horizontal,
        animationDuration: const Duration(milliseconds: 600),
        mainButton: TextButton(style: TextButton.styleFrom(minimumSize: Size(32, 32), padding: EdgeInsets.zero), onPressed: () => Get.back(), child: Icon(LucideIcons.x, color: AppColors.white, size: 20)),
        snackPosition: position == 1 ? SnackPosition.BOTTOM : SnackPosition.TOP,
        backgroundColor: status == 1 ? AppColors.darkBlue : status == 2 ? AppColors.darkNavy : AppColors.red,
        colorText: AppColors.white
    );
  }
}