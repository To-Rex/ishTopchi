
import 'package:get/get.dart';

import '../views/notifications_screen.dart';

class NotificationController extends GetxController {
  final RxList<Notification> notifications = <Notification>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Masalan, sinov ma'lumotlari
    notifications.addAll([
      Notification(
        title: 'Yangi xabar',
        description: 'Sizga yangi xabar keldi, iltimos tekshiring!',
        time: '2025-06-29 16:00',
        isRead: false,
      ),
      Notification(
        title: 'Ilova yangilandi',
        description: 'Ishtopchi v1.1 chiqdi, yangiliklarni ko‘ring.',
        time: '2025-06-28 14:30',
        isRead: true,
      ),
    ]);
  }

  void markAsRead(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }
}

// Extension Notification uchun copyWith (o'zgartirish uchun)
extension NotificationExtension on Notification {
  Notification copyWith({String? title, String? description, String? time, bool? isRead}) {
    return Notification(
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}