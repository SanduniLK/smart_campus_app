// lib/core/services/announcement_rest_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_campus_app/core/services/notification_service.dart';

class AnnouncementRestApi {
  static const String projectId = 'noti-5e8b7';
  static const String baseUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
  
  // GET /announcements - Fetch all announcements
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements?orderBy=createdAt%20desc'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseDocuments(data['documents'] ?? []);
      }
      print('GET Error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('REST API Error: $e');
      return [];
    }
  }
  
  // POST /announcements - Create new announcement
  static Future<String?> createAnnouncement(Map<String, dynamic> announcement) async {
    try {
      // Fix the timestamp format - use UTC with Z
      final fixedAnnouncement = Map<String, dynamic>.from(announcement);
      if (fixedAnnouncement['createdAt'] is DateTime) {
        fixedAnnouncement['createdAt'] = (fixedAnnouncement['createdAt'] as DateTime).toUtc().toIso8601String().replaceAll('+00:00', 'Z');
      }
      
      final body = jsonEncode(_toFirestoreFormat(fixedAnnouncement));
      print('Request body: $body'); // For debugging
      
      final response = await http.post(
        Uri.parse('$baseUrl/announcements'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'].toString().split('/').last;
      }
      print('POST Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    } catch (e) {
      print('REST API Error: $e');
      return null;
    }
  }
  
  // GET /announcements/{id} - Fetch single announcement
  static Future<Map<String, dynamic>?> getAnnouncementById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['fields'] as Map<String, dynamic>? ?? {};
        return {
          'id': data['name'].toString().split('/').last,
          'title': fields['title']?['stringValue'] ?? '',
          'content': fields['content']?['stringValue'] ?? '',
          'type': fields['type']?['stringValue'] ?? 'general',
          'priority': fields['priority']?['stringValue'] ?? 'normal',
          'targetAudience': fields['targetAudience']?['stringValue'] ?? 'all',
          'createdBy': fields['createdBy']?['stringValue'] ?? '',
          'createdByRole': fields['createdByRole']?['stringValue'] ?? '',
          'createdByName': fields['createdByName']?['stringValue'] ?? '',
          'createdAt': fields['createdAt']?['timestampValue'] != null 
              ? DateTime.parse(fields['createdAt']['timestampValue']) 
              : DateTime.now(),
          'readBy': fields['readBy']?['arrayValue']?['values']?.map((v) => v['stringValue']).toList() ?? [],
        };
      }
      return null;
    } catch (e) {
      print('REST API Error: $e');
      return null;
    }
  }
  
  // PATCH /announcements/{id} - Update announcement (mark as read)
  static Future<bool> markAsRead(String id, String userId) async {
    try {
      // First get current announcement to get existing readBy list
      final getResponse = await http.get(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (getResponse.statusCode != 200) return false;
      
      final data = jsonDecode(getResponse.body);
      final fields = data['fields'] as Map<String, dynamic>? ?? {};
      final readByValues = fields['readBy']?['arrayValue']?['values'] as List? ?? [];
      final List<String> readBy = readByValues.map((v) => v['stringValue'] as String).toList();
      
      // Add user if not already in list
      if (!readBy.contains(userId)) {
        readBy.add(userId);
        
        // Prepare update body
        final updateBody = {
          'fields': {
            'readBy': {
              'arrayValue': {
                'values': readBy.map((id) => {'stringValue': id}).toList()
              }
            }
          }
        };
        
        final patchResponse = await http.patch(
          Uri.parse('$baseUrl/announcements/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateBody),
        );
        
        return patchResponse.statusCode == 200;
      }
      return true;
    } catch (e) {
      print('REST API Error in markAsRead: $e');
      return false;
    }
  }
  
  // PATCH /announcements/{id} - Update any field
  static Future<bool> updateAnnouncement(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_toFirestoreFormat(updates)),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('REST API Error: $e');
      return false;
    }
  }
  
  // DELETE /announcements/{id} - Delete announcement
  static Future<bool> deleteAnnouncement(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('REST API Error: $e');
      return false;
    }
  }
  
  // Helper: Convert to Firestore REST API format
  static Map<String, dynamic> _toFirestoreFormat(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    
    data.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': value};
      } else if (value is double) {
        fields[key] = {'doubleValue': value};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is DateTime) {
        // ✅ Fixed: Use correct timestamp format with 'Z'
        final timestamp = value.toUtc().toIso8601String().replaceAll('+00:00', 'Z');
        fields[key] = {'timestampValue': timestamp};
      } else if (value is List) {
        fields[key] = {
          'arrayValue': {
            'values': value.map((v) => {'stringValue': v.toString()}).toList()
          }
        };
      } else if (value is Map) {
        final nestedFields = <String, dynamic>{};
        value.forEach((k, v) {
          if (v is String) {
            nestedFields[k] = {'stringValue': v};
          }
        });
        fields[key] = {'mapValue': {'fields': nestedFields}};
      }
    });
    
    return {'fields': fields};
  }
  
  // Helper: Parse Firestore documents to Map
  static List<Map<String, dynamic>> _parseDocuments(List<dynamic> documents) {
    final List<Map<String, dynamic>> result = [];
    
    for (var doc in documents) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      final announcement = {
        'id': doc['name'].toString().split('/').last,
        'title': fields['title']?['stringValue'] ?? '',
        'content': fields['content']?['stringValue'] ?? '',
        'type': fields['type']?['stringValue'] ?? 'general',
        'priority': fields['priority']?['stringValue'] ?? 'normal',
        'targetAudience': fields['targetAudience']?['stringValue'] ?? 'all',
        'createdBy': fields['createdBy']?['stringValue'] ?? '',
        'createdByRole': fields['createdByRole']?['stringValue'] ?? '',
        'createdByName': fields['createdByName']?['stringValue'] ?? '',
        'createdAt': fields['createdAt']?['timestampValue'] != null 
            ? DateTime.parse(fields['createdAt']['timestampValue']) 
            : DateTime.now(),
        'readBy': fields['readBy']?['arrayValue']?['values']?.map((v) => v['stringValue']).toList() ?? [],
      };
      result.add(announcement);
    }
    
    return result;
  }
  
  // Helper: Add reaction to announcement
  static Future<bool> addReaction(String id, String userId, String reaction) async {
    try {
      final announcement = await getAnnouncementById(id);
      if (announcement == null) return false;
      
      Map<String, String> reactions = {};
      if (announcement['reactions'] != null) {
        reactions = Map<String, String>.from(announcement['reactions']);
      }
      reactions[userId] = reaction;
      
      final reactionsMap = <String, dynamic>{};
      reactions.forEach((k, v) {
        reactionsMap[k] = {'stringValue': v};
      });
      
      final updateBody = {
        'fields': {
          'reactions': {
            'mapValue': {'fields': reactionsMap}
          }
        }
      };
      
      final response = await http.patch(
        Uri.parse('$baseUrl/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateBody),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('REST API Error: $e');
      return false;
    }
  }
  static Future<void> sendPushNotificationForAnnouncement(String title, String content, String priority) async {
  try {
    final notificationService = NotificationService();
    await notificationService.sendAnnouncementNotification(title, content, priority);
  } catch (e) {
    print('Failed to send push: $e');
  }
}
}