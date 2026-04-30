// lib/presentation/widgets/staff_dashboard/pending_tasks_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class PendingTasksWidget extends StatelessWidget {
  const PendingTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Tasks',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          title: 'Grade Assignment Submissions',
          subtitle: 'CS301 - Database Systems',
          dueDate: 'Due in 2 days',
          count: '5 pending',
          icon: Icons.grading_rounded,
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          title: 'Approve Leave Requests',
          subtitle: 'Faculty Leave Applications',
          dueDate: 'Due today',
          count: '3 requests',
          icon: Icons.event_available_rounded,
          isUrgent: true,
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          title: 'Prepare Lecture Notes',
          subtitle: 'CS302 - Mobile Development',
          dueDate: 'Due tomorrow',
          count: 'In progress',
          icon: Icons.note_alt_rounded,
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required String dueDate,
    required String count,
    required IconData icon,
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
            child: Icon(
              icon,
              color: isUrgent ? AppColors.vibrantYellow : AppColors.electricPurple,
              size: 20,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isUrgent ? AppColors.vibrantYellow : AppColors.electricPurple)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        count,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: isUrgent ? AppColors.vibrantYellow : AppColors.electricPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: isUrgent ? AppColors.vibrantYellow : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dueDate,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isUrgent ? AppColors.vibrantYellow : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}