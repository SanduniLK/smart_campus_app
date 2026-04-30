// lib/presentation/screens/time_table/edit_timetable_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_entry_model.dart';

class EditTimetableScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  const EditTimetableScreen({super.key, required this.entry});

  @override
  State<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _lecturerController;
  late TextEditingController _courseIdController;
  late TextEditingController _courseNameController;
  late TextEditingController _roomController;
  late TextEditingController _buildingController;
  
  late String _selectedLevel;
  late String _selectedSemester;
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  bool _isLoading = false;
  
  final List<String> _levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _semesters = ['Semester 1', 'Semester 2'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    
    _lecturerController = TextEditingController(text: widget.entry['lecturerName']);
    _courseIdController = TextEditingController(text: widget.entry['courseId']);
    _courseNameController = TextEditingController(text: widget.entry['courseName']);
    _roomController = TextEditingController(text: widget.entry['roomNumber']);
    _buildingController = TextEditingController(text: widget.entry['building'] ?? '');
    
    _selectedLevel = widget.entry['level'];
    _selectedSemester = widget.entry['semester'];
    _selectedDay = widget.entry['dayOfWeek'] - 1;
    
    _startTime = _parseTimeString(widget.entry['startTime']);
    _endTime = _parseTimeString(widget.entry['endTime']);
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.electricPurple),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _updateTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final db = DatabaseService();
      
      // Prepare updated data
      final updatedData = {
        'lecturerName': _lecturerController.text.trim(),
        'level': _selectedLevel,
        'semester': _selectedSemester,
        'courseId': _courseIdController.text.trim().toUpperCase(),
        'courseName': _courseNameController.text.trim(),
        'dayOfWeek': _selectedDay + 1,
        'startTime': _formatTimeOfDay(_startTime),
        'endTime': _formatTimeOfDay(_endTime),
        'roomNumber': _roomController.text.trim(),
        'building': _buildingController.text.trim(),
        'isSynced': 0, // Mark as unsynced
      };
      
      // 1. Update SQLITE first (offline cache)
      await db.updateTimetableEntry(widget.entry['id'], updatedData);
      print('✅ Updated SQLite entry ID: ${widget.entry['id']}');
      
      // 2. Update FIRESTORE if online
      final firestoreId = widget.entry['firestoreId'];
      if (firestoreId != null && firestoreId.isNotEmpty) {
        try {
          final entry = TimetableEntry(
            id: widget.entry['id'],
            firestoreId: firestoreId,
            lecturerName: _lecturerController.text.trim(),
            level: _selectedLevel,
            semester: _selectedSemester,
            courseId: _courseIdController.text.trim().toUpperCase(),
            courseName: _courseNameController.text.trim(),
            dayOfWeek: _selectedDay + 1,
            startTime: _formatTimeOfDay(_startTime),
            endTime: _formatTimeOfDay(_endTime),
            roomNumber: _roomController.text.trim(),
            building: _buildingController.text.trim(),
          );
          
          await _firebaseService.updateTimetableInFirestore(firestoreId, entry);
          await db.markTimetableAsSynced(widget.entry['id']);
          print('✅ Updated Firestore entry ID: $firestoreId');
        } catch (e) {
          print('⚠️ Firestore update failed - will sync later: $e');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Timetable updated successfully!')),
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

  Future<void> _deleteTimetable() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timetable Entry'),
        content: Text('Delete ${_courseIdController.text} - ${_courseNameController.text}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      
      try {
        final db = DatabaseService();
        final firestoreId = widget.entry['firestoreId'];
        
        // 1. Delete from SQLITE
        await db.deleteTimetableEntry(widget.entry['id']);
        print('✅ Deleted from SQLite ID: ${widget.entry['id']}');
        
        // 2. Delete from FIRESTORE if online
        if (firestoreId != null && firestoreId.isNotEmpty) {
          try {
            await _firebaseService.deleteTimetableFromFirestore(firestoreId);
            print('✅ Deleted from Firestore ID: $firestoreId');
          } catch (e) {
            print('⚠️ Firestore delete failed - will retry later: $e');
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Timetable entry deleted!')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Timetable'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTimetable,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildReadOnlyField('Lecturer Name', _lecturerController.text),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildLevelDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSemesterDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_courseIdController, 'Course ID', Icons.code),
              const SizedBox(height: 16),
              _buildTextField(_courseNameController, 'Course Name', Icons.book),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDayDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeFields()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_roomController, 'Room Number', Icons.meeting_room)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_buildingController, 'Building', Icons.business)),
                ],
              ),
              const SizedBox(height: 32),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value?.isEmpty ?? true ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLevel,
        items: _levels.map((level) {
          return DropdownMenuItem(value: level, child: Text(level, style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (value) => setState(() => _selectedLevel = value!),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        dropdownColor: AppColors.glassSurface,
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSemester,
        items: _semesters.map((semester) {
          return DropdownMenuItem(value: semester, child: Text(semester, style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (value) => setState(() => _selectedSemester = value!),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        dropdownColor: AppColors.glassSurface,
      ),
    );
  }

  Widget _buildDayDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedDay,
        items: List.generate(_days.length, (index) {
          return DropdownMenuItem(value: index, child: Text(_days[index], style: const TextStyle(color: Colors.white)));
        }),
        onChanged: (value) => setState(() => _selectedDay = value!),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        dropdownColor: AppColors.glassSurface,
      ),
    );
  }

  Widget _buildTimeFields() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _selectTime(context, true),
              child: Text(
                _formatTimeOfDay(_startTime),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const Text('-', style: TextStyle(color: Colors.white54)),
          Expanded(
            child: TextButton(
              onPressed: () => _selectTime(context, false),
              child: Text(
                _formatTimeOfDay(_endTime),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.electricPurple, AppColors.softMagenta],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateTimetable,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Update Timetable', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}