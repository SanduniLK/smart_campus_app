import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/student_model/dashboard_models.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';


class TodaySchedule extends StatelessWidget {
  final VoidCallback onViewAll;

  const TodaySchedule({super.key, required this.onViewAll});

  List<ClassModel> _getClasses() {
    return [
      ClassModel(
        code: 'CS301',
        name: 'Database Systems',
        time: '09:00 - 10:30',
        room: 'Room 203',
        lecturer: 'Dr. Perera',
        isNext: true,
      ),
      ClassModel(
        code: 'CS302',
        name: 'Mobile App Dev',
        time: '11:00 - 12:30',
        room: 'Lab 105',
        lecturer: 'Prof. Wijesinghe',
      ),
      ClassModel(
        code: 'CS303',
        name: 'Software Eng',
        time: '14:00 - 15:30',
        room: 'Room 301',
        lecturer: 'Dr. Fernando',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: onViewAll,
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
        ..._getClasses().map((cls) => _buildClassCard(cls)).toList(),
      ],
    );
  }

  Widget _buildClassCard(ClassModel cls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: cls.isNext ? AppColors.vibrantYellow : null,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: cls.isNext ? AppColors.vibrantYellow : AppColors.electricPurple,
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
                        cls.code,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cls.isNext ? AppColors.vibrantYellow : AppColors.electricPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (cls.isNext)
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
                    cls.name,
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
                      Text(cls.time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(cls.room, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
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
              child: Text(
                cls.lecturer.split(' ').last,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}