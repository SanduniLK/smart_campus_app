import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/student_model/dashboard_models.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';


class AnnouncementsList extends StatelessWidget {
  final VoidCallback onViewAll;

  const AnnouncementsList({super.key, required this.onViewAll});

  List<AnnouncementModel> _getAnnouncements() {
    return [
      AnnouncementModel(
        emoji: '📢',
        title: 'University Holiday',
        description: 'University closed on 25th December',
        time: '2 hours ago',
      ),
      AnnouncementModel(
        emoji: '⚠️',
        title: 'System Maintenance',
        description: 'Portal down tonight 10PM-12AM',
        time: '5 hours ago',
        isUrgent: true,
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
              'Announcements',
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
        ..._getAnnouncements().map((ann) => _buildAnnouncementCard(ann)),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel ann) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: ann.isUrgent ? AppColors.vibrantYellow : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (ann.isUrgent ? AppColors.vibrantYellow : AppColors.electricPurple)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(ann.emoji, style: const TextStyle(fontSize: 20)),
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
                          ann.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (ann.isUrgent)
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
                    ann.description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ann.time,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}