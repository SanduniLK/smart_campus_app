import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();

  // User Roles
  static const String ROLE_STUDENT = 'student';
  static const String ROLE_STAFF = 'staff';

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Sign Up Student
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
      print('📝 Creating student account for: $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        print('✅ User created in Firebase: ${user.uid}');
        
        await user.updateDisplayName(fullName);
        await user.reload();

        // Save to SQLite
        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STUDENT,
          'isEmailVerified': 0,
          'createdAt': DateTime.now().toIso8601String(),
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
        });

        // SEND EMAIL VERIFICATION - FIXED
        await sendEmailVerification();
        print('✅ Verification email sent to: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw 'An error occurred. Please try again.';
    }
  }

  // Sign Up Staff with Faculty and Department
Future<User?> signUpStaff({
  required String email,
  required String password,
  required String fullName,
  required String staffId,
  required String faculty,        // Added faculty
  required String department,      // Added department
 
}) async {
  try {
    print('📝 Creating staff account for: $email');
    
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user != null) {
      print('✅ User created in Firebase: ${user.uid}');
      
      await user.updateDisplayName(fullName);
      await user.reload();

      // Save to SQLite - Users table
      await _db.insertOrUpdateUser({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'role': ROLE_STAFF,
        'isEmailVerified': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Save to SQLite - Staff table with faculty and department
      await _db.insertStaffDetails({
        'uid': user.uid,
        'staffId': staffId,
        'faculty': faculty,
        'department': department,
        
      });

      // Send email verification
      await sendEmailVerification();
      print('✅ Verification email sent to: $email');
    }

    return user;
  } on FirebaseAuthException catch (e) {
    print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
    throw _handleFirebaseAuthException(e);
  } catch (e) {
    print('❌ Unexpected error: $e');
    throw 'An error occurred. Please try again.';
  }
}

  // Send Email Verification - FIXED VERSION
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          print('✅ Verification email sent successfully');
        } else {
          print('⚠️ Email already verified');
        }
      } else {
        print('❌ No user logged in');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      print('❌ Error sending verification: $e');
      throw 'Failed to send verification email';
    }
  }

  // Check Email Verification
  Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      print('❌ Error checking verification: $e');
      return false;
    }
  }

  // Sign In
  Future<User?> signInWithEmail({
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
        await user.reload();
        await _db.updateLastLogin(user.uid);
        await _db.recordLogin(user.uid);
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.recordLogout(user.uid);
    }
    await _auth.signOut();
  }

  // Handle Firebase Auth Exceptions
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
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}