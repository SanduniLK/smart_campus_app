import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class AnnouncementsList extends StatelessWidget {
  final VoidCallback onViewAll;

  const AnnouncementsList({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANNOUNCEMENTS',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const AnnouncementCard(
          title: 'Exam timetable released – Semester 2',
          time: '2 min ago',
          isUrgent: true,
        ),
        const SizedBox(height: 12),
        const AnnouncementCard(
          title: 'Library extended hours until 10 PM',
          time: '1 hr ago',
          isUrgent: false,
        ),
        const SizedBox(height: 12),
        const AnnouncementCard(
          title: 'Tech Expo 2026 – closes Friday',
          time: '3 hrs ago',
          isUrgent: false,
        ),
      ],
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String time;
  final bool isUrgent;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.time,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? AppColors.error.withValues(alpha: 0.3) : AppColors.cardBorder,
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.error : AppColors.electricPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'URGENT',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}