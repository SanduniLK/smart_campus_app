import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/student_model/dashboard_models.dart';
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
    final user = FirebaseService.currentUser;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WelcomeHeader widget එක
            WelcomeHeader(userName: user?.displayName ?? 'Student'),
            
            const SizedBox(height: 24),
            
            // ProgressStats widget එක - මේක දැන් හරියට වැඩ කරයි
            const ProgressStats(),
            
            const SizedBox(height: 24),
            
            // TodaySchedule widget එක
            TodaySchedule(onViewAll: () {
              // Navigate to full timetable
            }),
            
            const SizedBox(height: 24),
            
            // EventsList widget එක
            EventsList(onViewAll: () {
              // Navigate to events screen
            }),
            
            const SizedBox(height: 24),
            
            // QuickActions widget එක
            QuickActions(
              onScanQR: () {},
              onOpenMap: () {},
              onNotifications: () {},
            ),
            
            const SizedBox(height: 24),
            
            // AnnouncementsList widget එක
            AnnouncementsList(onViewAll: () {}),
          ],
        ),
      ),
    );
  }
}