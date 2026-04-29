import 'package:flutter/material.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

import '../../../core/constants/app_colors.dart';

class TimetableCard extends StatelessWidget {
  final String courseCode;
  final String courseName;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String building;
  final String lecturerName;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TimetableCard({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.building,
    required this.lecturerName,
    required this.type,
    this.onTap,
    this.onDelete,
  });

  Color _getTypeColor() {
    switch (type) {
      case 'Lecture': return AppColors.electricPurple;
      case 'Lab': return AppColors.success;
      case 'Tutorial': return AppColors.vibrantYellow;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(courseCode + startTime),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Time Column
              Container(
                width: 65,
                child: Column(
                  children: [
                    Text(startTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    Text(endTime, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
              const VerticalDivider(color: Colors.white24),
              const SizedBox(width: 12),
              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(courseCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(type, style: TextStyle(fontSize: 10, color: _getTypeColor())),
                        ),
                      ],
                    ),
                    Text(courseName, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text('$roomNumber, $building', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        const SizedBox(width: 12),
                        const Icon(Icons.person, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Expanded(child: Text(lecturerName, style: const TextStyle(fontSize: 11, color: Colors.white54))),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}