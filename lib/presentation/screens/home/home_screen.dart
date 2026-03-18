import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/presentation/screens/home/staff_dashboard_screen.dart';

import 'package:smart_campus_app/presentation/screens/home/student_dashboard_screen.dart';
import 'package:smart_campus_app/presentation/screens/timetable/timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/events_screen.dart';
import 'package:smart_campus_app/presentation/screens/profile/profile_screen.dart';

import 'package:smart_campus_app/presentation/widgets/staff_dashborard/glass_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          print('✅ User role: ${state.user.role}'); 
          
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: TabBarView(
                children: [
              
                  state.user.role == 'staff'
                      ? const StaffDashboardScreen()   
                      : const StudentDashboardScreen(), 
                  const TimetableScreen(),
                  const EventsScreen(),
                  const ProfileScreen(),
                ],
              ),
              bottomNavigationBar: const GlassBottomNavBar(),
            ),
          );
        }
        return const Center(child: Text('Not authenticated'));
      },
    );
  }
}