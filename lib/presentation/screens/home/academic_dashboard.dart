// lib/presentation/screens/home/academic_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_event.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

import 'package:smart_campus_app/data/models/user_model.dart';

import 'package:smart_campus_app/presentation/screens/events/create_event_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/events_list_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/pending_events_screen.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:smart_campus_app/presentation/screens/time_table/view_timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/time_table/edit_timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/profile/profile_screen.dart';
import 'package:smart_campus_app/presentation/widgets/announcement/role_based_announcements.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicDashboard extends StatefulWidget {
  const AcademicDashboard({super.key});

  @override
  State<AcademicDashboard> createState() => _AcademicDashboardState();
}

class _AcademicDashboardState extends State<AcademicDashboard> {
  late UserModel _user;
  int _currentIndex = 0;
  bool _isFixingDatabase = false;

  final List<Widget> _tabWidgets = [
    const SizedBox(), // Home tab - built dynamically
    const ViewTimetableScreen(),
    const ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _user = state.user;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }

  bool _isTimeBetween(String current, String start, String end) {
    try {
      int currentInt = int.parse(current.replaceAll(':', ''));
      int startInt = int.parse(start.replaceAll(':', ''));
      int endInt = int.parse(end.replaceAll(':', ''));
      return currentInt >= startInt && currentInt <= endInt;
    } catch (e) {
      return false;
    }
  }

  void _navigateToTimetableView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViewTimetableScreen(),
      ),
    );
  }

  void _navigateToEditTimetable(Map<String, dynamic> entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTimetableScreen(entry: entry),
      ),
    );
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEventScreen()),
    );
  }

  void _navigateToEventsList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EventsListScreen()),
    );
  }

  void _navigateToPendingEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PendingEventsScreen()),
    );
  }

  void _navigateToAllAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllAnnouncementsScreen(
          userRole: 'academic_staff',
          userId: _user.id,
          userName: _user.fullName,
          canPost: true, // Academic staff can post announcements
        ),
      ),
    );
  }

  void _showCreateAnnouncementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAnnouncementSheet(
        userRole: 'academic_staff',
        userId: _user.id,
        userName: _user.fullName,
        onCreated: () {
          // Refresh the announcements list
          setState(() {});
        },
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  
  // ==================== HOME TAB CONTENT ====================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildMySchedule(),
          const SizedBox(height: 24),
          
          // Announcements Section for Academic Staff
          _buildAnnouncementsSection(),
          
          const SizedBox(height: 16),
          
          
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ANNOUNCEMENTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                // Post Announcement Button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.electricPurple),
                  onPressed: _showCreateAnnouncementSheet,
                  tooltip: 'Post Announcement',
                ),
                // View All Button
                TextButton(
                  onPressed: _navigateToAllAnnouncements,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.electricPurple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Role-based announcements - Academic Staff can VIEW and POST
        RoleBasedAnnouncements(
          userRole: 'academic_staff',
          userId: _user.id,
          userName: _user.fullName,
          showViewAll: false, // We already have View All button above
          limit: 3,
          showCreateButton: false, // We have separate Post button
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Dr. ${_user.fullName.split(' ').last}',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.electricPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Academic Staff',
                style: TextStyle(fontSize: 10, color: AppColors.electricPurple),
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
          ),
          child: Center(
            child: Text(
              _user.fullName[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
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
          child: _buildStatCard('4', 'Courses', Icons.menu_book_rounded, AppColors.electricPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('120', 'Students', Icons.people_rounded, AppColors.softMagenta),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('2', 'Pending', Icons.pending_actions_rounded, AppColors.vibrantYellow),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.schedule_rounded,
                'My Timetable',
                AppColors.electricPurple,
                _navigateToTimetableView,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.event_rounded,
                'Create Event',
                AppColors.softMagenta,
                _navigateToCreateEvent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.pending_actions,
                'Pending Events',
                Colors.orange,
                _navigateToPendingEvents,
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
                Icons.list_alt,
                'All Events',
                Colors.green,
                _navigateToEventsList,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.edit_note,
                'My Profile',
                AppColors.success,
                () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                Icons.announcement,
                'Post Announcement',
                AppColors.vibrantYellow,
                _showCreateAnnouncementSheet,
              ),
            ),
          ],
        ),
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

  Widget _buildMySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Schedule',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            TextButton(
              onPressed: _navigateToTimetableView,
              child: Text(
                'View All',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.electricPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder(
          future: DatabaseService().getTimetableByLecturer(_user.fullName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
              );
            }

            final timetable = snapshot.data ?? [];

            if (timetable.isEmpty) {
              return GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.white54),
                      const SizedBox(height: 12),
                      const Text('No lectures assigned yet', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: timetable.map((entry) => _buildEditableScheduleCard(entry)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEditableScheduleCard(Map<String, dynamic> entry) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isOngoing = _isTimeBetween(currentTime, entry['startTime'], entry['endTime']);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderColor: isOngoing ? AppColors.vibrantYellow : null,
      borderWidth: isOngoing ? 1.5 : 1,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  entry['startTime'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
                Text(
                  entry['endTime'],
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry['courseId']} - ${entry['courseName']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level: ${entry['level']} | Semester: ${entry['semester']}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      '${entry['roomNumber']}, ${entry['building'] ?? ''}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isOngoing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.vibrantYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ONGOING',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.vibrantYellow),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.vibrantYellow),
            onPressed: () => _navigateToEditTimetable(entry),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthAuthenticated) {
      return const Center(child: Text('Not authenticated'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const ViewTimetableScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.glassSurface,
        selectedItemColor: AppColors.electricPurple,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}