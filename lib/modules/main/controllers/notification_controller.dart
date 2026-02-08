import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../controllers/api_controller.dart';
import '../views/notifications_screen.dart';

class NotificationController extends GetxController {
  final RxList<Notification> notifications = <Notification>[].obs;
  final ApiController apiController = Get.find<ApiController>();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await apiController.fetchNotifications();
      if (response != null) {
        notifications.clear();
        for (var notificationModel in response.data) {
          debugPrint(
            'Notification from API: id=${notificationModel.id}, isRead=${notificationModel.isRead}',
          );
          final notification = Notification(
            id: notificationModel.id,
            title: notificationModel.title,
            description: notificationModel.body,
            time: _formatDateTime(notificationModel.createdAt),
            isRead: notificationModel.isRead,
          );
          debugPrint(
            'Notification created: title=${notification.title}, isRead=${notification.isRead}',
          );
          notifications.add(notification);
        }
      }
    } catch (e) {
      debugPrint('fetchNotifications xatolik: $e');
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'hozir'.tr;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${'daqiqa oldin'.tr}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${'soat oldin'.tr}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${'kun oldin'.tr}';
      } else {
        return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      if (!notification.isRead) {
        final success = await apiController.markNotificationAsRead(
          notification.id,
        );
        if (success) {
          notifications[index] = notification.copyWith(isRead: true);
          debugPrint('Notification ${notification.id} marked as read');
        } else {
          debugPrint('Failed to mark notification ${notification.id} as read');
        }
      }
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> markAllAsRead() async {
    final success = await apiController.markAllNotificationsAsRead();
    if (success) {
      // Update all notifications locally to read
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      debugPrint('All notifications marked as read');
    } else {
      debugPrint('Failed to mark all notifications as read');
    }
  }
}

// Extension Notification uchun copyWith (o'zgartirish uchun)
extension NotificationExtension on Notification {
  Notification copyWith({
    int? id,
    String? title,
    String? description,
    String? time,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
