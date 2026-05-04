// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FCMService _fcmService = FCMService();

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications - FIXED
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initializationSettings);

    // Subscribe to topic
    await _fcm.subscribeToTopic('announcements');
    debugPrint('✅ Subscribed to announcements topic');

    // Get FCM token
    final token = await _fcm.getToken();
    debugPrint('📱 Device token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle when user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped notification');
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    // Create notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'announcement_channel',
      'Announcements',
      channelDescription: 'University announcements',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification - FIXED: using correct named parameters
    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Announcement',
      message.notification?.body ?? '',
      details,
    );
  }

  // Send notification using service account
  Future<void> sendAnnouncementNotification(String title, String body, String priority) async {
    await _fcmService.sendNotification(
      title: title,
      body: body,
      priority: priority,
    );
  }
}