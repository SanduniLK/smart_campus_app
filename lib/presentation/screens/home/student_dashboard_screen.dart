import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/screens/time_table/student_timetable_screen.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/announcements_list.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/next_class_card.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/progress_stats.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/quick_access_grid.dart';
import 'package:smart_campus_app/presentation/widgets/student_dashboard/welcome_header.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';


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
        
        // Get all timetable
        final allTimetable = await _db.getAllTimetable();
        
        // Filter by student's level and semester
        final filteredTimetable = allTimetable.where((entry) {
          return entry['level'] == _studentLevel && 
                 entry['semester'] == _studentSemester;
        }).toList();
        
        // Get today's classes
        final today = DateTime.now().weekday;
        final currentDay = today == 7 ? 6 : today;
        _todayClasses = filteredTimetable
            .where((entry) => entry['dayOfWeek'] == currentDay)
            .toList();
        
        // Get upcoming classes (future days)
        _upcomingClasses = filteredTimetable
            .where((entry) => entry['dayOfWeek'] > currentDay)
            .toList();
        
        // Sort by day
        _upcomingClasses.sort((a, b) => a['dayOfWeek'].compareTo(b['dayOfWeek']));
      }
    } catch (e) {
      print('Error loading data: $e');
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

  void _navigateToTimetable() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentTimetableScreen(),
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> entry, {bool isUpcoming = false}) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isOngoing = !isUpcoming && _isTimeBetween(currentTime, entry['startTime'], entry['endTime']);
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderColor: isOngoing ? AppColors.vibrantYellow : null,
      borderWidth: isOngoing ? 1.5 : 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Day/Time Column
            Container(
              width: isUpcoming ? 70 : 60,
              child: isUpcoming
                  ? Column(
                      children: [
                        Text(
                          _getDayName(entry['dayOfWeek']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.vibrantYellow,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry['startTime'],
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          entry['startTime'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOngoing ? AppColors.vibrantYellow : Colors.white,
                            fontSize: 14,
                          ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lecturer: ${entry['lecturerName']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${entry['roomNumber']}, ${entry['building'] ?? ''}',
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantYellow,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    if (_todayClasses.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                'No classes today!',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your free day',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: _todayClasses.map((cls) => _buildClassCard(cls)).toList(),
    );
  }

  Widget _buildUpcomingSchedule() {
    if (_upcomingClasses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Show only next 3 upcoming classes
    final displayClasses = _upcomingClasses.take(3).toList();
    final hasMore = _upcomingClasses.length > 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.vibrantYellow),
            const SizedBox(width: 8),
            Text(
              'Upcoming Lectures',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.vibrantYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayClasses.map((cls) => _buildClassCard(cls, isUpcoming: true)).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: _navigateToTimetable,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Show More'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.electricPurple,
                ),
              ),
            ),
          ),
      ],
    );
  }

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
              
              // Next Class Card
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
              
              // Progress Stats
              const ProgressStats(),
              const SizedBox(height: 24),
              
              // Today's Schedule Section
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Schedule",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToTimetable,
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
                    const SizedBox(height: 12),
                    _buildTodaySchedule(),
                    
                    // Upcoming Section
                    _buildUpcomingSchedule(),
                  ],
                ),
              const SizedBox(height: 24),
              
              // QUICK ACCESS Section
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
                onTimetableTap: _navigateToTimetable,
                onCampusMapTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Campus Map Coming Soon')),
                  );
                },
                onQRPassTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Pass Coming Soon')),
                  );
                },
                onEventsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Events Coming Soon')),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Announcements List
              AnnouncementsList(
                onViewAll: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}