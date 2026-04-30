// lib/data/models/time_table_model/course_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final int? id; // SQLite local ID
  final String? firestoreId; // Firestore document ID
  final String courseCode;
  final String courseName;
  final int credits;
  final String lecturerName;
  final String lecturerId; // Added - reference to staff
  final String batchYear;
  final String department;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final bool isDeleted;

  Course({
    this.id,
    this.firestoreId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.lecturerName,
    required this.lecturerId,
    required this.batchYear,
    required this.department,
    this.createdAt,
    this.updatedAt,
    this.isSynced = true,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'lecturerName': lecturerName,
      'lecturerId': lecturerId,
      'batchYear': batchYear,
      'department': department,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'lecturerName': lecturerName,
      'lecturerId': lecturerId,
      'batchYear': batchYear,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      firestoreId: map['firestoreId'],
      courseCode: map['courseCode'],
      courseName: map['courseName'],
      credits: map['credits'],
      lecturerName: map['lecturerName'],
      lecturerId: map['lecturerId'],
      batchYear: map['batchYear'],
      department: map['department'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      firestoreId: doc.id,
      courseCode: data['courseCode'],
      courseName: data['courseName'],
      credits: data['credits'],
      lecturerName: data['lecturerName'],
      lecturerId: data['lecturerId'],
      batchYear: data['batchYear'],
      department: data['department'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}