// lib/presentation/widgets/student_dashboard/progress_stats.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class ProgressStats extends StatelessWidget {
  const ProgressStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '85%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricPurple,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                const Text('+5% this month', style: TextStyle(fontSize: 10, color: Colors.green)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Text(
                  'GPA',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '3.6',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantYellow,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('First Class Honors', style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Text(
                  'Events',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '12',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Registered', style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}