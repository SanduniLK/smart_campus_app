import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/presentation/screens/events/create_event_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/events_list_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/pending_events_screen.dart';
import 'package:smart_campus_app/presentation/screens/time_table/create_timetable_screen.dart';
import 'package:smart_campus_app/presentation/widgets/events/pending_tasks_widget.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

import 'package:smart_campus_app/data/models/user_model.dart';
import 'package:smart_campus_app/presentation/screens/time_table/staff_timetable_manager.dart';
import 'package:smart_campus_app/presentation/widgets/staff_dashborard/recent_announcements_widget.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }

  void _navigateToCreateEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEventScreen()),
    );
  }

  void _navigateToEventsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EventsListScreen()),
    );
  }

  void _navigateToPendingEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PendingEventsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    
    if (state is! AuthAuthenticated) {
      return const Center(child: Text('Not authenticated'));
    }

    final user = state.user;
    final isAcademic = user.staffType == 'academic';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildQuickActions(context, isAcademic),
            const SizedBox(height: 24),
            _buildTodaySchedule(context),
            const SizedBox(height: 24),
            const PendingTasksWidget(),
            const SizedBox(height: 24),
            RecentAnnouncementsWidget(
              onPostNew: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dr. ${user.fullName.split(' ').last}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.electricPurple, AppColors.softMagenta],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricPurple.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.fullName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '24',
            'Courses',
            Icons.menu_book_rounded,
            AppColors.electricPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '156',
            'Students',
            Icons.people_rounded,
            AppColors.softMagenta,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '8',
            'Pending',
            Icons.pending_actions_rounded,
            AppColors.vibrantYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isAcademic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.post_add_rounded,
                'Announcement',
                AppColors.electricPurple,
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.event_rounded,
                'Create Event',
                AppColors.softMagenta,
                () => _navigateToCreateEvent(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.assignment_turned_in_rounded,
                'Take Attendance',
                AppColors.vibrantYellow,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Scanner Coming Soon')),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Second Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.schedule_rounded,
                'Timetable',
                AppColors.electricPurple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateTimetableScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.upload_file_rounded,
                'Upload Notes',
                AppColors.softMagenta,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload Notes Coming Soon')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.grade_rounded,
                'Marks Entry',
                AppColors.vibrantYellow,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marks Entry Coming Soon')),
                  );
                },
              ),
            ),
          ],
        ),

        // Third Row - Academic Staff Only (Event Management)
        if (isAcademic) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.pending_actions,
                  'Pending Events',
                  Colors.orange,
                  () => _navigateToPendingEvents(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.list_alt,
                  'All Events',
                  Colors.green,
                  () => _navigateToEventsList(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.add,
                  'Quick Event',
                  AppColors.electricPurple,
                  () => _navigateToCreateEvent(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffTimetableManager()),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScheduleCard(
          'CS301',
          'Database Systems',
          '09:00 - 10:30',
          'Room 203',
          'Year 2 Semester 1',
          isNext: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Schedule Coming Soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildScheduleCard(
          'CS302',
          'Mobile App Dev',
          '11:00 - 12:30',
          'Lab 105',
          'Year 3 Semester 2',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Schedule Coming Soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildScheduleCard(
          'CS303',
          'Software Engineering',
          '14:00 - 15:30',
          'Room 301',
          'Year 4 Semester 1',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Schedule Coming Soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    String code,
    String course,
    String time,
    String room,
    String batch, {
    bool isNext = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: isNext ? AppColors.vibrantYellow : null,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: isNext ? AppColors.vibrantYellow : AppColors.electricPurple,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isNext ? AppColors.vibrantYellow : AppColors.electricPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isNext ? AppColors.vibrantYellow : AppColors.electricPurple)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          batch,
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            color: isNext ? AppColors.vibrantYellow : AppColors.electricPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isNext)
                        const SizedBox(width: 8),
                      if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.vibrantYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEXT',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: AppColors.vibrantYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    course,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        room,
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.electricPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.electricPurple,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}