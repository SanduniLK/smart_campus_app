import 'package:smart_campus_app/data/repositories/auth_repository.dart';
import 'package:smart_campus_app/data/models/user_model.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;
  final DatabaseService _databaseService;

  AuthRepositoryImpl({
    required FirebaseService firebaseService,
    required DatabaseService databaseService,
  }) : _firebaseService = firebaseService,
       _databaseService = databaseService;

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Firebase Authentication
      final firebaseUser = await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        throw Exception('Invalid email or password');
      }

      // 2. Check email verification
      if (!firebaseUser.emailVerified) {
        throw Exception('Please verify your email first');
      }

      // 3. Get user data from SQLite
      final userData = await _databaseService.getUserByUid(firebaseUser.uid);
      
      if (userData == null) {
        throw Exception('User data not found');
      }

      // 4. Return UserModel
      return UserModel.fromMap(userData);
      
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
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
      // 1. Create user in Firebase
      final firebaseUser = await _firebaseService.signUpStudent(
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

      if (firebaseUser == null) {
        throw Exception('Failed to create account');
      }

      // 2. Send email verification
      await _firebaseService.sendEmailVerification();

      // 3. Get user data from SQLite
      final userData = await _databaseService.getUserByUid(firebaseUser.uid);
      
      if (userData == null) {
        throw Exception('User data not saved');
      }

      // 4. Return UserModel
      return UserModel.fromMap(userData);
      
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<UserModel?> signUpStaff({
    required String email,
    required String password,
    required String fullName,
    required String staffId,
    required String faculty,
    required String department,
  }) async {
    try {
      // 1. Create user in Firebase
      final firebaseUser = await _firebaseService.signUpStaff(
        email: email,
        password: password,
        fullName: fullName,
        staffId: staffId,
        faculty: faculty,
        department: department,
      );

      if (firebaseUser == null) {
        throw Exception('Failed to create account');
      }

      // 2. Send email verification
      await _firebaseService.sendEmailVerification();

      // 3. Get user data from SQLite
      final userData = await _databaseService.getUserByUid(firebaseUser.uid);
      
      if (userData == null) {
        throw Exception('User data not saved');
      }

      // 4. Return UserModel
      return UserModel.fromMap(userData);
      
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseService.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      return await _firebaseService.checkEmailVerified();
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        await _databaseService.recordLogout(user.uid);
      }
      await _firebaseService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      
      if (firebaseUser == null) {
        return null;
      }

      final userData = await _databaseService.getUserByUid(firebaseUser.uid);
      
      if (userData == null) {
        return null;
      }

      return UserModel.fromMap(userData);
      
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}