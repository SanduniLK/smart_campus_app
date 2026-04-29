// lib/data/repositories/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final userData = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
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
          nic: userData['nic'],
          dob: userData['dob'],
          degree: userData['degree'],
          intake: userData['intake'],
          staffId: userData['staffId'],
          faculty: userData['faculty'],
          designation: userData['designation'],
          officeLocation: userData['officeLocation'],
          createdAt: userData['createdAt'] != null ? DateTime.tryParse(userData['createdAt']) : null,
          lastLogin: userData['lastLogin'] != null ? DateTime.tryParse(userData['lastLogin']) : null,
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
          nic: nic,
          dob: dob,
          degree: degree,
          intake: intake,
          createdAt: DateTime.now(),
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
    String? staffType,
    String? designation,
    String? phone,
    String? officeLocation,
  }) async {
    try {
      final user = await _firebaseService.signUpStaff(
        email: email,
        password: password,
        fullName: fullName,
        staffId: staffId,
        faculty: faculty,
        department: department,
        staffType: staffType ?? 'academic',
      );
      
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: email,
          fullName: fullName,
          role: 'staff',
          staffType: staffType ?? 'academic',
          isEmailVerified: false,
          department: department,
          staffId: staffId,
          faculty: faculty,
          designation: designation,
          officeLocation: officeLocation,
          phone: phone,
          createdAt: DateTime.now(),
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

  // ==================== CHECK EMAIL VERIFIED ====================
  Future<bool> checkEmailVerified() async {
    return await _firebaseService.checkEmailVerified();
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
          nic: userData['nic'],
          dob: userData['dob'],
          degree: userData['degree'],
          intake: userData['intake'],
          staffId: userData['staffId'],
          faculty: userData['faculty'],
          designation: userData['designation'],
          officeLocation: userData['officeLocation'],
          createdAt: userData['createdAt'] != null ? DateTime.tryParse(userData['createdAt']) : null,
          lastLogin: userData['lastLogin'] != null ? DateTime.tryParse(userData['lastLogin']) : null,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== UPDATE USER PROFILE ====================
  Future<void> updateUserProfile({
    required String userId,
    String? phone,
    String? department,
    String? fullName,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (phone != null) updates['phone'] = phone;
      if (department != null) updates['department'] = department;
      if (fullName != null) updates['fullName'] = fullName;
      
      await _firebaseService.updateUserInFirestore(userId, updates);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== GET USER BY ID ====================
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userData = await _firebaseService.getUserFromFirestore(userId);
      if (userData != null) {
        return UserModel(
          id: userData['uid'] ?? userId,
          email: userData['email'] ?? '',
          fullName: userData['fullName'] ?? '',
          role: userData['role'] ?? 'student',
          staffType: userData['staffType'],
          isEmailVerified: userData['isEmailVerified'] ?? false,
          phone: userData['phone'],
          department: userData['department'],
          indexNumber: userData['indexNumber'],
          campusId: userData['campusId'],
          nic: userData['nic'],
          dob: userData['dob'],
          degree: userData['degree'],
          intake: userData['intake'],
          staffId: userData['staffId'],
          faculty: userData['faculty'],
          designation: userData['designation'],
          officeLocation: userData['officeLocation'],
          createdAt: userData['createdAt'] != null ? (userData['createdAt'] as Timestamp).toDate() : null,
          lastLogin: userData['lastLogin'] != null ? (userData['lastLogin'] as Timestamp).toDate() : null,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== GET ALL STUDENTS ====================
  Future<List<UserModel>> getAllStudents() async {
    try {
      final usersData = await _firebaseService.getUsersByRole('student');
      return usersData.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          id: doc.id,
          email: data['email'] ?? '',
          fullName: data['fullName'] ?? '',
          role: 'student',
          isEmailVerified: data['isEmailVerified'] ?? false,
          phone: data['phone'],
          department: data['department'],
          indexNumber: data['indexNumber'],
          campusId: data['campusId'],
          nic: data['nic'],
          dob: data['dob'],
          degree: data['degree'],
          intake: data['intake'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== GET ALL STAFF ====================
  Future<List<UserModel>> getAllStaff() async {
    try {
      final usersData = await _firebaseService.getUsersByRole('staff');
      return usersData.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          id: doc.id,
          email: data['email'] ?? '',
          fullName: data['fullName'] ?? '',
          role: 'staff',
          staffType: data['staffType'],
          isEmailVerified: data['isEmailVerified'] ?? false,
          department: data['department'],
          staffId: data['staffId'],
          faculty: data['faculty'],
          designation: data['designation'],
          officeLocation: data['officeLocation'],
          phone: data['phone'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== DELETE USER ACCOUNT ====================
  

  // ==================== RESET PASSWORD ====================
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}