import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            'Bildirishnomalar'.tr,
            style: TextStyle(color: AppColors.textColor, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: AppColors.textColor),
            onPressed: () => Get.back(),
          ),
          elevation: 0,
        ),
        body: Obx(
          () =>
              controller.notifications.isEmpty
                  ? Center(
                    child: Text(
                      'Hech qanday bildirishnoma yo‘q'.tr,
                      style: TextStyle(color: AppColors.textSecondaryColor),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return Card(
                        color: AppColors.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                notification.isRead
                                    ? AppColors.dividerColor
                                    : AppColors.secondaryColor.withOpacity(0.3),
                            radius: 20,
                            child: Icon(
                              LucideIcons.bell,
                              color: AppColors.textColor,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            notification.description,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            notification.time,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor.withOpacity(
                                0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            if (!notification.isRead) {
                              controller.markAsRead(index);
                            }
                          },
                        ),
                      );
                    },
                  ),
        ),
      );
    });
  }
}

class Notification {
  final String title;
  final String description;
  final String time;
  bool isRead;

  Notification({
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}
