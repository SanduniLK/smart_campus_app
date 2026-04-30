// lib/data/models/time_table_model/timetable_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableEntry {
  final int? id;
  final String? firestoreId;
  final String lecturerName;
  final String? lecturerId;
  final String level;
  final String semester;
  final String courseId;
  final String courseName;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String? building;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  TimetableEntry({
    this.id,
    this.firestoreId,
    required this.lecturerName,
    this.lecturerId,
    required this.level,
    required this.semester,
    required this.courseId,
    required this.courseName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    this.building,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isSynced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'lecturerName': lecturerName,
      'lecturerId': lecturerId,
      'level': level,
      'semester': semester,
      'courseId': courseId,
      'courseName': courseName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
      'building': building,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lecturerName': lecturerName,
      'lecturerId': lecturerId,
      'level': level,
      'semester': semester,
      'courseId': courseId,
      'courseName': courseName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
      'building': building,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      firestoreId: map['firestoreId'],
      lecturerName: map['lecturerName'],
      lecturerId: map['lecturerId'],
      level: map['level'],
      semester: map['semester'],
      courseId: map['courseId'],
      courseName: map['courseName'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      roomNumber: map['roomNumber'],
      building: map['building'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  factory TimetableEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimetableEntry(
      firestoreId: doc.id,
      lecturerName: data['lecturerName'],
      lecturerId: data['lecturerId'],
      level: data['level'],
      semester: data['semester'],
      courseId: data['courseId'],
      courseName: data['courseName'],
      dayOfWeek: data['dayOfWeek'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      roomNumber: data['roomNumber'],
      building: data['building'],
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
    );
  }
}