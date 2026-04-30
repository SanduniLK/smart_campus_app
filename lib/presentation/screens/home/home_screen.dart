// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/presentation/screens/home/academic_dashboard.dart';
import 'package:smart_campus_app/presentation/screens/home/non_academic_dashboard.dart';
import 'package:smart_campus_app/presentation/screens/home/student_dashboard_screen.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }
        
        if (state is AuthAuthenticated) {
          final user = state.user;
          
          // ✅ Role-based routing
          if (user.role == 'student') {
            return const StudentDashboardScreen();
          } 
          else if (user.role == 'staff') {
            // ✅ Check staff type
            if (user.staffType == 'academic') {
              return const AcademicDashboard();
            } else if (user.staffType == 'non_academic') {
              return const NonAcademicDashboard();
            }
          }
        }
        
        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }
        
        return const LoginScreen();
      },
    );
  }
}