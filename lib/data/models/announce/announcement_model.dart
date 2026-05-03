// lib/data/models/announcement/announcement_model.dart
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
  final List<String> readBy;
  final Map<String, String>? reactions;

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
    this.readBy = const [],
    this.reactions,
  });

  // ✅ Getter for priority color
  Color get priorityColor {
    switch (priority) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'normal': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // ✅ Getter for type icon
  IconData get typeIcon {
    switch (type) {
      case 'academic': return Icons.school;
      case 'event': return Icons.event;
      case 'deadline': return Icons.alarm;
      default: return Icons.announcement;
    }
  }

  // ✅ Getter for audience label
  String get audienceLabel {
    switch (targetAudience) {
      case 'students': return '📚 Students Only';
      case 'academic_staff': return '👨‍🏫 Academic Staff Only';
      case 'non_academic_staff': return '👔 Non-Academic Staff Only';
      default: return '👥 Everyone';
    }
  }

  // ✅ Check if announcement is visible to a user role
  bool isVisibleTo(String userRole) {
    if (targetAudience == 'all') return true;
    if (targetAudience == 'students' && userRole == 'student') return true;
    if (targetAudience == 'academic_staff' && userRole == 'academic_staff') return true;
    if (targetAudience == 'non_academic_staff' && userRole == 'non_academic_staff') return true;
    return false;
  }

  // ✅ JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'priority': priority,
      'targetAudience': targetAudience,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'readBy': readBy,
      'reactions': reactions,
    };
  }

  // ✅ Factory method from JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'general',
      priority: json['priority'] ?? 'normal',
      targetAudience: json['targetAudience'] ?? 'all',
      createdBy: json['createdBy'] ?? '',
      createdByRole: json['createdByRole'] ?? '',
      createdByName: json['createdByName'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      reactions: json['reactions'] != null 
          ? Map<String, String>.from(json['reactions']) 
          : null,
    );
  }

  // ✅ Copy with method
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
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
    );
  }
}