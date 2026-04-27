import 'package:smart_campus_app/data/models/user_model.dart';


abstract class AuthRepository {
  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

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
  });

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
  });

  // Email Verification
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();

  // Sign Out
  Future<void> signOut();

  // Get Current User
  Future<UserModel?> getCurrentUser();
}