// lib/data/models/announcement/announcement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final String type;
  final String priority;
  final String targetAudience;
  final String createdBy;
  final String createdByRole;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final List<String> readBy;
  final Map<String, String>? reactions;

  // ✅ Add these getters
  bool get isUrgent => priority == 'urgent';
  bool get isHighPriority => priority == 'high';
  
  // Priority color getter
  Color get priorityColor {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  // Type icon getter
  IconData get typeIcon {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'deadline':
        return Icons.alarm;
      case 'academic':
        return Icons.school;
      case 'general':
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }
  
  // Audience label getter
  String get audienceLabel {
    switch (targetAudience) {
      case 'students':
        return '📚 Students Only';
      case 'academic_staff':
        return '👨‍🏫 Academic Staff Only';
      case 'non_academic_staff':
        return '👔 Non-Academic Staff Only';
      default:
        return '👥 Everyone';
    }
  }
  
  // Check if announcement is visible to a user role
  bool isVisibleTo(String userRole) {
    if (targetAudience == 'all') return true;
    if (targetAudience == 'students' && userRole == 'student') return true;
    if (targetAudience == 'academic_staff' && userRole == 'academic_staff') return true;
    if (targetAudience == 'non_academic_staff' && userRole == 'non_academic_staff') return true;
    return false;
  }

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.type = 'general',
    this.priority = 'normal',
    this.targetAudience = 'all',
    required this.createdBy,
    required this.createdByRole,
    required this.createdByName,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.readBy = const [],
    this.reactions,
  });

  factory Announcement.fromFirestore(Map<String, dynamic> data, String docId) {
    return Announcement(
      id: docId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'general',
      priority: data['priority'] ?? 'normal',
      targetAudience: data['targetAudience'] ?? 'all',
      createdBy: data['createdBy'] ?? '',
      createdByRole: data['createdByRole'] ?? '',
      createdByName: data['createdByName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      imageUrl: data['imageUrl'],
      readBy: List<String>.from(data['readBy'] ?? []),
      reactions: data['reactions'] != null 
          ? Map<String, String>.from(data['reactions']) 
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'priority': priority,
      'targetAudience': targetAudience,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdByName': createdByName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'readBy': readBy,
    };
  }
  
  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    String? priority,
    String? targetAudience,
    String? createdBy,
    String? createdByRole,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    List<String>? readBy,
    Map<String, String>? reactions,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetAudience: targetAudience ?? this.targetAudience,
      createdBy: createdBy ?? this.createdBy,
      createdByRole: createdByRole ?? this.createdByRole,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
    );
  }
}