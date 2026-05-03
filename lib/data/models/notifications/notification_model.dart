// lib/data/models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // urgent, announcement, event
  final String targetAudience;
  final DateTime sentAt;
  final String sentBy;
  final String sentByName;
  final bool isRead;
  final String? announcementId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetAudience,
    required this.sentAt,
    required this.sentBy,
    required this.sentByName,
    this.isRead = false,
    this.announcementId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'targetAudience': targetAudience,
      'sentAt': sentAt.toIso8601String(),
      'sentBy': sentBy,
      'sentByName': sentByName,
      'isRead': isRead,
      'announcementId': announcementId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: map['type'],
      targetAudience: map['targetAudience'],
      sentAt: DateTime.parse(map['sentAt']),
      sentBy: map['sentBy'],
      sentByName: map['sentByName'],
      isRead: map['isRead'],
      announcementId: map['announcementId'],
    );
  }
}