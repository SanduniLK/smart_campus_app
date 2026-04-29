import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/data/models/time_table_model/course_model.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_slot_model.dart';
import '../../../business_logic/timetable/timetable_bloc.dart';
import '../../../business_logic/timetable/timetable_event.dart';
import '../../../business_logic/timetable/timetable_state.dart';
import '../../../core/constants/app_colors.dart';

class AddEditTimetableSlot extends StatefulWidget {
  final TimetableSlot? slot;
  const AddEditTimetableSlot({super.key, this.slot});

  @override
  State<AddEditTimetableSlot> createState() => _AddEditTimetableSlotState();
}

class _AddEditTimetableSlotState extends State<AddEditTimetableSlot> {
  final _formKey = GlobalKey<FormState>();
  
  Course? _selectedCourse;
  int _selectedDay = 1;
  String _startTime = '09:00';
  String _endTime = '11:00';
  final _roomCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  String _selectedType = 'Lecture';

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _timeSlots = ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'];
  final List<String> _types = ['Lecture', 'Lab', 'Tutorial'];

  @override
  void initState() {
    super.initState();
    if (widget.slot != null) {
      _selectedCourse = Course(
        id: widget.slot!.courseId,
        courseCode: widget.slot!.courseCode ?? '',
        courseName: widget.slot!.courseName ?? '',
        credits: 3,
        lecturerName: widget.slot!.lecturerName ?? '',
        batchYear: '',
        department: '',
      );
      _selectedDay = widget.slot!.dayOfWeek;
      _startTime = widget.slot!.startTime;
      _endTime = widget.slot!.endTime;
      _roomCtrl.text = widget.slot!.roomNumber;
      _buildingCtrl.text = widget.slot!.building;
      _selectedType = widget.slot!.type;
    }
    context.read<TimetableBloc>().add(LoadCourses());
  }

  @override
  void dispose() {
    _roomCtrl.dispose();
    _buildingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.slot == null ? 'Add Timetable Slot' : 'Edit Timetable Slot', 
          style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          if (state is TimetableLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CoursesLoaded) {
            return _buildForm(state.courses);
          }
          if (state is TimetableError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TimetableBloc>().add(LoadCourses()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildForm(List<Course> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDropdown(courses),
            const SizedBox(height: 16),
            _buildDayDropdown(),
            const SizedBox(height: 16),
            _buildTimeRow(),
            const SizedBox(height: 16),
            _buildTextField(_roomCtrl, 'Room Number', Icons.meeting_room),
            const SizedBox(height: 16),
            _buildTextField(_buildingCtrl, 'Building', Icons.business),
            const SizedBox(height: 16),
            _buildTypeDropdown(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<Course> courses) {
    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Text('No courses found', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('Please add a course first', style: TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<Course>(
        value: _selectedCourse,
        hint: const Text('Select Course', style: TextStyle(color: Colors.white70)),
        items: courses.map((c) => DropdownMenuItem(
          value: c,
          child: Text('${c.courseCode} - ${c.courseName}', 
            style: const TextStyle(color: Colors.white)),
        )).toList(),
        onChanged: (v) => setState(() => _selectedCourse = v),
        validator: (v) => v == null ? 'Select course' : null,
        dropdownColor: AppColors.glassSurface,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDayDropdown() => Container(
    decoration: BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: DropdownButtonFormField<int>(
      value: _selectedDay,
      items: List.generate(6, (i) => DropdownMenuItem(
        value: i + 1,
        child: Text(_days[i], style: const TextStyle(color: Colors.white)),
      )),
      onChanged: (v) => setState(() => _selectedDay = v!),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    ),
  );

  Widget _buildTimeRow() => Row(
    children: [
      Expanded(child: _buildTimeDropdown('Start', _startTime, (v) => setState(() => _startTime = v!))),
      const SizedBox(width: 12),
      Expanded(child: _buildTimeDropdown('End', _endTime, (v) => setState(() => _endTime = v!))),
    ],
  );

  Widget _buildTimeDropdown(String label, String value, Function(String?) onChanged) => Container(
    decoration: BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: DropdownButtonFormField<String>(
      value: value,
      hint: Text(label, style: const TextStyle(color: Colors.white70)),
      items: _timeSlots.map((t) => DropdownMenuItem(
        value: t,
        child: Text(t, style: const TextStyle(color: Colors.white)),
      )).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    ),
  );

  Widget _buildTextField(TextEditingController c, String label, IconData icon) => Container(
    decoration: BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextFormField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    ),
  );

  Widget _buildTypeDropdown() => Container(
    decoration: BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: DropdownButtonFormField<String>(
      value: _selectedType,
      items: _types.map((t) => DropdownMenuItem(
        value: t,
        child: Text(t, style: const TextStyle(color: Colors.white)),
      )).toList(),
      onChanged: (v) => setState(() => _selectedType = v!),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
    ),
  );

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCourse != null) {
      final slot = TimetableSlot(
        id: widget.slot?.id,
        courseId: _selectedCourse!.id!,
        dayOfWeek: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        roomNumber: _roomCtrl.text,
        building: _buildingCtrl.text,
        type: _selectedType,
      );
      
      if (widget.slot == null) {
        context.read<TimetableBloc>().add(AddTimetableSlot(slot));
      } else {
        context.read<TimetableBloc>().add(UpdateTimetableSlot(slot));
      }
      Navigator.pop(context);
    }
  }
}