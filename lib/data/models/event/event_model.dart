// lib/data/models/event/event_model.dart
import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final int? id;
  final String? firestoreId;
  final String title;
  final String description;
  final DateTime eventDate;
  final String? startTime;
  final String? endTime;
  final String location;
  final int capacity;
  final int registeredCount;
  final String status; // pending, approved, rejected
  final String createdBy;
  final String createdByRole;
  final String? createdByEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
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
    this.status = 'pending',
    required this.createdBy,
    required this.createdByRole,
    this.createdByEmail,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ ADD THIS copyWith METHOD
  Event copyWith({
    int? id,
    String? firestoreId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    int? capacity,
    int? registeredCount,
    String? status,
    String? createdBy,
    String? createdByRole,
    String? createdByEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdByRole: createdByRole ?? this.createdByRole,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map for database storage
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
      'status': status,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Map (database query result)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      firestoreId: map['firestoreId'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      eventDate: map['eventDate'] != null 
          ? DateTime.parse(map['eventDate'] as String) 
          : DateTime.now(),
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      location: map['location'] as String? ?? '',
      capacity: map['capacity'] as int? ?? 0,
      registeredCount: map['registeredCount'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdBy: map['createdBy'] as String? ?? '',
      createdByRole: map['createdByRole'] as String? ?? '',
      createdByEmail: map['createdByEmail'] as String?,
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'] as String) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.tryParse(map['updatedAt'] as String) 
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firestoreId': firestoreId,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore
  factory Event.fromFirestore(Map<String, dynamic> data, String docId) {
    return Event(
      firestoreId: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventDate: data['eventDate'] != null 
          ? DateTime.parse(data['eventDate']) 
          : DateTime.now(),
      startTime: data['startTime'],
      endTime: data['endTime'],
      location: data['location'] ?? '',
      capacity: data['capacity'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
      status: data['status'] ?? 'pending',
      createdBy: data['createdBy'] ?? '',
      createdByRole: data['createdByRole'] ?? '',
      createdByEmail: data['createdByEmail'],
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt']) 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? DateTime.tryParse(data['updatedAt']) 
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id, firestoreId, title, description, eventDate, 
    startTime, endTime, location, capacity, registeredCount, 
    status, createdBy, createdByRole, createdByEmail, createdAt, updatedAt
  ];
}