import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../firebase_options.dart';
import 'dart:convert';


class InitNotification {
  static bool _isInitialized = false;

  // Asosiy sozlash funksiyasi
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final FuncController funcController = Get.put(FuncController());
    if (_isInitialized) {  // GetController tekshiruvini qo'shish mumkin, lekin majburiy emas
      print('Xabarlar allaqachon sozlangan.');
      return;
    }
    _isInitialized = true;
    try {
      // FCM token olish va saqlash
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $fcmToken');
      funcController.fcmToken.value = fcmToken ?? '';
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _setupForegroundHandlers();

    } catch (e) {
      debugPrint('Xabarlarni sozlashda xatolik: $e');
    }
  }

  // Foreground handler'larni sozlash
  static void _setupForegroundHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground xabarni qayta ishlash: ${message.messageId}');
      print('Qabul qilingan xabar: ${message.notification?.title} - ${message.notification?.body}');
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Xabarnoma orqali ochilgan: ${message.messageId}');
      print('Xabarnoma orqali ochilgan xabar: ${message.notification?.title} - ${message.notification?.body}');
    });
  }



  // Fondagi xabarlarni qayta ishlash (background handler)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Fondagi xabarni qayta ishlash: ${message.messageId}');
    print('Fondagi xabar: ${message.notification?.title} - ${message.notification?.body}');
    _showNotification(message);
  }

  // Xabarlarni ko'rsatish
  static Future<void> _showNotification(RemoteMessage message) async {
    final title = message.data['title'] ?? 'Hicom Partner';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    debugPrint('Fondagi xabarni qayta ishlash: $title - $body');
    print('Ko\'rsatilayotgan xabar: $title - $body');
  }
}
