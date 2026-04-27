// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_campus_app/data/models/user_model.dart';

class AuthRepository {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          // Create user model from Firebase user if no Firestore doc
          return UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            fullName: userCredential.user!.displayName ?? '',
            role: 'student', // Default role
          );
        }
      }
      return null;
    } on firebase.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Student Sign Up
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
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.reload();
        
        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Create user document in Firestore
        final user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          role: 'student',
          indexNumber: indexNumber,
          campusId: campusId,
          nic: nic,
          phone: phone,
          dob: dob,
          department: department,
          degree: degree,
          intake: intake,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toFirestore());

        return user;
      }
      return null;
    } on firebase.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Staff Sign Up
  Future<UserModel?> signUpStaff({
    required String email,
    required String password,
    required String fullName,
    required String staffId,
    required String faculty,
    required String department,
    required String designation,
    required String phone,
    String? officeLocation,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.reload();
        
        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Create user document in Firestore
        final user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          role: 'staff',
          staffId: staffId,
          faculty: faculty,
          department: department,
          designation: designation,
          phone: phone,
          officeLocation: officeLocation,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toFirestore());

        return user;
      }
      return null;
    } on firebase.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase errors
  String _handleFirebaseError(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}