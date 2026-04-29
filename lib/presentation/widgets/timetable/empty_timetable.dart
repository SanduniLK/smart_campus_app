import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EmptyTimetable extends StatelessWidget {
  final String message;
  const EmptyTimetable({super.key, this.message = 'No classes scheduled'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}