import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();

  static const String ROLE_STUDENT = 'student';
  static const String ROLE_STAFF = 'staff';

  User? get currentUser => _auth.currentUser;

  // ==================== SIGN IN ====================
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // ==================== GET CURRENT USER DATA ====================
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _db.getCompleteUserProfile(user.uid);
    }
    return null;
  }

  // ==================== REFRESH VERIFICATION STATUS ====================
  Future<bool> refreshUserVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final isVerified = user.emailVerified;
        await _db.updateEmailVerificationStatus(user.uid, isVerified);
        print('🔄 Verification status: $isVerified');
        return isVerified;
      }
      return false;
    } catch (e) {
      print('❌ Error refreshing: $e');
      return false;
    }
  }

  // ==================== SEND EMAIL VERIFICATION ====================
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('✅ Verification email sent');
    }
  }

  // ==================== STUDENT SIGN UP ====================
  Future<User?> signUpStudent({
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
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STUDENT,
          'staffType': null,
          'isEmailVerified': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': '', 
          'phone': phone,
          'department': department,
        });

        await _db.insertStudentDetails({
          'uid': user.uid,
          'indexNumber': indexNumber,
          'campusId': campusId,
          'nic': nic,
          'phone': phone,
          'dob': dob,
          'department': department,
          'degree': degree,
          'intake': intake,
          'currentSemester': 1,
          'batchYear': int.tryParse(intake) ?? 2024,
        });

        await user.sendEmailVerification();
        print('✅ STUDENT account created: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // ==================== STAFF SIGN UP ====================
  Future<User?> signUpStaff({
    required String email,
    required String password,
    required String fullName,
    required String staffId,
    required String faculty,
    required String department,
    String? staffType,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STAFF,
          'staffType': staffType ?? 'academic',
          'isEmailVerified': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': null,
          'phone': '',
          'department': department,
        });

        await _db.insertStaffDetails({
          'uid': user.uid,
          'staffId': staffId,
          'faculty': faculty,
          'department': department,
          'staffType': staffType ?? 'academic',
          'position': '',
          'workLocation': '',
        });

        await user.sendEmailVerification();
        print('✅ STAFF account created: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // ==================== SIGN OUT ====================
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.recordLogout(user.uid);
    }
    await _auth.signOut();
  }

  // ==================== CHECK EMAIL VERIFIED ====================
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // ==================== HANDLE ERRORS ====================
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}