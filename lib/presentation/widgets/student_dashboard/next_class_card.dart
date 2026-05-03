// lib/presentation/widgets/student_dashboard/next_class_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class NextClassCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // MOCK DATA - Directly show this class
    // This will always display regardless of Firebase
    return _buildMockClassCard();
  }

  Widget _buildMockClassCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.vibrantYellow,
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.vibrantYellow, AppColors.vibrantYellow.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Tomorrow · 9 hours 30 min',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Class Name
          Text(
            'ITE 2002 – Cyber Security',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Time
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '9:00 AM – 11:00 AM',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '13 · Hall',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Lecturer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Eng. Kli',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
                  'Theory',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}