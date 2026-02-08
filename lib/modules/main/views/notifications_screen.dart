import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          actions: [
            Obx(
              () =>
                  controller.notifications.any((n) => !n.isRead)
                      ? IconButton(
                        icon: Icon(
                          LucideIcons.checkCheck,
                          color: AppColors.secondaryColor,
                        ),
                        onPressed: () async {
                          await controller.markAllAsRead();
                        },
                        tooltip: 'Barchasini o\'qilgan deb belgilash'.tr,
                      )
                      : const SizedBox.shrink(),
            ),
          ],
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
                  : RefreshIndicator(
                    onRefresh: () => controller.refreshNotifications(),
                    color: AppColors.secondaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return Card(
                          color: AppColors.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  notification.isRead
                                      ? Colors.transparent
                                      : AppColors.secondaryColor,
                              width: 1,
                            ),
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
                                      : AppColors.secondaryColor.withValues(
                                        alpha: 0.3,
                                      ),
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
                                color: AppColors.textSecondaryColor.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              if (!notification.isRead) {
                                await controller.markAsRead(index);
                              }
                              _showNotificationBottomSheet(notification);
                            },
                          ),
                        );
                      },
                    ),
                  ),
        ),
      );
    });
  }

  void _showNotificationBottomSheet(Notification notification) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification.isRead ? 'O‘qilgan'.tr : 'O‘qilmagan'.tr,
                  style: TextStyle(
                    color:
                        notification.isRead
                            ? AppColors.textSecondaryColor
                            : AppColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: AppColors.textColor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              notification.title,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              notification.description,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  color: AppColors.textSecondaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  notification.time,
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.black54,
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }
}

class Notification {
  final int id;
  final String title;
  final String description;
  final String time;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}
