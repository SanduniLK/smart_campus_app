import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. මේක ඇඩ් කරන්න
import 'package:smart_campus_app/core/theme/app_theme.dart';
import 'package:smart_campus_app/presentation/screens/auth/register_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/verification_success_screen.dart';
import 'package:smart_campus_app/presentation/screens/home/home_screen.dart';
import 'package:smart_campus_app/presentation/screens/splash/splash_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';
// import 'firebase_options.dart'; // 2. CLI එක පාවිච්චි කළා නම් මේක import කරන්න

void main() async {
  // 3. Flutter widgets initialize වන තෙක් රැඳී සිටීම අනිවාර්යයි
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. Firebase App එක initialize කිරීම
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // CLI setup කළා නම් මේක enable කරන්න
  );

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
        '/register': (context) => const SignUpScreen(),
        '/verification-success': (context) => const VerificationSuccessScreen(),
        '/home': (context) => const HomeScreen(),  
      },
    );
  }
}