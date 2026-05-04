// lib/presentation/widgets/student_dashboard/next_class_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class NextClassWidget extends StatefulWidget {
  final String studentLevel;
  final String studentSemester;
  final String studentId;

  const NextClassWidget({
    super.key,
    required this.studentLevel,
    required this.studentSemester,
    required this.studentId,
  });

  @override
  State<NextClassWidget> createState() => _NextClassWidgetState();
}

class _NextClassWidgetState extends State<NextClassWidget> with TickerProviderStateMixin {
  Map<String, dynamic>? _nextClass;
  bool _isLoading = true;
  final DatabaseService _db = DatabaseService();
  
  // Animation Controllers - Pure Yellow Animation
  late AnimationController _yellowAnimationController;
  late Animation<double> _yellowPulseScale;
  late Animation<double> _yellowGlowIntensity;
  late Animation<double> _yellowBorderWidth;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _findNextClass();
    
    // Pure Yellow Pulsing Animation
    _yellowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _yellowPulseScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _yellowAnimationController, curve: Curves.easeInOut),
    );
    
    _yellowGlowIntensity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _yellowAnimationController, curve: Curves.easeInOut),
    );
    
    _yellowBorderWidth = Tween<double>(begin: 2.0, end: 4.0).animate(
      CurvedAnimation(parent: _yellowAnimationController, curve: Curves.easeInOut),
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _findNextClass();
    });
  }

  @override
  void dispose() {
    _yellowAnimationController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _findNextClass() async {
    try {
      final now = DateTime.now();
      final currentDay = now.weekday == 7 ? 6 : now.weekday;
      final currentTime = _getTimeInMinutes(now);
      
      final allTimetable = await _db.getAllTimetable();
      
      final todayClasses = allTimetable.where((entry) {
        return entry['level'] == widget.studentLevel &&
               entry['semester'] == widget.studentSemester &&
               entry['dayOfWeek'] == currentDay;
      }).toList();
      
      todayClasses.sort((a, b) => a['startTime'].compareTo(b['startTime']));
      
      if (todayClasses.isEmpty) {
        await _findNextDayClass(now);
        return;
      }
      
      Map<String, dynamic>? currentOrNextClass;
      String status = '';
      
      for (var classEntry in todayClasses) {
        final startTimeMinutes = _timeStringToMinutes(classEntry['startTime']);
        final endTimeMinutes = _timeStringToMinutes(classEntry['endTime']);
        
        if (currentTime < startTimeMinutes) {
          currentOrNextClass = classEntry;
          status = 'UPCOMING';
          break;
        } else if (currentTime >= startTimeMinutes && currentTime <= endTimeMinutes) {
          currentOrNextClass = classEntry;
          status = 'ONGOING';
          break;
        }
      }
      
      if (currentOrNextClass == null) {
        await _findNextDayClass(now);
      } else {
        _updateClassData(currentOrNextClass, status, currentTime);
      }
      
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _findNextDayClass(DateTime now) async {
    for (int daysAhead = 1; daysAhead <= 7; daysAhead++) {
      final nextDate = now.add(Duration(days: daysAhead));
      final nextDay = nextDate.weekday == 7 ? 6 : nextDate.weekday;
      
      final allTimetable = await _db.getAllTimetable();
      
      final nextDayClasses = allTimetable.where((entry) {
        return entry['level'] == widget.studentLevel &&
               entry['semester'] == widget.studentSemester &&
               entry['dayOfWeek'] == nextDay;
      }).toList();
      
      if (nextDayClasses.isNotEmpty) {
        nextDayClasses.sort((a, b) => a['startTime'].compareTo(b['startTime']));
        final firstClass = nextDayClasses.first;
        
        final dayName = _getDayName(nextDate.weekday);
        final startTime = firstClass['startTime'];
        
        final nowMinutes = _getTimeInMinutes(now);
        final targetMinutes = _timeStringToMinutes(startTime);
        final minutesRemaining = (daysAhead * 24 * 60) + (targetMinutes - nowMinutes);
        
        _updateFutureClassData(firstClass, dayName, minutesRemaining);
        return;
      }
    }
    
    setState(() {
      _nextClass = null;
      _isLoading = false;
    });
  }

  int _getTimeInMinutes(DateTime time) {
    return time.hour * 60 + time.minute;
  }

  int _timeStringToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  void _updateClassData(Map<String, dynamic> classData, String status, int currentTime) {
    final startTimeMinutes = _timeStringToMinutes(classData['startTime']);
    final endTimeMinutes = _timeStringToMinutes(classData['endTime']);
    
    int minutesRemaining = 0;
    String displayStatus = status;
    Color statusColor;
    IconData statusIcon;
    
    if (status == 'ONGOING') {
      minutesRemaining = endTimeMinutes - currentTime;
      statusColor = Colors.green;
      statusIcon = Icons.play_circle;
    } else if (status == 'UPCOMING') {
      minutesRemaining = startTimeMinutes - currentTime;
      if (minutesRemaining <= 15) {
        statusColor = Colors.red;
        statusIcon = Icons.timer;
        displayStatus = 'STARTING SOON';
      } else {
        statusColor = AppColors.vibrantYellow;
        statusIcon = Icons.schedule;
        displayStatus = 'NEXT CLASS';
      }
    } else {
      statusColor = AppColors.vibrantYellow;
      statusIcon = Icons.event;
    }
    
    setState(() {
      _nextClass = {
        'courseId': classData['courseId'],
        'courseName': classData['courseName'],
        'lecturerName': classData['lecturerName'],
        'startTime': _convertTo12HourFormat(classData['startTime']),
        'endTime': _convertTo12HourFormat(classData['endTime']),
        'roomNumber': classData['roomNumber'],
        'building': classData['building'] ?? 'Main Building',
        'minutesRemaining': minutesRemaining,
        'status': displayStatus,
        'statusColor': statusColor,
        'statusIcon': statusIcon,
      };
      _isLoading = false;
    });
  }

  void _updateFutureClassData(Map<String, dynamic> classData, String dayName, int minutesRemaining) {
    setState(() {
      _nextClass = {
        'courseId': classData['courseId'],
        'courseName': classData['courseName'],
        'lecturerName': classData['lecturerName'],
        'startTime': '${_convertTo12HourFormat(classData['startTime'])} ($dayName)',
        'endTime': _convertTo12HourFormat(classData['endTime']),
        'roomNumber': classData['roomNumber'],
        'building': classData['building'] ?? 'Main Building',
        'minutesRemaining': minutesRemaining,
        'status': 'UPCOMING',
        'statusColor': AppColors.electricPurple,
        'statusIcon': Icons.event,
      };
      _isLoading = false;
    });
  }

  String _convertTo12HourFormat(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  String _getDayName(int weekday) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[weekday] ?? 'Monday';
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return 'Now';
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours hour${hours > 1 ? 's' : ''}';
      return '$hours hr $mins min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GlassCard(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.electricPurple),
            const SizedBox(height: 12),
            Text('Finding your next class...', 
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }
    
    if (_nextClass == null) {
      return GlassCard(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.free_breakfast, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text('No classes scheduled!', 
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Enjoy your break', 
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
    }
    
    final classData = _nextClass!;
    final minutesRemaining = classData['minutesRemaining'];
    final status = classData['status'];
    final statusColor = classData['statusColor'];
    final statusIcon = classData['statusIcon'];
    final isOngoing = status == 'ONGOING';
    final isStartingSoon = status == 'STARTING SOON';
    final isNextClass = status == 'NEXT CLASS';
    
    // Only show yellow animation for NEXT CLASS
    final showYellowAnimation = isNextClass;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        if (showYellowAnimation) _yellowAnimationController,
        _slideController, 
        _fadeController
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: showYellowAnimation ? _yellowPulseScale.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    if (showYellowAnimation)
                      BoxShadow(
                        color: AppColors.vibrantYellow.withValues(alpha: _yellowGlowIntensity.value * 0.6),
                        blurRadius: 25 * _yellowGlowIntensity.value,
                        spreadRadius: 5 * _yellowGlowIntensity.value,
                      ),
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: showYellowAnimation
                        ? Border.all(
                            color: AppColors.vibrantYellow,
                            width: _yellowBorderWidth.value,
                          )
                        : null,
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: showYellowAnimation ? AppColors.vibrantYellow : statusColor,
                    borderWidth: showYellowAnimation ? _yellowBorderWidth.value : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isNextClass || isStartingSoon
                                  ? [AppColors.vibrantYellow.withValues(alpha: 0.25), AppColors.vibrantYellow.withValues(alpha: 0.1)]
                                  : [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isNextClass || isStartingSoon ? AppColors.vibrantYellow : statusColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 18, color: isNextClass ? AppColors.vibrantYellow : statusColor),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isNextClass ? AppColors.vibrantYellow : statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (!isOngoing && minutesRemaining > 0 && minutesRemaining <= 60) ...[
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isNextClass ? AppColors.vibrantYellow : statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  _formatMinutes(minutesRemaining),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isNextClass ? AppColors.vibrantYellow : statusColor,
                                  ),
                                ),
                              ],
                              if (isOngoing && minutesRemaining > 0) ...[
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  '${_formatMinutes(minutesRemaining)} left',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Attention Message
                        if (isNextClass || isStartingSoon)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.touch_app, size: 16, color: AppColors.vibrantYellow),
                                const SizedBox(width: 8),
                                Text(
                                  isStartingSoon ? '⚠️ GET READY! CLASS STARTING SOON' : '👉 YOUR NEXT CLASS IS HERE!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.vibrantYellow,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Course Name
                        Text(
                          '${classData['courseId']} – ${classData['courseName']}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Time
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: isNextClass ? AppColors.vibrantYellow : Colors.white54),
                            const SizedBox(width: 8),
                            Text(
                              '${classData['startTime']} – ${classData['endTime']}',
                              style: GoogleFonts.poppins(
                                fontSize: 14, 
                                color: isNextClass ? AppColors.vibrantYellow : Colors.white70,
                                fontWeight: isNextClass ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: isNextClass ? AppColors.vibrantYellow : Colors.white54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${classData['roomNumber']} • ${classData['building']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14, 
                                  color: isNextClass ? AppColors.vibrantYellow : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Lecturer
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: isNextClass ? AppColors.vibrantYellow : Colors.white54),
                            const SizedBox(width: 8),
                            Text(
                              classData['lecturerName'],
                              style: GoogleFonts.poppins(
                                fontSize: 14, 
                                color: isNextClass ? AppColors.vibrantYellow : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        
                        // Action Button
                        if (isNextClass || isStartingSoon)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [AppColors.vibrantYellow, AppColors.vibrantYellow.withValues(alpha: 0.8)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.vibrantYellow.withValues(alpha: _yellowGlowIntensity.value * 0.5),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('📍 Head to ${classData['roomNumber']} - ${classData['building']}'),
                                      backgroundColor: AppColors.vibrantYellow,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      isStartingSoon ? 'GO TO CLASS NOW →' : 'VIEW CLASS LOCATION →',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}