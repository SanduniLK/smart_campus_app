// lib/presentation/screens/home/non_academic_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/user_model.dart';
import 'package:smart_campus_app/presentation/screens/announcements/announcements_screen.dart';
import 'package:smart_campus_app/presentation/screens/profile/profile_screen.dart';
import 'package:smart_campus_app/presentation/widgets/announcement/role_based_announcements.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:smart_campus_app/presentation/screens/time_table/create_timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/time_table/view_timetable_screen.dart';
import 'package:smart_campus_app/presentation/screens/time_table/edit_timetable_screen.dart';

class NonAcademicDashboard extends StatefulWidget {
  const NonAcademicDashboard({super.key});

  @override
  State<NonAcademicDashboard> createState() => _NonAcademicDashboardState();
}

class _NonAcademicDashboardState extends State<NonAcademicDashboard> {
  late UserModel _user;
  int _currentIndex = 0;

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

  void _navigateToCreateTimetable() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTimetableScreen()),
    );
  }

  void _navigateToTimetableView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViewTimetableScreen()),
    );
  }

  void _navigateToEditTimetable(Map<String, dynamic> entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTimetableScreen(entry: entry)),
    );
  }

  void _navigateToAllAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllAnnouncementsScreen(
          userRole: 'non_academic_staff',
          userId: _user.id,
          userName: _user.fullName,
          canPost: true,
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _showCreateAnnouncementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAnnouncementSheet(
        userRole: 'non_academic_staff',
        userId: _user.id,
        userName: _user.fullName,
        onCreated: () {
          setState(() {});
        },
      ),
    );
  }

  

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        _navigateToTimetableView();
        break;
      case 2:
        _navigateToAllAnnouncements();
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToCreateTimetable,
            tooltip: 'Create Timetable',
          ),
          IconButton(
            icon: const Icon(Icons.schedule, color: Colors.white),
            onPressed: _navigateToTimetableView,
            tooltip: 'View Timetable',
          ),
        ],
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildAnnouncementsSection(),
              const SizedBox(height: 24),
              _buildAllTimetable(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.glassSurface,
          selectedItemColor: AppColors.electricPurple,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: _currentIndex,
          onTap: _onNavBarTap,
          elevation: 0,
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
              icon: Icon(Icons.announcement_outlined),
              activeIcon: Icon(Icons.announcement),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
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
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.electricPurple),
                  onPressed: _showCreateAnnouncementSheet,
                  tooltip: 'Post Announcement',
                ),
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
        
        RoleBasedAnnouncements(
          userRole: 'non_academic_staff',
          userId: _user.id,
          userName: _user.fullName,
          showViewAll: false,
          limit: 3,
          showCreateButton: false,
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
            Text(_getGreeting(), style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(_user.fullName, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(_getFormattedDate(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Administrative Staff', style: TextStyle(fontSize: 10, color: AppColors.success)),
            ),
          ],
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.electricPurple, AppColors.softMagenta]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(_user.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('24', 'Courses', Icons.menu_book_rounded, AppColors.electricPurple)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('156', 'Students', Icons.people_rounded, AppColors.softMagenta)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('8', 'Staff', Icons.badge_rounded, AppColors.vibrantYellow)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionButton(Icons.add, 'Create', AppColors.electricPurple, _navigateToCreateTimetable)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.schedule, 'View All', AppColors.success, _navigateToTimetableView)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.announcement, 'Post', AppColors.vibrantYellow, _showCreateAnnouncementSheet)),
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
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimetable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Timetable Entries', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        FutureBuilder(
          future: DatabaseService().getAllTimetable(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
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
                      const Text('No timetable entries', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      
                    ],
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timetable.length,
              itemBuilder: (context, index) {
                final entry = timetable[index];
                return _buildEditableTimetableCard(entry);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEditableTimetableCard(Map<String, dynamic> entry) {
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
                Text(entry['startTime'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                Text(entry['endTime'], style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry['courseId']} - ${entry['courseName']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Lecturer: ${entry['lecturerName']}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                Text('Level: ${entry['level']} | Semester: ${entry['semester']}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text('${entry['roomNumber']}, ${entry['building'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
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
              child: Text('ONGOING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.vibrantYellow)),
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.vibrantYellow),
            onPressed: () => _navigateToEditTimetable(entry),
          ),
        ],
      ),
    );
  }
}