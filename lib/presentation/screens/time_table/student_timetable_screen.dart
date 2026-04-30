// lib/presentation/screens/student/student_timetable_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  String _studentLevel = '';
  String _studentSemester = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _timetable = [];
  int _selectedDay = DateTime.now().weekday;
  
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    final firebaseService = FirebaseService();
    final user = firebaseService.currentUser;
    
    if (user != null) {
      final db = DatabaseService();
      final studentDetails = await db.getStudentDetails(user.uid);
      
      if (studentDetails != null) {
        setState(() {
          _studentLevel = studentDetails['level'] ?? 'Year 3';
          _studentSemester = studentDetails['currentSemester'] ?? 'Semester 1';
          _isLoading = false;
        });
        await _loadTimetable();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTimetable() async {
    final db = DatabaseService();
    final allTimetable = await db.getAllTimetable();
    
    // Filter by student's level and semester
    final filteredTimetable = allTimetable.where((entry) {
      return entry['level'] == _studentLevel && 
             entry['semester'] == _studentSemester;
    }).toList();
    
    setState(() {
      _timetable = filteredTimetable;
    });
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

  List<Map<String, dynamic>> _getTimetableForDay(int day) {
    return _timetable.where((entry) => entry['dayOfWeek'] == day).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final todayTimetable = _getTimetableForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Timetable', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildInfoHeader(),
        ),
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          const SizedBox(height: 16),
          Expanded(
            child: todayTimetable.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todayTimetable.length,
                    itemBuilder: (context, index) {
                      return _buildTimetableCard(todayTimetable[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Level',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 4),
              Text(
                _studentLevel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.vibrantYellow),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your Semester',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 4),
              Text(
                _studentSemester,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.vibrantYellow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_days.length, (index) {
          final dayNumber = index + 1;
          final hasClasses = _getTimetableForDay(dayNumber).isNotEmpty;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                _days[index],
                style: TextStyle(
                  color: _selectedDay == dayNumber ? Colors.white : Colors.white70,
                  fontWeight: hasClasses ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: _selectedDay == dayNumber,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedDay = dayNumber);
                }
              },
              backgroundColor: AppColors.glassSurface,
              selectedColor: AppColors.electricPurple,
              avatar: hasClasses
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimetableCard(Map<String, dynamic> entry) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isOngoing = _isTimeBetween(currentTime, entry['startTime'], entry['endTime']);
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      borderColor: isOngoing ? AppColors.vibrantYellow : null,
      borderWidth: isOngoing ? 2 : 1,
      child: Row(
        children: [
          // Time Column
          SizedBox(
            width: 70,
            child: Column(
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
          Container(width: 1, height: 60, color: Colors.white24),
          const SizedBox(width: 12),
          
          // Course Details
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
                ),
                const SizedBox(height: 4),
                Text(
                  'Lecturer: ${entry['lecturerName']}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${entry['roomNumber']}, ${entry['building'] ?? ''}',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ongoing Badge
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled for $_studentLevel - $_studentSemester',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check other days or contact your department',
            style: TextStyle(fontSize: 12, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}