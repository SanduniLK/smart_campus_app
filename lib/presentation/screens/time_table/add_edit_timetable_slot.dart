import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/timetable/timetable_bloc.dart';
import '../../../business_logic/timetable/timetable_event.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/time_table_model/timetable_entry_model.dart';

class AddEditTimetableSlot extends StatefulWidget {
  final TimetableEntry? entry;
  const AddEditTimetableSlot({super.key, this.entry});

  @override
  State<AddEditTimetableSlot> createState() => _AddEditTimetableSlotState();
}

class _AddEditTimetableSlotState extends State<AddEditTimetableSlot> {
  final _formKey = GlobalKey<FormState>();
  
  final _lecturerController = TextEditingController();
  final _courseIdController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _roomController = TextEditingController();
  final _buildingController = TextEditingController();
  
  String? _selectedLevel;
  String? _selectedSemester;
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  
  List<String> _lecturerSuggestions = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  
  final List<String> _levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _semesters = ['Semester 1', 'Semester 2'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _loadLecturers();
    
    if (widget.entry != null) {
      _lecturerController.text = widget.entry!.lecturerName;
      _selectedLevel = widget.entry!.level;
      _selectedSemester = widget.entry!.semester;
      _courseIdController.text = widget.entry!.courseId;
      _courseNameController.text = widget.entry!.courseName;
      _selectedDay = widget.entry!.dayOfWeek - 1;
      _startTime = _parseTimeString(widget.entry!.startTime);
      _endTime = _parseTimeString(widget.entry!.endTime);
      _roomController.text = widget.entry!.roomNumber;
      _buildingController.text = widget.entry!.building ?? '';
    }
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _loadLecturers() async {
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final staff = await db.getAcademicStaff();
    setState(() {
      _lecturerSuggestions = staff.map((s) => s['fullName'] as String).toList();
      _isLoading = false;
    });
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final entry = TimetableEntry(
        id: widget.entry?.id,
        firestoreId: widget.entry?.firestoreId,
        lecturerName: _lecturerController.text.trim(),
        level: _selectedLevel!,
        semester: _selectedSemester!,
        courseId: _courseIdController.text.trim().toUpperCase(),
        courseName: _courseNameController.text.trim(),
        dayOfWeek: _selectedDay + 1,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        roomNumber: _roomController.text.trim(),
        building: _buildingController.text.trim(),
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        isSynced: false,
      );
      
      if (widget.entry == null) {
        context.read<TimetableBloc>().add(AddTimetableEntry(entry));
      } else {
        context.read<TimetableBloc>().add(UpdateTimetableEntry(entry));
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Timetable Slot' : 'Edit Timetable Slot',
          style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLecturerField(),
                    const SizedBox(height: 16),
                    _buildLevelDropdown(),
                    const SizedBox(height: 16),
                    _buildSemesterDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(_courseIdController, 'Course ID', Icons.code),
                    const SizedBox(height: 16),
                    _buildTextField(_courseNameController, 'Course Name', Icons.book),
                    const SizedBox(height: 16),
                    _buildDayDropdown(),
                    const SizedBox(height: 16),
                    _buildTimeRow(),
                    const SizedBox(height: 16),
                    _buildTextField(_roomController, 'Room Number', Icons.meeting_room),
                    const SizedBox(height: 16),
                    _buildTextField(_buildingController, 'Building', Icons.business),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLecturerField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) return [];
          return _lecturerSuggestions.where((lecturer) {
            return lecturer.toLowerCase().contains(textEditingValue.text.toLowerCase());
          }).toList();
        },
        onSelected: (value) => _lecturerController.text = value,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: _lecturerController,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Lecturer Name',
              hintText: 'Search lecturer...',
              prefixIcon: Icon(Icons.person, color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Select lecturer' : null,
          );
        },
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
        hint: const Text('Level', style: TextStyle(color: Colors.white54)),
        items: _levels.map((level) {
          return DropdownMenuItem(value: level, child: Text(level, style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (value) => setState(() => _selectedLevel = value),
        validator: (value) => value == null ? 'Select level' : null,
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
        hint: const Text('Semester', style: TextStyle(color: Colors.white54)),
        items: _semesters.map((semester) {
          return DropdownMenuItem(value: semester, child: Text(semester, style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (value) => setState(() => _selectedSemester = value),
        validator: (value) => value == null ? 'Select semester' : null,
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
        hint: const Text('Day', style: TextStyle(color: Colors.white54)),
        items: List.generate(_days.length, (index) {
          return DropdownMenuItem(value: index, child: Text(_days[index], style: const TextStyle(color: Colors.white)));
        }),
        onChanged: (value) => setState(() => _selectedDay = value!),
        validator: (value) => value == null ? 'Select day' : null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        dropdownColor: AppColors.glassSurface,
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start', style: TextStyle(color: Colors.white54)),
                TextButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text(_formatTimeOfDay(_startTime), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('End', style: TextStyle(color: Colors.white54)),
                TextButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text(_formatTimeOfDay(_endTime), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildSubmitButton() {
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
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}