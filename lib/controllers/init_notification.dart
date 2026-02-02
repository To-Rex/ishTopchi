/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'funcController.dart';
import 'package:get/get.dart';

// Create a channel for Android notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class InitNotification {
  static Future<void> initialize() async {
    // Firebase is already initialized in main.dart, don't initialize again
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final FuncController funcController = Get.put(FuncController());

    // Initialize Android notification channel
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default',
      'Default Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    funcController.fcmToken.value = fcmToken!;
    print('\n');
    print('═' * 80);
    print('🔑 FCM TOKEN REGISTERED 🔑');
    print('═' * 80);
    print('Token: $fcmToken');
    print('═' * 80);
    print('\n');

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Notification received while app is in FOREGROUND');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Show local notification when in foreground
      _showLocalNotification(message);
    });

    // Handle messages when the app is in the background and user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 Notification opened while app was in BACKGROUND');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    // Handle initial messages when the app is opened from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('📩 Notification opened from TERMINATED state');
      print('Message ID: ${initialMessage.messageId}');
      print('Title: ${initialMessage.notification?.title}');
      print('Body: ${initialMessage.notification?.body}');
      print('Data: ${initialMessage.data}');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default',
      'Default Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  static void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    print('Local Notification Received: $title - $body');
  }
}
*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hicom_patners/controllers/get_controller.dart';
import '../firebase_options.dart';

class InitNotification {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final List<String> _topics = ['HicomPartner_C1', 'HicomPartner_R12', 'HicomPartner_D3', 'HicomPartner_U2', 'HicomPartner'];
  static bool _isInitialized = false;

  // Asosiy sozlash funksiyasi
  static Future<void> initialize() async {
    if (_isInitialized || !GetController().getNotification()) {
      return;
    }
    _isInitialized = true;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $fcmToken');
      GetController().saveFcmToken(fcmToken ?? '');
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Xabarnoma orqali ochilgan: ${message.messageId}');
      });

      await _configureNotificationChannels();
    } catch (e) {
      debugPrint('Xabarlarni sozlashda xatolik: $e');
    }
  }

  // Mavzular bo'yicha obuna bo'lish
  static Future<void> subscribeToTopics() async {
    for (var topic in _topics) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        debugPrint('Mavzuga obuna bo\'lindi: $topic');
      } catch (e) {
        debugPrint('Mavzuga obuna bo\'lishda xatolik: $topic. Xato: $e');
      }
    }
  }

  // Mahalliy xabarnomalarni sozlash
  static Future<void> _configureNotificationChannels() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fondagi xabarlarni qayta ishlash
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Fondagi xabarni qayta ishlash: ${message.messageId}');
    GetController().saveNotificationMessage(
      message.data['title'] ?? 'Hicom Partner',
      message.notification?.body ?? message.data['body'] ?? '',
    );
    _showNotification(message);
  }

  // Xabarlarni ko'rsatish
  static Future<void> _showNotification(RemoteMessage message) async {
    final notificationDetails = _getNotificationDetails();
    final title = message.data['title'] ?? 'Hicom Partner';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: 'item x');
  }

  // Xabarnoma sozlamalari
  static NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    return const NotificationDetails(android: androidDetails);
  }
}
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../firebase_options.dart';
import 'package:get/get.dart';
import 'funcController.dart';

class InitNotification {
  static bool _isInitialized = false;

  // Asosiy sozlash funksiyasi
  static Future<void> initialize() async {
    final FuncController funcController = Get.put(FuncController());
    if (_isInitialized) {
      print('Notification already initialized, skipping...');
      return;
    }
    _isInitialized = true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final fcmToken = await FirebaseMessaging.instance.getToken();
      funcController.fcmToken.value = fcmToken!;
      debugPrint('========================================');
      debugPrint('📱 FCM Token: $fcmToken');
      debugPrint('========================================');

      await FirebaseMessaging.instance.requestPermission();

      // Local notificationni o'chirish - faqat terminalda chiqarish
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );


      // Terminated state'dan ochilganda
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _printNotificationDetails(initialMessage, 'TERMINATED');
      }

      // Background'dan ochilganda
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _printNotificationDetails(message, 'BACKGROUND OPENED');
      });

      // Foreground'da kelganda
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _printNotificationDetails(message, 'FOREGROUND');
      });
    } catch (e) {
      debugPrint('❌ Xabarlarni sozlashda xatolik: $e');
    }
  }

  // Xabarnoma ma'lumotlarini terminalga chiqarish
  static void _printNotificationDetails(RemoteMessage message, String state) {
    debugPrint('\n');
    debugPrint('========================================');
    debugPrint('📩 NOTIFICATION RECEIVED [$state]');
    debugPrint('========================================');
    debugPrint('🆔 Message ID: ${message.messageId}');
    debugPrint('📨 Sent Time: ${message.sentTime}');
    debugPrint('📅 TTL: ${message.ttl}');
    debugPrint('📦 Collapse Key: ${message.collapseKey}');
    debugPrint('📋 From: ${message.from}');
    debugPrint('🏷️ Category: ${message.category}');

    debugPrint('\n--- NOTIFICATION CONTENT ---');
    if (message.notification != null) {
      debugPrint('📌 Title: ${message.notification!.title}');
      debugPrint('📝 Body: ${message.notification!.body}');
      debugPrint(
        '🔔 Android Channel ID: ${message.notification!.android?.channelId}',
      );
      debugPrint(
        '🔔 Android Click Action: ${message.notification!.android?.clickAction}',
      );
      debugPrint('🔔 Android Color: ${message.notification!.android?.color}');
      debugPrint('🔔 Android Count: ${message.notification!.android?.count}');
      debugPrint(
        '🔔 Android Image URL: ${message.notification!.android?.imageUrl}',
      );
      debugPrint('🔔 Android Link: ${message.notification!.android?.link}');
      debugPrint(
        '🔔 Android Priority: ${message.notification!.android?.priority}',
      );
      debugPrint(
        '🔔 Android Small Icon: ${message.notification!.android?.smallIcon}',
      );
      debugPrint('🔔 Android Sound: ${message.notification!.android?.sound}');
      debugPrint('🔔 Android Ticker: ${message.notification!.android?.ticker}');
      debugPrint(
        '🔔 Android Visibility: ${message.notification!.android?.visibility}',
      );
      debugPrint('🍎 Apple Badge: ${message.notification!.apple?.badge}');
      debugPrint('🍎 Apple Sound: ${message.notification!.apple?.sound}');
      debugPrint('🍎 Apple Subtitle: ${message.notification!.apple?.subtitle}');
    } else {
      debugPrint('⚠️ Notification content is null');
    }

    debugPrint('\n--- DATA PAYLOAD ---');
    if (message.data.isNotEmpty) {
      message.data.forEach((key, value) {
        debugPrint('🔑 $key: $value');
      });
    } else {
      debugPrint('⚠️ Data payload is empty');
    }

    debugPrint('========================================\n');
  }
}
