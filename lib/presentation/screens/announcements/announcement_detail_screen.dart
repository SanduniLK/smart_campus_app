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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Priority Badge
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
                
                // Type Badge
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
                
                // Audience Badge
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
            
            // Title
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Metadata
            Row(
              children: [
                Icon(
                  announcement.createdByRole == 'academic_staff' ? Icons.school : 
                  announcement.createdByRole == 'non_academic_staff' ? Icons.business : Icons.person,
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
            
            const SizedBox(height: 24),
            
            // Divider
            const Divider(color: Colors.white24, height: 1),
            
            const SizedBox(height: 24),
            
            // Content
            Text(
              announcement.content,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Read count
                  Column(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, color: Colors.white54, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '${announcement.readBy.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Text('Read', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  
                  // Reaction count (safe check with null)
                  if (announcement.reactions != null && announcement.reactions!.isNotEmpty)
                    Column(
                      children: [
                        const Icon(Icons.thumb_up_outlined, color: Colors.white54, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '${announcement.reactions!.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text('Reactions', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}