// lib/presentation/widgets/announcement/role_based_announcements.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

import 'package:firebase_auth/firebase_auth.dart';

// ==================== ROLE BASED ANNOUNCEMENTS WIDGET ====================
class RoleBasedAnnouncements extends StatefulWidget {
  final String userRole;
  final String userId;
  final String userName;
  final bool showViewAll;
  final int limit;
  final bool showCreateButton;

  const RoleBasedAnnouncements({
    super.key,
    required this.userRole,
    required this.userId,
    required this.userName,
    this.showViewAll = true,
    this.limit = 3,
    this.showCreateButton = false,
  });

  @override
  State<RoleBasedAnnouncements> createState() => _RoleBasedAnnouncementsState();
}

class _RoleBasedAnnouncementsState extends State<RoleBasedAnnouncements> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
            Row(
              children: [
                if (widget.showCreateButton)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.electricPurple),
                    onPressed: _showCreateAnnouncementSheet,
                    tooltip: 'Post Announcement',
                  ),
                if (widget.showViewAll)
                  TextButton(
                    onPressed: _navigateToAllAnnouncements,
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
          ],
        ),
        
        // Filter chips for Staff
        if (widget.userRole != 'student' && widget.showViewAll) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Students', 'students'),
                const SizedBox(width: 8),
                _buildFilterChip('Academic Staff', 'academic_staff'),
                const SizedBox(width: 8),
                _buildFilterChip('Non-Academic Staff', 'non_academic_staff'),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Announcements Stream
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
            
            // Filter announcements based on user role and selected filter
            final visibleAnnouncements = announcements.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final targetAudience = data['targetAudience'] ?? 'all';
              
              // Apply role-based visibility
              if (!_isVisibleToRole(targetAudience, widget.userRole)) {
                return false;
              }
              
              // Apply staff filter
              if (widget.userRole != 'student' && _selectedFilter != 'all') {
                return targetAudience == _selectedFilter;
              }
              
              return true;
            }).toList();
            
            if (visibleAnnouncements.isEmpty) {
              return _buildEmptyWidget();
            }
            
            final displayAnnouncements = visibleAnnouncements.take(widget.limit).toList();
            
            return Column(
              children: displayAnnouncements.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildAnnouncementCard(
                  id: doc.id,
                  title: data['title'] ?? '',
                  content: data['content'] ?? '',
                  type: data['type'] ?? 'general',
                  priority: data['priority'] ?? 'normal',
                  targetAudience: data['targetAudience'] ?? 'all',
                  createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  createdByName: data['createdByName'] ?? 'Admin',
                  createdByRole: data['createdByRole'] ?? 'staff',
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.glassSurface,
      selectedColor: AppColors.electricPurple,
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? AppColors.electricPurple : Colors.white24),
      ),
    );
  }

  bool _isVisibleToRole(String targetAudience, String userRole) {
    switch (targetAudience) {
      case 'all':
        return true;
      case 'students':
        return userRole == 'student';
      case 'academic_staff':
        return userRole == 'academic_staff';
      case 'non_academic_staff':
        return userRole == 'non_academic_staff';
      default:
        return true;
    }
  }

  Stream<QuerySnapshot> _getAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _showCreateAnnouncementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAnnouncementSheet(
        userRole: widget.userRole,
        userId: widget.userId,
        userName: widget.userName,
        onCreated: () {
          setState(() {});
        },
      ),
    );
  }

  void _navigateToAllAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllAnnouncementsScreen(
          userRole: widget.userRole,
          userId: widget.userId,
          userName: widget.userName,
          canPost: widget.showCreateButton,
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String id,
    required String title,
    required String content,
    required String type,
    required String priority,
    required String targetAudience,
    required DateTime createdAt,
    required String createdByName,
    required String createdByRole,
  }) {
    final isUrgent = priority == 'urgent';
    final priorityColor = priority == 'urgent' ? Colors.red : 
                         (priority == 'high' ? Colors.orange : AppColors.electricPurple);

    return GestureDetector(
      onTap: () => _showAnnouncementDetail(
        id, title, content, type, priority, targetAudience, createdAt, createdByName, createdByRole,
      ),
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
              // Badges Row
              Row(
                children: [
                  // Priority Badge
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
                          isUrgent ? Icons.warning : Icons.flag,
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
                  // Type Badge
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
                  const SizedBox(width: 8),
                  // Audience Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getAudienceLabel(targetAudience),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Date
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
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
              // Content Preview
              Text(
                content,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Footer
              Row(
                children: [
                  Icon(
                    createdByRole == 'academic_staff' ? Icons.school : 
                    createdByRole == 'non_academic_staff' ? Icons.business : Icons.person,
                    size: 10,
                    color: Colors.white54,
                  ),
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

  String _getAudienceLabel(String audience) {
    switch (audience) {
      case 'students': return 'STUDENTS';
      case 'academic_staff': return 'ACADEMIC STAFF';
      case 'non_academic_staff': return 'NON-ACADEMIC STAFF';
      default: return 'ALL';
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
    String id,
    String title,
    String content,
    String type,
    String priority,
    String targetAudience,
    DateTime createdAt,
    String createdByName,
    String createdByRole,
  ) async {
    // Mark as read
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(id)
        .update({
          'readBy': FieldValue.arrayUnion([widget.userId])
        });

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnouncementDetailSheet(
        title: title,
        content: content,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        createdAt: createdAt,
        createdByName: createdByName,
        createdByRole: createdByRole,
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

// ==================== CREATE ANNOUNCEMENT SHEET ====================
class CreateAnnouncementSheet extends StatefulWidget {
  final String userRole;
  final String userId;
  final String userName;
  final VoidCallback onCreated;

  const CreateAnnouncementSheet({
    super.key,
    required this.userRole,
    required this.userId,
    required this.userName,
    required this.onCreated,
  });

  @override
  State<CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedType = 'general';
  String _selectedPriority = 'normal';
  String _selectedAudience = 'all';
  bool _isPosting = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'general', 'label': 'General', 'icon': Icons.announcement},
    {'value': 'academic', 'label': 'Academic', 'icon': Icons.school},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event},
    {'value': 'deadline', 'label': 'Deadline', 'icon': Icons.alarm},
  ];
  
  final List<Map<String, dynamic>> _priorities = [
    {'value': 'normal', 'label': 'Normal', 'color': Colors.blue},
    {'value': 'high', 'label': 'High', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgent', 'color': Colors.red},
  ];
  
  List<Map<String, String>> get _audiences {
    return [
      {'value': 'all', 'label': '👥 Everyone'},
      {'value': 'students', 'label': '📚 Students Only'},
      {'value': 'academic_staff', 'label': '👨‍🏫 Academic Staff Only'},
      {'value': 'non_academic_staff', 'label': '👔 Non-Academic Staff Only'},
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _postAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isPosting = true);

    try {
      final announcement = {
        'title': _titleController.text,
        'content': _contentController.text,
        'type': _selectedType,
        'priority': _selectedPriority,
        'targetAudience': _selectedAudience,
        'createdBy': widget.userId,
        'createdByRole': widget.userRole,
        'createdByName': widget.userName,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [],
      };

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
                  const Text(
                    'Post New Announcement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Enter title' : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Content
                  TextFormField(
                    controller: _contentController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Enter content' : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Type
                  const Text('Type', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _types.map((type) {
                      return ChoiceChip(
                        label: Text(type['label']),
                        selected: _selectedType == type['value'],
                        onSelected: (selected) {
                          setState(() => _selectedType = type['value']);
                        },
                        backgroundColor: AppColors.glassSurface,
                        selectedColor: AppColors.electricPurple,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Priority
                  const Text('Priority', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _priorities.map((priority) {
                      return ChoiceChip(
                        label: Text(priority['label']),
                        selected: _selectedPriority == priority['value'],
                        onSelected: (selected) {
                          setState(() => _selectedPriority = priority['value']);
                        },
                        backgroundColor: AppColors.glassSurface,
                        selectedColor: priority['color'],
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Target Audience
                  const Text('Send to', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _audiences.map((audience) {
                      return ChoiceChip(
                        label: Text(audience['label']!),
                        selected: _selectedAudience == audience['value'],
                        onSelected: (selected) {
                          setState(() => _selectedAudience = audience['value']!);
                        },
                        backgroundColor: AppColors.glassSurface,
                        selectedColor: AppColors.electricPurple,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Post Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _postAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isPosting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Post Announcement'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== ANNOUNCEMENT DETAIL SHEET ====================
class AnnouncementDetailSheet extends StatelessWidget {
  final String title;
  final String content;
  final String type;
  final String priority;
  final String targetAudience;
  final DateTime createdAt;
  final String createdByName;
  final String createdByRole;

  const AnnouncementDetailSheet({
    super.key,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.targetAudience,
    required this.createdAt,
    required this.createdByName,
    required this.createdByRole,
  });

  String _getAudienceLabel(String audience) {
    switch (audience) {
      case 'students': return 'FOR STUDENTS';
      case 'academic_staff': return 'FOR ACADEMIC STAFF';
      case 'non_academic_staff': return 'FOR NON-ACADEMIC STAFF';
      default: return 'FOR EVERYONE';
    }
  }

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
        maxChildSize: 0.95,
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
                
                // Badges
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: TextStyle(color: priorityColor, fontSize: 11),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(color: AppColors.electricPurple, fontSize: 11),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getAudienceLabel(targetAudience),
                        style: const TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(
                      createdByRole == 'academic_staff' ? Icons.school : Icons.business,
                      size: 14,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(createdByName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 14, color: Colors.white54),
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
                  style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
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

// ==================== ALL ANNOUNCEMENTS SCREEN ====================
class AllAnnouncementsScreen extends StatefulWidget {
  final String userRole;
  final String userId;
  final String userName;
  final bool canPost;

  const AllAnnouncementsScreen({
    super.key,
    required this.userRole,
    required this.userId,
    required this.userName,
    this.canPost = false,
  });

  @override
  State<AllAnnouncementsScreen> createState() => _AllAnnouncementsScreenState();
}

class _AllAnnouncementsScreenState extends State<AllAnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Announcements', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.canPost)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CreateAnnouncementSheet(
                    userRole: widget.userRole,
                    userId: widget.userId,
                    userName: widget.userName,
                    onCreated: () {
                      setState(() {});
                    },
                  ),
                );
              },
            ),
        ],
      ),
      body: RoleBasedAnnouncements(
        userRole: widget.userRole,
        userId: widget.userId,
        userName: widget.userName,
        showViewAll: false,
        limit: 100,
        showCreateButton: widget.canPost,
      ),
    );
  }
}