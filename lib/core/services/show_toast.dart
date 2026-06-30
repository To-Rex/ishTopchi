import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/config/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShowToast {
  static void show(
    String title,
    String message,
    int status,
    int position, {
    int duration = 2,
    IconData icon = LucideIcons.info,
  }) {
    Future.delayed(const Duration(milliseconds: 150), () {
      try {
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
          mainButton: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => Get.back(),
            child: const Icon(LucideIcons.x, color: AppColors.white, size: 20),
          ),
          snackPosition:
              position == 1 ? SnackPosition.BOTTOM : SnackPosition.TOP,
          backgroundColor: status == 1
              ? AppColors.darkBlue
              : status == 2
                  ? AppColors.darkNavy
                  : AppColors.red,
          colorText: AppColors.white,
        );
      } catch (_) {
        final ctx = Get.context;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: AppColors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: status == 1
                  ? AppColors.darkBlue
                  : status == 2
                      ? AppColors.darkNavy
                      : AppColors.red,
              duration: Duration(seconds: duration),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              action: SnackBarAction(
                label: '',
                textColor: AppColors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    });
  }
}
