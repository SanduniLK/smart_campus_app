// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/core/theme/app_theme.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/repositories/auth_repository.dart';
import 'package:smart_campus_app/data/repositories/event/event_repository.dart';
import 'package:smart_campus_app/data/repositories/time_table/timetable_repository.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_event.dart';
import 'package:smart_campus_app/business_logic/timetable/timetable_bloc.dart';
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
    debugPrint('✅ Firebase initialized');
    
    // Initialize database (this will create the database if it doesn't exist)
    final dbService = DatabaseService();
    await dbService.database; // This triggers database creation
    debugPrint('✅ SQLite database initialized');
    
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }
  
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseService: firebaseService,
          ),
        ),
        RepositoryProvider<TimetableRepository>(
          create: (context) => TimetableRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckStatusRequested()),
          ),
          BlocProvider<TimetableBloc>(
            create: (context) => TimetableBloc(
              repository: context.read<TimetableRepository>(),
            ),
          ),
          BlocProvider<EventBloc>(
            create: (context) => EventBloc(
              repository: EventRepository(),
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