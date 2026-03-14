import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseService _db = DatabaseService();

  // User Roles
  static const String ROLE_STUDENT = 'student';
  static const String ROLE_STAFF = 'staff';

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Sign Up with Email & Password (Student)
  static Future<User?> signUpStudent({
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
      // Create authentication user in Firebase
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update display name in Firebase
        await user.updateDisplayName(fullName);
        await user.reload();

        // Save user data to LOCAL SQLite database
        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STUDENT,
          'isEmailVerified': user.emailVerified ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Save student-specific details
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
        });

        // Send email verification
        await sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Sign Up with Email & Password (Staff)
  static Future<User?> signUpStaff({
    required String email,
    required String password,
    required String fullName,
    required String staffId,
  }) async {
    try {
      // Create authentication user in Firebase
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Update display name in Firebase
        await user.updateDisplayName(fullName);
        await user.reload();

        // Save user data to LOCAL SQLite database
        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STAFF,
          'isEmailVerified': user.emailVerified ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Save staff-specific details
        await _db.insertStaffDetails({
          'uid': user.uid,
          'staffId': staffId,
        });

        // Send email verification
        await sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  // Sign In
  static Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      
      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();
        
        // Update local database with latest info
        final existingUser = await _db.getUserByUid(user.uid);
        
        if (existingUser != null) {
          // Update verification status if changed
          await _db.updateEmailVerificationStatus(user.uid, user.emailVerified);
          await _db.updateLastLogin(user.uid);
        } else {
          // If user exists in Firebase but not in local DB (shouldn't happen, but just in case)
          await _db.insertOrUpdateUser({
            'uid': user.uid,
            'email': user.email,
            'fullName': user.displayName ?? 'User',
            'role': 'unknown', // We don't know role yet
            'isEmailVerified': user.emailVerified ? 1 : 0,
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
        }
        
        // Record login session
        await _db.recordLogin(user.uid);
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Send Email Verification
  static Future<void> sendEmailVerification() async {
  try {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('✅ Verification email sent to: ${user.email}');
    } else {
      print('❌ User is null or already verified');
    }
  } catch (e) {
    print('❌ Failed to send verification email: $e');
    throw 'Failed to send verification email: $e';
  }
}

  // Check email verification status and update local DB
  static Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        bool isVerified = user.emailVerified;
        
        // Update local database
        await _db.updateEmailVerificationStatus(user.uid, isVerified);
        
        return isVerified;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user role from local database
  static Future<String?> getUserRole(String uid) async {
    final user = await _db.getUserByUid(uid);
    return user?['role'] as String?;
  }

  // Get complete user profile from local database
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _db.getCompleteUserProfile(user.uid);
    }
    return null;
  }

  // Sign Out
  static Future<void> signOut() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.recordLogout(user.uid);
    }
    await _auth.signOut();
  }

  // Handle Firebase Auth Exceptions
  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Stream of auth changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}