// lib/presentation/widgets/announcements/announcements_section.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/screens/announcements/announcements_screen.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class AnnouncementsSection extends StatelessWidget {
  final bool showViewAll;
  final int limit;
  final String? filterByType;

  const AnnouncementsSection({
    super.key,
    this.showViewAll = true,
    this.limit = 3,
    this.filterByType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ANNOUNCEMENTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            if (showViewAll)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.electricPurple,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _getAnnouncementsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyWidget();
            }

            final announcements = snapshot.data!.docs;
            return Column(
              children: announcements.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildAnnouncementCard(
                  context,
                  id: doc.id,
                  title: data['title'] ?? '',
                  content: data['content'] ?? '',
                  type: data['type'] ?? 'general',
                  priority: data['priority'] ?? 'normal',
                  createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  createdByName: data['createdByName'] ?? 'Admin',
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getAnnouncementsStream() {
    Query query = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true);

    if (filterByType != null) {
      query = query.where('type', isEqualTo: filterByType);
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  Widget _buildAnnouncementCard(
    BuildContext context, {
    required String id,
    required String title,
    required String content,
    required String type,
    required String priority,
    required DateTime createdAt,
    required String createdByName,
  }) {
    final isUrgent = priority == 'urgent';
    final priorityColor = priority == 'urgent' ? Colors.red : 
                         (priority == 'high' ? Colors.orange : AppColors.electricPurple);

    return GestureDetector(
      onTap: () => _showAnnouncementDetail(context, id, title, content, type, priority, createdAt, createdByName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.glassSurface,
              AppColors.glassSurface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? Colors.red : Colors.white24,
            width: isUrgent ? 1 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent ? Icons.warning : Icons.circle,
                          size: 10,
                          color: priorityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTypeLabel(type),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electricPurple,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 10, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    createdByName,
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'academic': return 'ACADEMIC';
      case 'event': return 'EVENT';
      case 'deadline': return 'DEADLINE';
      default: return 'GENERAL';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return DateFormat('MMM dd').format(date);
  }

  void _showAnnouncementDetail(
    BuildContext context,
    String id,
    String title,
    String content,
    String type,
    String priority,
    DateTime createdAt,
    String createdByName,
  ) async {
    // Mark as read
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .update({
            'readBy': FieldValue.arrayUnion([user.uid])
          });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnnouncementDetailSheet(
        title: title,
        content: content,
        type: type,
        priority: priority,
        createdAt: createdAt,
        createdByName: createdByName,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const GlassCard(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return GlassCard(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Error loading announcements',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return GlassCard(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No announcements yet',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

// Detailed announcement bottom sheet
class _AnnouncementDetailSheet extends StatelessWidget {
  final String title;
  final String content;
  final String type;
  final String priority;
  final DateTime createdAt;
  final String createdByName;

  const _AnnouncementDetailSheet({
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdAt,
    required this.createdByName,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = priority == 'urgent';
    final priorityColor = priority == 'urgent' ? Colors.red : 
                         (priority == 'high' ? Colors.orange : AppColors.electricPurple);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUrgent ? Icons.warning : Icons.flag,
                            size: 14,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type == 'academic' ? Icons.school :
                            type == 'event' ? Icons.event :
                            type == 'deadline' ? Icons.alarm : Icons.announcement,
                            size: 14,
                            color: AppColors.electricPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.electricPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      createdByName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

