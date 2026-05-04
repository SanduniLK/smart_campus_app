// lib/presentation/screens/home/student_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/screens/events/events_list_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/student_events_screen.dart';
import 'package:smart_campus_app/presentation/screens/location/campus_map_screen.dart';
import 'package:smart_campus_app/presentation/screens/notification/notifications_screen.dart';
import 'package:smart_campus_app/presentation/screens/profile/profile_screen.dart';
import 'package:smart_campus_app/presentation/screens/time_table/student_timetable_screen.dart';
import 'package:smart_campus_app/presentation/widgets/announcement/role_based_announcements.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/presentation/widgets/timetable/next_class_widget.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String _studentLevel = 'Year 3';
  String _studentSemester = 'Semester 1';
  bool _isLoading = true;
  List<Map<String, dynamic>> _todayClasses = [];
  List<Map<String, dynamic>> _upcomingClasses = [];
  final DatabaseService _db = DatabaseService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final firebaseService = FirebaseService();
      final user = firebaseService.currentUser;
      
      if (user != null) {
        final studentDetails = await _db.getStudentDetails(user.uid);
        if (studentDetails != null) {
          _studentLevel = studentDetails['level'] ?? 'Year 3';
          _studentSemester = studentDetails['currentSemester'] ?? 'Semester 1';
        }
        
        final allTimetable = await _db.getAllTimetable();
        
        final filteredTimetable = allTimetable.where((entry) {
          return entry['level'] == _studentLevel && 
                 entry['semester'] == _studentSemester;
        }).toList();
        
        final today = DateTime.now().weekday;
        final currentDay = today == 7 ? 6 : today;
        _todayClasses = filteredTimetable
            .where((entry) => entry['dayOfWeek'] == currentDay)
            .toList();
        
        _upcomingClasses = filteredTimetable
            .where((entry) => entry['dayOfWeek'] > currentDay)
            .toList();
        
        _upcomingClasses.sort((a, b) => a['dayOfWeek'].compareTo(b['dayOfWeek']));
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek - 1];
  }

  void _navigateTo(String route) {
    final routes = {
      'timetable': const StudentTimetableScreen(),
      'register_events': const EventsListScreen(),
      'my_events': const StudentEventsScreen(),
      'map': const CampusMapScreen(),
      'notifications': const NotificationsScreen(),
      'profile': const ProfileScreen(),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => routes[route]!));
  }

  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: break;
      case 1: _navigateTo('timetable');
      case 2: _navigateTo('my_events');
      case 3: _navigateTo('profile');
    }
  }

  Widget _buildClassCard(Map<String, dynamic> entry, {bool isUpcoming = false}) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isOngoing = !isUpcoming && _isTimeBetween(currentTime, entry['startTime'], entry['endTime']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              border: Border.all(
                color: isOngoing ? AppColors.vibrantYellow.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                width: isOngoing ? 1.5 : 0.5,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildTimeColumn(entry, isUpcoming, isOngoing),
                Container(width: 1, height: 50, color: Colors.white24),
                const SizedBox(width: 12),
                Expanded(child: _buildClassDetails(entry)),
                if (isOngoing) _buildOngoingBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(Map<String, dynamic> entry, bool isUpcoming, bool isOngoing) {
    return SizedBox(
      width: isUpcoming ? 70 : 60,
      child: isUpcoming
          ? Column(
              children: [
                Text(_getDayName(entry['dayOfWeek']),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.vibrantYellow, fontSize: 12)),
                const SizedBox(height: 4),
                Text(entry['startTime'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
              ],
            )
          : Column(
              children: [
                Text(entry['startTime'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isOngoing ? AppColors.vibrantYellow : Colors.white, fontSize: 14)),
                Text(entry['endTime'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
              ],
            ),
    );
  }

  Widget _buildClassDetails(Map<String, dynamic> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${entry['courseId']} - ${entry['courseName']}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(entry['lecturerName'],
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.location_on, size: 10, color: Colors.white54),
            const SizedBox(width: 4),
            Expanded(
              child: Text('${entry['roomNumber']}, ${entry['building'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOngoingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.vibrantYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('ONGOING', 
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.vibrantYellow)),
    );
  }

  Widget _buildTodaySchedule() {
    if (_todayClasses.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(Icons.free_breakfast, size: 48, color: Colors.green),
                const SizedBox(height: 12),
                Text('No classes today!', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Enjoy your day', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: _todayClasses.map((cls) => _buildClassCard(cls)).toList());
  }

  Widget _buildUpcomingSchedule() {
    if (_upcomingClasses.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(children: [
          Icon(Icons.calendar_today, size: 16, color: AppColors.vibrantYellow),
          const SizedBox(width: 8),
          Text('Upcoming Classes', 
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.vibrantYellow)),
        ]),
        const SizedBox(height: 12),
        Column(children: _upcomingClasses.take(3).map((cls) => _buildClassCard(cls, isUpcoming: true)).toList()),
        if (_upcomingClasses.length > 3)
          Center(
            child: TextButton.icon(
              onPressed: () => _navigateTo('timetable'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(foregroundColor: AppColors.electricPurple),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(title, 
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar(String userName) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60)),
                      const SizedBox(height: 4),
                      Text(userName,
                          style: GoogleFonts.poppins(
                            fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.electricPurple, AppColors.softMagenta],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$_studentLevel • $_studentSemester',
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                _buildNotificationBell(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () => _navigateTo('notifications'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications_none, color: Colors.white, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  AppColors.electricPurple.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.electricPurple,
              unselectedItemColor: Colors.white54,
              currentIndex: _currentIndex,
              onTap: _onNavBarTap,
              elevation: 0,
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), activeIcon: Icon(Icons.schedule), label: 'Timetable'),
                BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available), label: 'Events'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().currentUser;
    final userName = user?.displayName?.split(' ').first ?? 'Student';
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E21), Color(0xFF1A1A3A), Color(0xFF2D1B4E)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildGlassAppBar(userName),
              
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Next Class Card
                    NextClassWidget(
                      studentLevel: _studentLevel,
                      studentSemester: _studentSemester,
                      studentId: user?.uid ?? '',
                    ),
                    const SizedBox(height: 24),
                    
                    // Today's Schedule Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Schedule",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color:AppColors.vibrantYellow)),
                        if (_todayClasses.isNotEmpty)
                          TextButton(
                            onPressed: () => _navigateTo('timetable'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.electricPurple,
                              backgroundColor: AppColors.electricPurple.withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('View All', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _isLoading ? const Center(child: CircularProgressIndicator()) : _buildTodaySchedule(),
                    _buildUpcomingSchedule(),
                    const SizedBox(height: 28),
                    
                    // Announcements Section
                    const Text('Latest Announcements', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.vibrantYellow)),
                    const SizedBox(height: 12),
                    
                    RoleBasedAnnouncements(
                      userRole: 'student',
                      userId: user?.uid ?? '',
                      userName: userName,
                      showViewAll: true,
                      limit: 2,
                      showCreateButton: false,
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Quick Access Section
                    const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 16),
                    
                    // Quick Access Row 1
                    Row(children: [
                      _buildQuickActionCard(icon: Icons.schedule, title: 'Timetable', color: AppColors.electricPurple, onTap: () => _navigateTo('timetable')),
                      const SizedBox(width: 14),
                      _buildQuickActionCard(icon: Icons.event_available, title: 'Events', color: AppColors.success, onTap: () => _navigateTo('register_events')),
                      const SizedBox(width: 14),
                      _buildQuickActionCard(icon: Icons.map, title: 'Map', color: Colors.pinkAccent, onTap: () => _navigateTo('map')),
                      const SizedBox(width: 14),
                      _buildQuickActionCard(icon: Icons.list_alt, title: 'My Events', color: AppColors.vibrantYellow, onTap: () => _navigateTo('my_events')),

                    ]),
                    const SizedBox(height: 14),
                    
                    
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(),
    );
  }
}