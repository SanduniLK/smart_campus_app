import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? staffType;
  final bool isEmailVerified;
  final String? phone;
  final String? department;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  
  // Student specific
  final String? indexNumber;
  final String? campusId;
  final String? nic;
  final String? dob;
  final String? degree;
  final String? intake;
  
  // Staff specific
  final String? staffId;
  final String? faculty;
  final String? designation;
  final String? officeLocation;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.staffType,
    this.isEmailVerified = false,
    this.phone,
    this.department,
    this.createdAt,
    this.lastLogin,
    this.indexNumber,
    this.campusId,
    this.nic,
    this.dob,
    this.degree,
    this.intake,
    this.staffId,
    this.faculty,
    this.designation,
    this.officeLocation,
  });

  bool get isStudent => role == 'student';
  bool get isStaff => role == 'staff';
  bool get isAcademicStaff => role == 'staff' && staffType == 'academic';
  bool get isNonAcademicStaff => role == 'staff' && staffType == 'non_academic';

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'staffType': staffType,
      'isEmailVerified': isEmailVerified ? 1 : 0,
      'phone': phone,
      'department': department,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'indexNumber': indexNumber,
      'campusId': campusId,
      'nic': nic,
      'dob': dob,
      'degree': degree,
      'intake': intake,
      'staffId': staffId,
      'faculty': faculty,
      'designation': designation,
      'officeLocation': officeLocation,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'student',
      staffType: map['staffType'],
      isEmailVerified: map['isEmailVerified'] == 1,
      phone: map['phone'],
      department: map['department'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      lastLogin: map['lastLogin'] != null ? DateTime.tryParse(map['lastLogin']) : null,
      indexNumber: map['indexNumber'],
      campusId: map['campusId'],
      nic: map['nic'],
      dob: map['dob'],
      degree: map['degree'],
      intake: map['intake'],
      staffId: map['staffId'],
      faculty: map['faculty'],
      designation: map['designation'],
      officeLocation: map['officeLocation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'staffType': staffType,
      'isEmailVerified': isEmailVerified,
      'phone': phone,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'indexNumber': indexNumber,
      'campusId': campusId,
      'nic': nic,
      'dob': dob,
      'degree': degree,
      'intake': intake,
      'staffId': staffId,
      'faculty': faculty,
      'designation': designation,
      'officeLocation': officeLocation,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'student',
      staffType: data['staffType'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      phone: data['phone'],
      department: data['department'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      indexNumber: data['indexNumber'],
      campusId: data['campusId'],
      nic: data['nic'],
      dob: data['dob'],
      degree: data['degree'],
      intake: data['intake'],
      staffId: data['staffId'],
      faculty: data['faculty'],
      designation: data['designation'],
      officeLocation: data['officeLocation'],
    );
  }
}