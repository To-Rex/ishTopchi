import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: Text('Bildirishnomalar'.tr, style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => Get.back())
      ),
      body: Obx(() => controller.notifications.isEmpty ? Center(child: Text('Hech qanday bildirishnoma yo‘q'.tr, style: TextStyle(color: Colors.white70)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return Card(
            color: AppColors.darkBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: notification.isRead ? Colors.white10 : Colors.white24,
                radius: 20,
                child: const Icon(LucideIcons.bell, color: Colors.white, size: 18),
              ),
              title: Text(notification.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
              subtitle: Text(notification.description, style: TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Text(notification.time, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              onTap: () {
                if (!notification.isRead) {controller.markAsRead(index);}
              }
            )
          );
        }
      ))
    );
  }
}

class Notification {
  final String title;
  final String description;
  final String time;
  bool isRead;

  Notification({required this.title, required this.description, required this.time, this.isRead = false});
}