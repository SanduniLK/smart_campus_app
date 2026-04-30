// lib/presentation/widgets/staff_dashboard/recent_announcements_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class RecentAnnouncementsWidget extends StatelessWidget {
  final VoidCallback? onPostNew;

  const RecentAnnouncementsWidget({super.key, this.onPostNew});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Announcements',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: onPostNew,
              child: Text(
                'Post New',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAnnouncementCard(
          emoji: '📢',
          title: 'Faculty Meeting',
          description: 'Department meeting on Friday at 10:00 AM in Conference Room',
          time: '30 mins ago',
        ),
        const SizedBox(height: 12),
        _buildAnnouncementCard(
          emoji: '⚠️',
          title: 'System Maintenance',
          description: 'LMS will be down tonight from 10 PM to 12 AM',
          time: '2 hours ago',
          isUrgent: true,
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required String emoji,
    required String title,
    required String description,
    required String time,
    bool isUrgent = false,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderColor: isUrgent ? AppColors.vibrantYellow : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isUrgent ? AppColors.vibrantYellow : AppColors.electricPurple)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.vibrantYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
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
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.more_vert_rounded,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }
}