import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_campus_app/core/theme/app_theme.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/repositories/auth_repository.dart';
import 'package:smart_campus_app/data/repositories/time_table/timetable_repository.dart';

import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_event.dart';
import 'package:smart_campus_app/business_logic/timetable/timetable_bloc.dart';

// Screens
import 'package:smart_campus_app/presentation/screens/splash/splash_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/role_selection_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/student_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/staff_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    await DatabaseService().database;
    print('✅ Firebase & SQLite initialized');
  } catch (e) {
    print('❌ Initialization error: $e');
  }
  
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create service instances
    final firebaseService = FirebaseService();

    return MultiRepositoryProvider(
      providers: [
        // Auth Repository
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseService: firebaseService,
          ),
        ),
        // Timetable Repository
        RepositoryProvider<TimetableRepository>(
          create: (context) => TimetableRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth Bloc
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckStatusRequested()),
          ),
          // Timetable Bloc
          BlocProvider<TimetableBloc>(
            create: (context) => TimetableBloc(
              repository: context.read<TimetableRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
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
        ),
      ),
    );
  }
}