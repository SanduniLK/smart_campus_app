import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class NextClassCard extends StatefulWidget {
  final String studentLevel;
  final String studentSemester;
  final String studentId;

  const NextClassCard({
    super.key,
    required this.studentLevel,
    required this.studentSemester,
    required this.studentId,
  });

  @override
  State<NextClassCard> createState() => _NextClassCardState();
}

class _NextClassCardState extends State<NextClassCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;
  
  // Real data from Firebase
  String _className = 'Loading...';
  String _startTime = '--:-- --';
  String _endTime = '--:-- --';
  String _location = 'Loading...';
  String _room = '--';
  String _building = '--';
  String _floor = '--';
  String _professor = 'Loading...';
  String _type = '--';
  int _minutesRemaining = 0;
  String _dayInfo = '';
  
  bool _isLoading = true;
  bool _hasClass = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _colorAnimation = ColorTween(
      begin: AppColors.electricPurple.withValues(alpha: 0.5),
      end: AppColors.vibrantYellow,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _fetchNextClassFromFirebase();
    
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _fetchNextClassFromFirebase();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Convert weekday number to day name
  String _getDayNameFromInt(int dayOfWeek) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday', 
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[dayOfWeek] ?? 'Monday';
  }

  String _getDayShortName(int dayOfWeek) {
    const days = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return days[dayOfWeek] ?? 'Mon';
  }

  Future<void> _fetchNextClassFromFirebase() async {
    try {
      final now = DateTime.now();
      final currentDayOfWeek = now.weekday; // Monday=1, Sunday=7
      final currentTime = _formatTime(now);
      
      print('🔍 Looking for first upcoming class in next 3 days...');
      print('📅 Current time: $currentTime');
      print('📅 Current day number: $currentDayOfWeek (${_getDayNameFromInt(currentDayOfWeek)})');
      print('📚 Student Level: ${widget.studentLevel}, Semester: ${widget.studentSemester}');
      
      Map<String, dynamic>? foundClass;
      int? foundDaysAhead;
      String? foundDayName;
      int? foundMinutesRemaining;
      
      // Check next 3 days (today, tomorrow, day after tomorrow)
      for (int daysAhead = 0; daysAhead <= 2; daysAhead++) {
        final checkDate = now.add(Duration(days: daysAhead));
        final targetDayOfWeek = checkDate.weekday;
        final dayName = daysAhead == 0 ? 'Today' : (daysAhead == 1 ? 'Tomorrow' : _getDayShortName(targetDayOfWeek));
        
        print('📅 Checking $dayName (Day number: $targetDayOfWeek)');
        
        // Query Firebase for classes on this day
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('timetable')
            .where('level', isEqualTo: widget.studentLevel)
            .where('semester', isEqualTo: widget.studentSemester)
            .where('dayOfWeek', isEqualTo: targetDayOfWeek)
            .orderBy('startTime')
            .get();
        
        print('   Found ${snapshot.docs.length} classes for $dayName');
        
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final startTime = data['startTime'] ?? '00:00';
            
            // For today, only show classes that haven't started yet
            if (daysAhead == 0) {
              if (startTime.compareTo(currentTime) > 0) {
                foundClass = data;
                foundDaysAhead = daysAhead;
                foundDayName = dayName;
                foundMinutesRemaining = _calculateMinutesDifference(currentTime, startTime);
                print('✅ Found today\'s class: ${data['courseName']} at $startTime (${foundMinutesRemaining} min from now)');
                break;
              } else {
                print('   Skipping past class: ${data['courseName']} at $startTime');
              }
            } else {
              // For future days, take the first class of the day
              foundClass = data;
              foundDaysAhead = daysAhead;
              foundDayName = dayName;
              foundMinutesRemaining = _calculateFutureDayMinutes(daysAhead, startTime);
              print('✅ Found class on $dayName: ${data['courseName']} at $startTime');
              break;
            }
          }
        }
        
        if (foundClass != null) break;
      }
      
      if (foundClass != null) {
        _updateUIWithClassData(foundClass, foundMinutesRemaining!, foundDayName!);
      } else {
        print('❌ No classes found in the next 3 days');
        setState(() {
          _className = 'No upcoming classes';
          _isLoading = false;
          _hasClass = false;
        });
      }
      
    } catch (e) {
      print('❌ Error fetching next class: $e');
      setState(() {
        _className = 'Unable to load schedule';
        _isLoading = false;
        _hasClass = false;
      });
    }
  }

  void _updateUIWithClassData(Map<String, dynamic> data, int minutesRemaining, String dayInfo) {
    final String courseId = data['courseId'] ?? '';
    final String courseName = data['courseName'] ?? '';
    
    // Determine class type
    String type = 'Theory';
    if (courseId.contains('LAB') || courseId.contains('PRAC') || courseId.contains('lab')) {
      type = 'Practical';
    } else if (courseId.contains('TUT') || courseId.contains('tut')) {
      type = 'Tutorial';
    }
    
    // Format location
    final room = data['roomNumber'] ?? 'N/A';
    final building = data['building'] ?? 'Building';
    final floor = data['floor'] ?? '';
    final location = floor.isNotEmpty ? '$room · $building · $floor' : '$room · $building';
    
    // Format times
    String startTime = data['startTime'] ?? '--:--';
    String endTime = data['endTime'] ?? '--:--';
    
    // Convert to 12-hour format
    startTime = _convertTo12HourFormat(startTime);
    endTime = _convertTo12HourFormat(endTime);
    
    setState(() {
      _className = '$courseId – $courseName';
      _startTime = startTime;
      _endTime = endTime;
      _location = location;
      _room = room;
      _building = building;
      _floor = floor;
      _professor = data['lecturerName'] ?? 'Staff';
      _type = type;
      _minutesRemaining = minutesRemaining;
      _dayInfo = dayInfo;
      _isLoading = false;
      _hasClass = true;
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String _convertTo12HourFormat(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  int _calculateMinutesDifference(String currentTime, String startTime) {
    try {
      final currentParts = currentTime.split(':');
      final startParts = startTime.split(':');
      
      final currentMinutes = int.parse(currentParts[0]) * 60 + int.parse(currentParts[1]);
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      
      return startMinutes - currentMinutes;
    } catch (e) {
      return 60;
    }
  }
  
  int _calculateFutureDayMinutes(int daysAhead, String startTime) {
    try {
      final startParts = startTime.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      return (daysAhead * 24 * 60) + startMinutes;
    } catch (e) {
      return daysAhead * 24 * 60;
    }
  }
  
  String _formatMinutesRemaining(int minutes) {
    if (minutes <= 0) return 'Now';
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
      return '$hours hr $mins min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Finding your next class...',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!_hasClass) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(Icons.free_breakfast, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                _className,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No classes in the next 3 days!',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your break 🎉',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    
    final isUrgent = _minutesRemaining <= 15 && _minutesRemaining > 0;
    final isToday = _dayInfo == 'Today';
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? Colors.red : AppColors.vibrantYellow).withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: GlassCard(
              borderRadius: 20,
              blurIntensity: 15,
              padding: const EdgeInsets.all(20),
              backgroundColor: (isUrgent ? Colors.red : AppColors.electricPurple).withValues(alpha: 0.3 + (_glowAnimation.value * 0.1)),
              borderColor: isUrgent ? Colors.red : _colorAnimation.value,
              borderWidth: _borderAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUrgent 
                            ? [Colors.red, Colors.red.withValues(alpha: 0.7)]
                            : [AppColors.vibrantYellow, AppColors.vibrantYellow.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isUrgent ? Colors.red : AppColors.vibrantYellow).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: AppColors.background,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_dayInfo · ${_formatMinutesRemaining(_minutesRemaining)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _className,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '$_startTime – $_endTime',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _location,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _professor,
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _type,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.electricPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (isUrgent && isToday)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 14, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Class starting soon! Please head to the venue.',
                                style: TextStyle(fontSize: 11, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}