// lib/core/services/fcm_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  String? _accessToken;
  DateTime? _tokenExpiry;
  AutoRefreshingAuthClient? _client;

  Future<Map<String, dynamic>> _loadServiceAccount() async {
    final String jsonString = await rootBundle.loadString('assets/firebase/service_account.json');
    return jsonDecode(jsonString);
  }

  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials = await _loadServiceAccount();
      
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentials),
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      _accessToken = client.credentials.accessToken.data;
      _tokenExpiry = DateTime.now().add(const Duration(seconds: 3600));
      _client = client;
      
      debugPrint('✅ FCM Access token obtained');
      return _accessToken!;
    } catch (e) {
      debugPrint('❌ Failed to get access token: $e');
      throw Exception('Failed to authenticate FCM service: $e');
    }
  }

  Future<bool> sendNotification({
  required String title,
  required String body,
  required String priority,
  String? imageUrl,
  Map<String, String>? data,
  String? topic,
}) async {
  try {
    debugPrint('📤 Preparing to send FCM notification...');
    debugPrint('   Title: $title');
    debugPrint('   Topic: ${topic ?? 'announcements'}');
    
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final message = {
      'message': {
        'topic': topic ?? 'announcements',
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'priority': priority == 'urgent' ? 'high' : 'normal',
        },
      },
    };

    debugPrint('📤 Sending to: $url');
    debugPrint('📤 Message: ${jsonEncode(message)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    debugPrint('📥 Response status: ${response.statusCode}');
    debugPrint('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      debugPrint('✅ Push notification sent successfully!');
      return true;
    } else {
      debugPrint('❌ Failed to send: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error sending notification: $e');
    return false;
  }
}

  Future<String> _getProjectId() async {
    final credentials = await _loadServiceAccount();
    return credentials['project_id'];
  }
 
Future<bool> sendToDevice({
  required String deviceToken,
  required String title,
  required String body,
  required String priority,
}) async {
  try {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'priority': priority == 'high' ? 'high' : 'normal',
        },
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Personal notification sent to device');
      return true;
    } else {
      debugPrint('❌ Failed to send: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
    return false;
  }
}
  void close() {
    _client?.close();
  }
}