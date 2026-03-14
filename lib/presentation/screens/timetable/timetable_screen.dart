import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildDaySchedule('Monday', ['CS301 - 9:00 AM', 'CS302 - 11:00 AM', 'Lab - 2:00 PM']),
            const SizedBox(height: 12),
            _buildDaySchedule('Tuesday', ['CS303 - 8:00 AM', 'CS304 - 10:00 AM']),
            const SizedBox(height: 12),
            _buildDaySchedule('Wednesday', ['CS305 - 9:00 AM', 'Workshop - 2:00 PM']),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, List<String> classes) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.electricPurple,
            ),
          ),
          const SizedBox(height: 8),
          ...classes.map((c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  c,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}