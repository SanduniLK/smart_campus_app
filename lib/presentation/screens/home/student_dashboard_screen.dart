import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/announcements_list.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/events_list.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/progress_stats.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/quick_actions.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/today_schedule.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/welcome_header.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create FirebaseService instance
    final firebaseService = FirebaseService();
    final user = firebaseService.currentUser;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeHeader(userName: user?.displayName ?? 'Student'),
            const SizedBox(height: 24),
            const ProgressStats(),
            const SizedBox(height: 24),
            TodaySchedule(onViewAll: () {}),
            const SizedBox(height: 24),
            EventsList(onViewAll: () {}),
            const SizedBox(height: 24),
            QuickActions(
              onScanQR: () {},
              onOpenMap: () {},
              onNotifications: () {},
            ),
            const SizedBox(height: 24),
            AnnouncementsList(onViewAll: () {}),
          ],
        ),
      ),
    );
  }
}