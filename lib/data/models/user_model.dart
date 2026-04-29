// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'student' or 'staff'
  final bool isEmailVerified; // ✅ ADD THIS FIELD
  
  // Student specific fields
  final String? indexNumber;
  final String? campusId;
  final String? nic;
  final String? phone;
  final String? dob;
  final String? department;
  final String? degree;
  final String? intake;
  
  // Staff specific fields
  final String? staffId;
  final String? faculty;
  final String? designation;
  final String? officeLocation;
  final String? staffType; // ✅ ADD THIS FIELD (academic/non_academic)
  
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isEmailVerified = false, // ✅ ADD WITH DEFAULT
    this.indexNumber,
    this.campusId,
    this.nic,
    this.phone,
    this.dob,
    this.department,
    this.degree,
    this.intake,
    this.staffId,
    this.faculty,
    this.designation,
    this.officeLocation,
    this.staffType, // ✅ ADD
    this.createdAt,
    this.lastLogin,
  });

  // Convert to Map (for SQLite/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'isEmailVerified': isEmailVerified ? 1 : 0, // ✅ ADD
      'indexNumber': indexNumber,
      'campusId': campusId,
      'nic': nic,
      'phone': phone,
      'dob': dob,
      'department': department,
      'degree': degree,
      'intake': intake,
      'staffId': staffId,
      'faculty': faculty,
      'designation': designation,
      'officeLocation': officeLocation,
      'staffType': staffType, // ✅ ADD
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Create from Map (for SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? map['uid'] ?? '', // Support both 'id' and 'uid'
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'student',
      isEmailVerified: map['isEmailVerified'] == 1, // ✅ ADD
      indexNumber: map['indexNumber'],
      campusId: map['campusId'],
      nic: map['nic'],
      phone: map['phone'],
      dob: map['dob'],
      department: map['department'],
      degree: map['degree'],
      intake: map['intake'],
      staffId: map['staffId'],
      faculty: map['faculty'],
      designation: map['designation'],
      officeLocation: map['officeLocation'],
      staffType: map['staffType'], // ✅ ADD
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      lastLogin: map['lastLogin'] != null ? DateTime.tryParse(map['lastLogin']) : null,
    );
  }

  // For Firestore compatibility
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'isEmailVerified': isEmailVerified, // ✅ ADD
      'indexNumber': indexNumber,
      'campusId': campusId,
      'nic': nic,
      'phone': phone,
      'dob': dob,
      'department': department,
      'degree': degree,
      'intake': intake,
      'staffId': staffId,
      'faculty': faculty,
      'designation': designation,
      'officeLocation': officeLocation,
      'staffType': staffType, // ✅ ADD
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'student',
      isEmailVerified: data['isEmailVerified'] ?? false, // ✅ ADD
      indexNumber: data['indexNumber'],
      campusId: data['campusId'],
      nic: data['nic'],
      phone: data['phone'],
      dob: data['dob'],
      department: data['department'],
      degree: data['degree'],
      intake: data['intake'],
      staffId: data['staffId'],
      faculty: data['faculty'],
      designation: data['designation'],
      officeLocation: data['officeLocation'],
      staffType: data['staffType'], // ✅ ADD
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  // Helper to check if user is student
  bool get isStudent => role == 'student';
  
  // Helper to check if user is staff
  bool get isStaff => role == 'staff';
  
  // Helper to check if user is academic staff
  bool get isAcademicStaff => role == 'staff' && staffType == 'academic';
  
  // Helper to check if user is non-academic staff
  bool get isNonAcademicStaff => role == 'staff' && staffType == 'non_academic';
}