// lib/presentation/screens/announcements/announcements_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';


class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.electricPurple,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.electricPurple,
          tabs: const [
            Tab(text: 'ALL', icon: Icon(Icons.list_alt)),
            Tab(text: 'ACADEMIC', icon: Icon(Icons.school)),
            Tab(text: 'EVENTS', icon: Icon(Icons.event)),
            Tab(text: 'DEADLINES', icon: Icon(Icons.alarm)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsList('all'),
          _buildAnnouncementsList('academic'),
          _buildAnnouncementsList('event'),
          _buildAnnouncementsList('deadline'),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList(String type) {
    Query query = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true);

    if (type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'No announcements found',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back later for updates',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        final announcements = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final data = announcements[index].data() as Map<String, dynamic>;
            return _buildAnnouncementCard(
              id: announcements[index].id,
              title: data['title'] ?? '',
              content: data['content'] ?? '',
              type: data['type'] ?? 'general',
              priority: data['priority'] ?? 'normal',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              createdByName: data['createdByName'] ?? 'Admin',
              readBy: List<String>.from(data['readBy'] ?? []),
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementCard({
    required String id,
    required String title,
    required String content,
    required String type,
    required String priority,
    required DateTime createdAt,
    required String createdByName,
    required List<String> readBy,
  }) {
    final isUrgent = priority == 'urgent';
    final priorityColor = priority == 'urgent' ? Colors.red : 
                         (priority == 'high' ? Colors.orange : AppColors.electricPurple);
    
    return GestureDetector(
      onTap: () => _showAnnouncementDetail(id, title, content, type, priority, createdAt, createdByName),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.glassSurface,
              AppColors.glassSurface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? Colors.red : Colors.white24,
            width: isUrgent ? 1.5 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with badges
              Row(
                children: [
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent ? Icons.warning : Icons.flag,
                          size: 12,
                          color: priorityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == 'academic' ? Icons.school :
                          type == 'event' ? Icons.event :
                          type == 'deadline' ? Icons.alarm : Icons.announcement,
                          size: 12,
                          color: AppColors.electricPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.electricPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Date
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                content,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 12, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    createdByName,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    '${readBy.length} reads',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _showAnnouncementDetail(String id, String title, String content, String type, 
      String priority, DateTime createdAt, String createdByName) async {
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
                
                // Title
                Text(
                  title,
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
                
                // Content
                Text(
                  content,
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

