// lib/presentation/screens/announcements/announcement_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/announce/announcement_model.dart';


class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;
  
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          announcement.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type and priority badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: announcement.priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 14, color: announcement.priorityColor),
                      const SizedBox(width: 4),
                      Text(
                        announcement.priority.toUpperCase(),
                        style: TextStyle(color: announcement.priorityColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.electricPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(announcement.typeIcon, size: 14, color: AppColors.electricPurple),
                      const SizedBox(width: 4),
                      Text(
                        announcement.type.toUpperCase(),
                        style: const TextStyle(color: AppColors.electricPurple, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.audienceLabel,
                    style: const TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Metadata
            Row(
              children: [
                Icon(
                  announcement.createdByRole == 'academic_staff' ? Icons.school : Icons.business,
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  'By ${announcement.createdByName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(announcement.createdAt),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Content
            Text(
              announcement.content,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 30),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white54),
                      const SizedBox(height: 4),
                      Text(
                        '${announcement.readBy.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Text('Read', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  if (announcement.reactions != null)
                    Column(
                      children: [
                        const Icon(Icons.thumb_up, color: Colors.white54),
                        const SizedBox(height: 4),
                        Text(
                          '${announcement.reactions!.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Text('Reactions', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
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