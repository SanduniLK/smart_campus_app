// lib/presentation/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read, color: Colors.white),
            onPressed: () => _markAllAsRead(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading notifications', style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('New announcements and events will appear here', 
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              return _buildNotificationCard(
                id: notifications[index].id,
                title: data['title'] ?? '',
                body: data['body'] ?? '',
                type: data['type'] ?? 'general',
                priority: data['priority'] ?? 'normal',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isRead: isRead,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required String id,
    required String title,
    required String body,
    required String type,
    required String priority,
    required DateTime createdAt,
    required bool isRead,
  }) {
    final isUrgent = priority == 'urgent';
    final isAnnouncement = type == 'announcement';
    final isEventApproved = type == 'event_approved';
    
    IconData icon;
    Color color;
    
    if (isUrgent) {
      icon = Icons.warning;
      color = Colors.red;
    } else if (isAnnouncement) {
      icon = Icons.announcement;
      color = AppColors.electricPurple;
    } else if (isEventApproved) {
      icon = Icons.event_available;
      color = Colors.green;
    } else {
      icon = Icons.notifications;
      color = AppColors.electricPurple;
    }
    
    return GestureDetector(
      onTap: () => _markAsRead(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isUrgent ? Colors.red.withValues(alpha: 0.15) : AppColors.glassSurface,
              isUrgent ? Colors.red.withValues(alpha: 0.05) : AppColors.glassSurface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? Colors.red : (isRead ? Colors.white24 : color),
            width: isUrgent ? 1.5 : (isRead ? 0.5 : 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead ? Colors.white70 : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 12,
                        color: isRead ? Colors.white54 : Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(createdAt),
                      style: TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Future<void> _markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('user_notifications').doc(id).update({
      'isRead': true,
    });
  }

  Future<void> _markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('user_notifications')
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read'), backgroundColor: Colors.green),
    );
  }
}