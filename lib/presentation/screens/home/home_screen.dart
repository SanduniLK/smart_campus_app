import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/presentation/screens/home/staff_dashboard_screen.dart';
import 'package:smart_campus_app/presentation/screens/home/student_dashboard_screen.dart';
import 'package:smart_campus_app/presentation/screens/timetable/timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/events_screen.dart';
import 'package:smart_campus_app/presentation/screens/profile/profile_screen.dart';
import 'package:smart_campus_app/presentation/widgets/staff_dashborard/glass_bottom_nav.dart';
import 'package:smart_campus_app/presentation/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // ✅ Handle loading state
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // ✅ Handle unauthenticated state - Redirect to login
        if (state is AuthUnauthenticated) {
          // Redirect to login screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink(); // Return empty widget while redirecting
        }
        
        // ✅ Handle authenticated state
        if (state is AuthAuthenticated) {
          print('✅ User role: ${state.user.role}'); 
          
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: TabBarView(
                children: [
                  // First tab - Dashboard (based on role)
                  state.user.role == 'staff'
                      ? const StaffDashboardScreen()   
                      : const StudentDashboardScreen(), 
                  // Second tab - Timetable
                  const TimetableScreen(),
                  // Third tab - Events
                  const EventsScreen(),
                  // Fourth tab - Profile
                  const ProfileScreen(),
                ],
              ),
              bottomNavigationBar: const GlassBottomNavBar(),
            ),
          );
        }
        
        // ✅ Handle error state
        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
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
        
        // Default fallback - show login
        return const LoginScreen();
      },
    );
  }
}