// lib/business_logic/auth_bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class AuthStudentSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String indexNumber;
  final String campusId;
  final String nic;
  final String phone;
  final String dob;
  final String department;
  final String degree;
  final String intake;
  final String level;              
  final String currentSemester; 

  const AuthStudentSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.indexNumber,
    required this.campusId,
    required this.nic,
    required this.phone,
    required this.dob,
    required this.department,
    required this.degree,
    required this.intake,
    required this.level,              
    required this.currentSemester, 
  });
  
  @override
  List<Object?> get props => [
    email, password, fullName, indexNumber, campusId, 
    nic, phone, dob, department, degree, intake,
    level, currentSemester  // ✅ FIXED: Added missing props
  ];
}

class AuthStaffSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String staffId;
  final String faculty;
  final String department;
  final String designation;        
  final String phone;               
  final String? officeLocation;     

  const AuthStaffSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.staffId,
    required this.faculty,
    required this.department,
    required this.designation,       
    required this.phone,            
    this.officeLocation,             
  });
  
  @override
  List<Object?> get props => [
    email, password, fullName, staffId, 
    faculty, department, designation, phone, officeLocation  
  ];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthEmailVerified extends AuthEvent {}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordRequested({required this.email});
  @override
  List<Object> get props => [email];
}