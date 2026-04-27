// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'student' or 'staff'
  
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
  
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
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
    this.createdAt,
    this.lastLogin,
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
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
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Create from Map (for Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'student',
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
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }

  // For Firestore compatibility
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  // Helper to check if user is student
  bool get isStudent => role == 'student';
  
  // Helper to check if user is staff
  bool get isStaff => role == 'staff';
}