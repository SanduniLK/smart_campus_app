// lib/data/models/event/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final int? id;
  final String? firestoreId;  // ✅ ADD THIS
  final String title;
  final String description;
  final DateTime eventDate;
  final String? startTime;
  final String? endTime;
  final String location;
  final int capacity;
  final int registeredCount;
  final String? qrCode;
  final bool isActive;
  final String status;
  final String createdBy;
  final String createdByRole;
  final String? createdByEmail;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  Event({
    this.id,
    this.firestoreId,
    required this.title,
    required this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    required this.location,
    required this.capacity,
    this.registeredCount = 0,
    this.qrCode,
    this.isActive = true,
    this.status = 'pending',
    required this.createdBy,
    required this.createdByRole,
    this.createdByEmail,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.isSynced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'qrCode': qrCode,
      'isActive': isActive ? 1 : 0,
      'status': status,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdByEmail': createdByEmail,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ✅ ADD THIS METHOD
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'status': status,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdByEmail': createdByEmail,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      firestoreId: map['firestoreId'],
      title: map['title'],
      description: map['description'],
      eventDate: DateTime.parse(map['eventDate']),
      startTime: map['startTime'],
      endTime: map['endTime'],
      location: map['location'],
      capacity: map['capacity'],
      registeredCount: map['registeredCount'] ?? 0,
      qrCode: map['qrCode'],
      isActive: map['isActive'] == 1,
      status: map['status'] ?? 'pending',
      createdBy: map['createdBy'],
      createdByRole: map['createdByRole'],
      createdByEmail: map['createdByEmail'],
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      firestoreId: doc.id,
      title: data['title'],
      description: data['description'],
      eventDate: DateTime.parse(data['eventDate']),
      startTime: data['startTime'],
      endTime: data['endTime'],
      location: data['location'],
      capacity: data['capacity'],
      registeredCount: data['registeredCount'] ?? 0,
      status: data['status'] ?? 'pending',
      createdBy: data['createdBy'],
      createdByRole: data['createdByRole'],
      createdByEmail: data['createdByEmail'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}