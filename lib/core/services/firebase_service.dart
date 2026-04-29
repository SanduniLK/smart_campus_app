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
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      
      if (user != null) {
        await user.reload();
        
        // ✅ Get user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          // ✅ Sync to SQLite for offline cache
          await _db.insertOrUpdateUser({
            'uid': user.uid,
            'email': user.email ?? email,
            'fullName': userData['fullName'] ?? '',
            'role': userData['role'] ?? ROLE_STUDENT,
            'staffType': userData['staffType'],
            'isEmailVerified': user.emailVerified ? 1 : 0,
            'createdAt': userData['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'phone': userData['phone'] ?? '',
            'department': userData['department'] ?? '',
          });
          
          return {
            'uid': user.uid,
            'email': user.email,
            'fullName': userData['fullName'],
            'role': userData['role'],
            'staffType': userData['staffType'],
            'phone': userData['phone'],
            'department': userData['department'],
            'isEmailVerified': user.emailVerified ? 1 : 0,
          };
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
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
      // 1. Create user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        // 2. ✅ Save to FIRESTORE (Cloud)
        final userData = {
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STUDENT,
          'indexNumber': indexNumber,
          'campusId': campusId,
          'nic': nic,
          'phone': phone,
          'dob': dob,
          'department': department,
          'degree': degree,
          'intake': intake,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(userData);

        // 3. ✅ Save to SQLITE (Local Cache)
        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STUDENT,
          'staffType': null,
          'isEmailVerified': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': null,
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

        // 4. Send email verification
        await user.sendEmailVerification();
        
        print('✅ STUDENT account created in Firebase & Firestore: $email');
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
      // 1. Create user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        // 2. ✅ Save to FIRESTORE (Cloud)
        final userData = {
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': ROLE_STAFF,
          'staffType': staffType ?? 'academic',
          'staffId': staffId,
          'faculty': faculty,
          'department': department,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(userData);

        // 3. ✅ Save to SQLITE (Local Cache)
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

        // 4. Send email verification
        await user.sendEmailVerification();
        
        print('✅ STAFF account created in Firebase & Firestore: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // ==================== GET USER FROM FIRESTORE ====================
  Future<Map<String, dynamic>?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting user from Firestore: $e');
      return null;
    }
  }

  // ==================== UPDATE USER IN FIRESTORE ====================
  Future<void> updateUserInFirestore(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User updated in Firestore');
    } catch (e) {
      print('❌ Error updating user in Firestore: $e');
      throw e;
    }
  }

  // ==================== GET ALL USERS FROM FIRESTORE ====================
  Future<List<QueryDocumentSnapshot>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs;
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }

  // ==================== GET USERS BY ROLE ====================
  Future<List<QueryDocumentSnapshot>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('❌ Error getting users by role: $e');
      return [];
    }
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

  // ==================== REFRESH VERIFICATION STATUS ====================
  Future<bool> refreshUserVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final isVerified = user.emailVerified;
        
        // Update both SQLite and Firestore
        await _db.updateEmailVerificationStatus(user.uid, isVerified);
        await _firestore.collection('users').doc(user.uid).update({
          'isEmailVerified': isVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return isVerified;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== SEND EMAIL VERIFICATION ====================
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ==================== GET CURRENT USER DATA ====================
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Try Firestore first, fallback to SQLite
      final firestoreData = await getUserFromFirestore(user.uid);
      if (firestoreData != null) {
        return firestoreData;
      }
      return await _db.getCompleteUserProfile(user.uid);
    }
    return null;
  }
Future<void> deleteUserFromFirestore(String userId) async {
  try {
    await _firestore.collection('users').doc(userId).delete();
    print('✅ User deleted from Firestore');
  } catch (e) {
    print('❌ Error deleting from Firestore: $e');
    throw e;
  }
}
Future<void> sendPasswordResetEmail(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    print('✅ Password reset email sent to: $email');
  } on FirebaseAuthException catch (e) {
    throw _handlePasswordResetError(e);
  } catch (e) {
    throw 'An error occurred. Please try again.';
  }
}

String _handlePasswordResetError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email address.';
    case 'invalid-email':
      return 'Invalid email address format.';
    case 'too-many-requests':
      return 'Too many requests. Please try again later.';
    default:
      return 'Failed to send password reset email. Please try again.';
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