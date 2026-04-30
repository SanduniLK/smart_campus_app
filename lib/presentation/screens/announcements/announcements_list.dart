// lib/presentation/widgets/student_dashboard/announcements_list.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

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
            const Text(
              'ANNOUNCEMENTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
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
        
        // Real-time announcements stream from Firebase
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Error loading announcements: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const GlassCard(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

            final announcements = snapshot.data!.docs;
            
            return Column(
              children: announcements.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildAnnouncementCard(
                  title: data['title'] ?? '',
                  content: data['content'] ?? '',
                  type: data['type'] ?? 'general',
                  priority: data['priority'] ?? 'normal',
                  createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  createdByName: data['createdByName'] ?? 'Admin',
                  onTap: () => _showAnnouncementDetail(context, data, doc.id),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String type,
    required String priority,
    required DateTime createdAt,
    required String createdByName,
    required VoidCallback onTap,
  }) {
    final isUrgent = priority == 'urgent';
    final priorityColor = priority == 'urgent' ? Colors.red : 
                         (priority == 'high' ? Colors.orange : AppColors.electricPurple);
    
    return GestureDetector(
      onTap: onTap,
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
                style: TextStyle(
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
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
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

  void _showAnnouncementDetail(BuildContext context, Map<String, dynamic> data, String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnnouncementDetailSheet(
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        type: data['type'] ?? 'general',
        priority: data['priority'] ?? 'normal',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdByName: data['createdByName'] ?? 'Admin',
        announcementId: id,
      ),
    );
  }
}

// Detailed announcement bottom sheet
class _AnnouncementDetailSheet extends StatefulWidget {
  final String title;
  final String content;
  final String type;
  final String priority;
  final DateTime createdAt;
  final String createdByName;
  final String announcementId;

  const _AnnouncementDetailSheet({
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdAt,
    required this.createdByName,
    required this.announcementId,
  });

  @override
  State<_AnnouncementDetailSheet> createState() => _AnnouncementDetailSheetState();
}

class _AnnouncementDetailSheetState extends State<_AnnouncementDetailSheet> {
  bool _isMarkedRead = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    if (_isMarkedRead) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementId)
          .update({
            'readBy': FieldValue.arrayUnion([user.uid])
          });
      _isMarkedRead = true;
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.priority == 'urgent';
    final priorityColor = widget.priority == 'urgent' ? Colors.red : 
                         (widget.priority == 'high' ? Colors.orange : AppColors.electricPurple);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                // Drag handle
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
                
                // Priority and type badges
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
                            widget.priority.toUpperCase(),
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
                            widget.type == 'academic' ? Icons.school :
                            widget.type == 'event' ? Icons.event :
                            widget.type == 'deadline' ? Icons.alarm : Icons.announcement,
                            size: 14,
                            color: AppColors.electricPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.type.toUpperCase(),
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
                
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Metadata
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      widget.createdByName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(widget.createdAt),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                
                const Divider(color: Colors.white24, height: 24),
                
                // Content
                Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Close button
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

