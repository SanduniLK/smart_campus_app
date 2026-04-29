// lib/data/repositories/auth_repository.dart
import 'package:smart_campus_app/core/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  // ==================== SIGN IN ====================
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase
      final user = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user == null) return null;
      
      // Refresh verification status from Firebase
      final isVerified = await _firebaseService.refreshUserVerificationStatus();
      
      // Get user data from SQLite
      final userData = await _firebaseService.getCurrentUserData();
      
      if (userData != null) {
        return UserModel(
          id: userData['uid'] ?? '',
          email: userData['email'] ?? '',
          fullName: userData['fullName'] ?? '',
          role: userData['role'] ?? 'student',
          staffType: userData['staffType'],
          isEmailVerified: isVerified,
          phone: userData['phone'],
          department: userData['department'],
          indexNumber: userData['indexNumber'],
          campusId: userData['campusId'],
        );
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== STUDENT SIGN UP ====================
  Future<UserModel?> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String indexNumber,
    required String campusId,
    required String nic,
    required String phone,
    required String dob,
    required String department,
    required String degree,
    required String intake,
  }) async {
    try {
      final user = await _firebaseService.signUpStudent(
        email: email,
        password: password,
        fullName: fullName,
        indexNumber: indexNumber,
        campusId: campusId,
        nic: nic,
        phone: phone,
        dob: dob,
        department: department,
        degree: degree,
        intake: intake,
      );
      
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: email,
          fullName: fullName,
          role: 'student',
          isEmailVerified: false,
          phone: phone,
          department: department,
          indexNumber: indexNumber,
          campusId: campusId,
        );
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== STAFF SIGN UP ====================
  Future<UserModel?> signUpStaff({
    required String email,
    required String password,
    required String fullName,
    required String staffId,
    required String faculty,
    required String department,
  }) async {
    try {
      final user = await _firebaseService.signUpStaff(
        email: email,
        password: password,
        fullName: fullName,
        staffId: staffId,
        faculty: faculty,
        department: department,
      );
      
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: email,
          fullName: fullName,
          role: 'staff',
          staffType: 'academic',
          isEmailVerified: false,
          department: department,
        );
      }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== REFRESH EMAIL VERIFICATION ====================
  Future<bool> refreshEmailVerificationStatus() async {
    return await _firebaseService.refreshUserVerificationStatus();
  }

  // ==================== SEND EMAIL VERIFICATION ====================
  Future<void> sendEmailVerification() async {
    await _firebaseService.sendEmailVerification();
  }

  // ==================== SIGN OUT ====================
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  // ==================== GET CURRENT USER ====================
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await _firebaseService.getCurrentUserData();
      if (userData != null) {
        return UserModel(
          id: userData['uid'] ?? '',
          email: userData['email'] ?? '',
          fullName: userData['fullName'] ?? '',
          role: userData['role'] ?? 'student',
          staffType: userData['staffType'],
          isEmailVerified: userData['isEmailVerified'] == 1,
          phone: userData['phone'],
          department: userData['department'],
          indexNumber: userData['indexNumber'],
          campusId: userData['campusId'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}