import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/announcements_list.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/next_class_card.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/progress_stats.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/quick_access_grid.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/welcome_header.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final user = firebaseService.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeHeader(
                userName: user?.displayName ?? 'Kavya Perera',
              ),
              const SizedBox(height: 24),
              const NextClassCard(
                className: 'ICT4153 – Mobile App Dev',
                startTime: '10:00 AM',
                endTime: '12:00 PM',
                location: 'Room A204 · Building A · 2nd Floor',
                room: 'Room A204',
                building: 'Building A',
                floor: '2nd Floor',
                professor: 'Dr. Nimal Silva',
                type: 'Theory',
                minutesRemaining: 25,
              ),
              const SizedBox(height: 20),
              const ProgressStats(),
              const SizedBox(height: 24),
              const Text(
                'QUICK ACCESS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              QuickAccessGrid(
                onTimetableTap: () {
                  // Navigate to timetable
                },
                onCampusMapTap: () {
                  // Navigate to map
                },
                onQRPassTap: () {
                  // Show QR pass
                },
                onEventsTap: () {
                  // Navigate to events
                },
              ),
              const SizedBox(height: 24),
              AnnouncementsList(
                onViewAll: () {
                  // Navigate to all announcements
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      
    );
  }
}