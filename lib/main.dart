import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_campus_app/core/theme/app_theme.dart';
import 'package:smart_campus_app/presentation/screens/splash/splash_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/role_selection_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/student_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/staff_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/home/home_screen.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/presentation/widgets/email_verification_dialog.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
    
    // Test SQLite
    var databasesPath = await getDatabasesPath();
    print('📁 Databases path: $databasesPath');
    
    // Initialize SQLite
    await DatabaseService().database;
    print('✅ SQLite initialized');
    
  } catch (e, stack) {
    print('❌ Initialization error: $e');
    print('📚 Stack trace: $stack');
  }
  
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const RuhunaSplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/student-signup': (context) => const StudentSignUpScreen(),
        '/staff-signup': (context) => const StaffSignUpScreen(),
        
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}