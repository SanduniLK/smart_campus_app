import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_campus_app/core/theme/app_theme.dart';
import 'package:smart_campus_app/logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/logic/auth_bloc/auth_event.dart';

// Screens
import 'package:smart_campus_app/presentation/screens/splash/splash_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/role_selection_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/student_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/staff_signup_screen.dart';
import 'package:smart_campus_app/presentation/screens/home/home_screen.dart';

// Services
import 'package:smart_campus_app/core/services/database_service.dart';

// BLoCs

// import 'package:smart_campus_app/logic/timetable/timetable_bloc.dart';
// import 'package:smart_campus_app/logic/events/event_bloc.dart';
// import 'package:smart_campus_app/logic/announcements/announcement_bloc.dart';

// SQLite
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
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - App එක පටන් ගන්න කොටම auth status check කරනවා
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckStatusRequested()),
        ),
        
        // Timetable BLoC (will be added later)
        // BlocProvider<TimetableBloc>(
        //   create: (context) => TimetableBloc(),
        // ),
        
        // Events BLoC (will be added later)
        // BlocProvider<EventBloc>(
        //   create: (context) => EventBloc(),
        // ),
        
        // Announcements BLoC (will be added later)
        // BlocProvider<AnnouncementBloc>(
        //   create: (context) => AnnouncementBloc(),
        // ),
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
        // Error handling for undefined routes
        onGenerateRoute: (settings) {
          // You can add more dynamic route handling here
          return null;
        },
        // Fallback if route not found
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  'Page not found: ${settings.name}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}