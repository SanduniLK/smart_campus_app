// lib/core/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Initialize local notifications
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

    // Save token to Firestore for personal notifications
    await _saveTokenToFirestore(token);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle when user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped notification');
    });
  }

  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showLocalNotification(RemoteMessage message) {
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

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Announcement',
      message.notification?.body ?? '',
      details,
    );
  }

  // ✅ Send announcement notification to all users (topic)
  Future<void> sendAnnouncementNotification(String title, String body, String priority) async {
    await _fcmService.sendNotification(
      title: title,
      body: body,
      priority: priority,
    );
  }

  // ✅ Send personal notification to specific user (using their device token)
  Future<void> sendPersonalNotification({
    required String deviceToken,
    required String title,
    required String body,
    required String type,
  }) async {
    await _fcmService.sendToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      priority: type == 'urgent' ? 'high' : 'normal',
    );
  }

  // ✅ Send event registration confirmation
  Future<void> sendEventRegistrationNotification(
    String deviceToken,
    String eventName,
    String eventDate,
  ) async {
    await sendPersonalNotification(
      deviceToken: deviceToken,
      title: '✅ Registration Successful',
      body: 'You registered for "$eventName" on $eventDate',
      type: 'event_registration',
    );
  }

  // ✅ Send event reminder
  Future<void> sendEventReminderNotification(
    String deviceToken,
    String eventName,
    String startTime,
  ) async {
    await sendPersonalNotification(
      deviceToken: deviceToken,
      title: '⏰ Event Reminder',
      body: '"$eventName" starts in 1 hour at $startTime',
      type: 'event_reminder',
    );
  }
  Future<void> sendNewEventNotification(String eventName, String eventTime, String eventLocation) async {
  print('🔔 SENDING EVENT NOTIFICATION');
  print('   Event: $eventName');
  print('   Time: $eventTime');
  print('   Location: $eventLocation');
  
  final result = await _fcmService.sendNotification(
    title: '🎉 New Event Alert!',
    body: '$eventName • $eventTime • 📍 $eventLocation',
    priority: 'high',
  );
  
  print('📬 Send result: $result');
}
  // ✅ Send QR scan confirmation
  Future<void> sendScanConfirmationNotification(
    String deviceToken,
    String eventName,
  ) async {
    await sendPersonalNotification(
      deviceToken: deviceToken,
      title: '✅ Attendance Marked',
      body: 'Your attendance for "$eventName" has been recorded.',
      type: 'attendance',
    );
  }
  Future<void> sendEventApprovedNotification(
  String eventName, 
  String eventTime, 
  String eventLocation,
  String approverName,
) async {
  debugPrint('📢 Sending event approved notification: $eventName approved by $approverName');
  
  await _fcmService.sendNotification(
    title: '✅ Event Approved!',
    body: '"$eventName" on $eventTime at 📍 $eventLocation has been approved by $approverName',
    priority: 'high',
  );
}
Future<bool> sendToDevice({
  required String deviceToken,
  required String title,
  required String body,
  required String type,
}) async {
  try {
    final fcmService = FCMService();
    final result = await fcmService.sendToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      priority: type == 'event_approved_creator' ? 'high' : 'normal',
    );
    return result;
  } catch (e) {
    debugPrint('Error sending to device: $e');
    return false;
  }
}
}