// lib/presentation/screens/announcements/create_announcement_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:smart_campus_app/core/constants/app_colors.dart';


class CreateAnnouncementScreen extends StatefulWidget {
  final String userRole; // 'academic_staff' or 'non_academic_staff'
  final String userName;
  final String userId;

  const CreateAnnouncementScreen({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userId,
  });

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedType = 'general';
  String _selectedPriority = 'normal';
  String _selectedAudience = 'all';
  bool _isLoading = false;

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
  
  // Role-based audience options
  List<Map<String, String>> get _audiences {
    return [
      {'value': 'all', 'label': 'Everyone'},
      {'value': 'students', 'label': 'Students Only'},
      {'value': 'academic_staff', 'label': 'Academic Staff Only'},
      {'value': 'non_academic_staff', 'label': 'Non-Academic Staff Only'},
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

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
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post Announcement', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Enter announcement title',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: AppColors.glassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.title, color: AppColors.electricPurple),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter title' : null,
              ),
              
              const SizedBox(height: 20),
              
              // Content
              TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Enter announcement details...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: AppColors.glassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter content' : null,
              ),
              
              const SizedBox(height: 20),
              
              // Announcement Type
              const Text(
                'Announcement Type',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _types.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    label: Text(type['label']),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                    avatar: Icon(type['icon'], size: 18, color: isSelected ? Colors.white : Colors.white54),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type['value']);
                    },
                    backgroundColor: AppColors.glassSurface,
                    selectedColor: AppColors.electricPurple,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Priority
              const Text(
                'Priority',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _priorities.map((priority) {
                  final isSelected = _selectedPriority == priority['value'];
                  return ChoiceChip(
                    label: Text(priority['label']),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : priority['color']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedPriority = priority['value']);
                    },
                    backgroundColor: AppColors.glassSurface,
                    selectedColor: priority['color'],
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Target Audience (Role-based)
              const Text(
                'Target Audience',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _audiences.map((audience) {
                  final isSelected = _selectedAudience == audience['value'];
                  return FilterChip(
                    label: Text(audience['label']!),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedAudience = audience['value']!);
                    },
                    backgroundColor: AppColors.glassSurface,
                    selectedColor: AppColors.electricPurple,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post Announcement', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}