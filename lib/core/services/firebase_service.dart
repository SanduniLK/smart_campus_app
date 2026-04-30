import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';
import '../../data/models/time_table_model/course_model.dart';
import '../../data/models/time_table_model/timetable_entry_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService();

  static const String roleStudent = 'student';
  static const String roleStaff = 'staff';

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
        
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          await _db.insertOrUpdateUser({
            'uid': user.uid,
            'email': user.email ?? email,
            'fullName': userData['fullName'] ?? '',
            'role': userData['role'] ?? roleStudent,
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
    required String level,              
    required String currentSemester, 
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

        final userData = {
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': roleStudent,
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

        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': roleStudent,
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
          'level': level,
          'currentSemester': currentSemester,
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

        final userData = {
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': roleStaff,
          'staffType': staffType ?? 'academic',
          'staffId': staffId,
          'faculty': faculty,
          'department': department,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(userData);

        await _db.insertOrUpdateUser({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': roleStaff,
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

  // ==================== COURSE FIRESTORE OPERATIONS ====================
  Future<String> saveCourseToFirestore(Course course) async {
    try {
      final docRef = _firestore.collection('courses').doc();
      await docRef.set(course.toFirestore());
      print('✅ Course saved to Firestore: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving course to Firestore: $e');
      throw e;
    }
  }

  Future<void> updateCourseInFirestore(String firestoreId, Course course) async {
    try {
      await _firestore.collection('courses').doc(firestoreId).update(course.toFirestore());
      print('✅ Course updated in Firestore: $firestoreId');
    } catch (e) {
      print('❌ Error updating course in Firestore: $e');
      throw e;
    }
  }

  Future<void> deleteCourseFromFirestore(String firestoreId) async {
    try {
      await _firestore.collection('courses').doc(firestoreId).delete();
      print('✅ Course deleted from Firestore: $firestoreId');
    } catch (e) {
      print('❌ Error deleting course from Firestore: $e');
      throw e;
    }
  }

  Future<void> syncCoursesFromFirestoreToSQLite() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      
      for (var doc in snapshot.docs) {
        final course = Course.fromFirestore(doc);
        await _db.insertOrUpdateCourse(course);
      }
      print('✅ Synced ${snapshot.docs.length} courses from Firestore');
    } catch (e) {
      print('❌ Error syncing courses: $e');
    }
  }

  Future<void> syncLocalCoursesToFirestore() async {
    try {
      final unsyncedCourses = await _db.getUnsyncedCourses();
      
      for (var course in unsyncedCourses) {
        try {
          String firestoreId;
          
          if (course.firestoreId == null) {
            firestoreId = await saveCourseToFirestore(course);
            await _db.updateCourse(course.id!, {'firestoreId': firestoreId});
          } else {
            await updateCourseInFirestore(course.firestoreId!, course);
          }
          
          await _db.updateCourse(course.id!, {'isSynced': 1});
        } catch (e) {
          print('Failed to sync course ${course.id}: $e');
        }
      }
      print('✅ Synced ${unsyncedCourses.length} local courses');
    } catch (e) {
      print('❌ Error syncing local courses: $e');
    }
  }

  // ==================== TIMETABLE FIRESTORE OPERATIONS ====================
  Future<String> saveTimetableToFirestore(TimetableEntry entry) async {
    try {
      final docRef = _firestore.collection('timetable').doc();
      await docRef.set(entry.toFirestore());
      print('✅ Timetable saved to Firestore: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      throw e;
    }
  }

  Future<void> updateTimetableInFirestore(String firestoreId, TimetableEntry entry) async {
    try {
      await _firestore.collection('timetable').doc(firestoreId).update(entry.toFirestore());
      print('✅ Timetable updated in Firestore: $firestoreId');
    } catch (e) {
      print('❌ Error updating in Firestore: $e');
      throw e;
    }
  }

  Future<void> deleteTimetableFromFirestore(String firestoreId) async {
    try {
      await _firestore.collection('timetable').doc(firestoreId).delete();
      print('✅ Timetable deleted from Firestore: $firestoreId');
    } catch (e) {
      print('❌ Error deleting from Firestore: $e');
      throw e;
    }
  }

  Future<void> syncTimetableFromFirestoreToSQLite() async {
    try {
      final snapshot = await _firestore.collection('timetable').get();
      
      for (var doc in snapshot.docs) {
        final entry = TimetableEntry.fromFirestore(doc);
        await _db.insertOrUpdateTimetableEntry(entry);
      }
      print('✅ Synced ${snapshot.docs.length} entries from Firestore');
    } catch (e) {
      print('❌ Error syncing from Firestore: $e');
    }
  }

  Future<void> syncLocalTimetableToFirestore() async {
    try {
      final unsyncedEntries = await _db.getUnsyncedTimetableEntries();
      
      for (var entry in unsyncedEntries) {
        try {
          String firestoreId;
          
          if (entry.firestoreId == null) {
            firestoreId = await saveTimetableToFirestore(entry);
            await _db.updateTimetableFirestoreId(entry.id!, firestoreId);
          } else {
            await updateTimetableInFirestore(entry.firestoreId!, entry);
          }
          
          await _db.markTimetableAsSynced(entry.id!);
        } catch (e) {
          print('Failed to sync entry ${entry.id}: $e');
        }
      }
      print('✅ Synced ${unsyncedEntries.length} local entries');
    } catch (e) {
      print('❌ Error syncing to Firestore: $e');
    }
  }

  // ==================== EMAIL VERIFICATION ====================
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  Future<bool> refreshUserVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final isVerified = user.emailVerified;
        
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
      final firestoreData = await getUserFromFirestore(user.uid);
      if (firestoreData != null) {
        return firestoreData;
      }
      return await _db.getCompleteUserProfile(user.uid);
    }
    return null;
  }

  // ==================== DELETE USER ====================
  Future<void> deleteUserFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User deleted from Firestore');
    } catch (e) {
      print('❌ Error deleting from Firestore: $e');
      throw e;
    }
  }

  // ==================== PASSWORD RESET ====================
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