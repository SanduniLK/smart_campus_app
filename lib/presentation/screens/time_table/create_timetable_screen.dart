// lib/presentation/screens/time_table/create_timetable_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_entry_model.dart';

class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({super.key});

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _lecturerController = TextEditingController();
  final _courseIdController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _roomController = TextEditingController();
  final _buildingController = TextEditingController();
  
  // Selection fields
  String? _selectedLecturerId;
  String? _selectedLecturerName;
  String? _selectedLevel;
  String? _selectedSemester;
  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  
  // Lecturer suggestions from database
  List<String> _lecturerSuggestions = [];
  bool _isLoading = false;
  
  final List<String> _levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _semesters = ['Semester 1', 'Semester 2'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadAcademicStaff();
  }

  Future<void> _loadAcademicStaff() async {
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final staff = await db.getAcademicStaff();
    
    setState(() {
      _lecturerSuggestions = staff.map((s) => s['fullName'] as String).toList();
      _isLoading = false;
    });
    
    print('📚 Loaded ${_lecturerSuggestions.length} academic staff members');
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

  Future<void> _submitTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verify selected lecturer exists in database
    if (_selectedLecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid lecturer from suggestions'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final db = DatabaseService();
      
      // Create entry data
      final entry = TimetableEntry(
        lecturerName: _selectedLecturerName!,
        lecturerId: _selectedLecturerId,
        level: _selectedLevel!,
        semester: _selectedSemester!,
        courseId: _courseIdController.text.trim().toUpperCase(),
        courseName: _courseNameController.text.trim(),
        dayOfWeek: _selectedDay + 1,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        roomNumber: _roomController.text.trim(),
        building: _buildingController.text.trim(),
        createdAt: DateTime.now(),
        isSynced: false,
      );
      
      // 1. Save to SQLITE first (offline cache)
      final localId = await db.insertTimetableEntry(entry.toMap());
      print('✅ Saved to SQLite with ID: $localId');
      
      // 2. Save to FIRESTORE (cloud backup)
      try {
        final firestoreId = await _firebaseService.saveTimetableToFirestore(entry);
        
        // Update SQLite with Firestore ID
        await db.updateTimetableFirestoreId(localId, firestoreId);
        await db.markTimetableAsSynced(localId);
        print('✅ Saved to Firestore with ID: $firestoreId');
      } catch (e) {
        print('⚠️ Saved only to SQLite (offline mode). Will sync later.');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Timetable created and saved to cloud!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateAndSelectLecturer(String value) async {
    final db = DatabaseService();
    final lecturer = await db.getLecturerByName(value);
    
    if (lecturer != null) {
      setState(() {
        _selectedLecturerId = lecturer['uid'];
        _selectedLecturerName = lecturer['fullName'];
        _lecturerController.text = lecturer['fullName'];
      });
    } else {
      setState(() {
        _selectedLecturerId = null;
        _selectedLecturerName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Timetable', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading && _lecturerSuggestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLecturerField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildLevelDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSemesterDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_courseIdController, 'Course ID', 'e.g., ICT4153', Icons.code),
                    const SizedBox(height: 16),
                    _buildTextField(_courseNameController, 'Course Name', 'e.g., Mobile App Development', Icons.book),
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
                        Expanded(child: _buildTextField(_roomController, 'Room Number', 'e.g., A204', Icons.meeting_room)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_buildingController, 'Building', 'e.g., Building A', Icons.business)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    ElevatedButton(
  onPressed: () async {
    final db = DatabaseService();
    final database = await db.database;
    
    try {
      await database.execute('ALTER TABLE timetable ADD COLUMN firestoreId TEXT');
      print('✅ Added firestoreId column');
    } catch (e) { print('firestoreId: $e'); }
    
    try {
      await database.execute('ALTER TABLE timetable ADD COLUMN updatedAt TEXT');
      print('✅ Added updatedAt column');
    } catch (e) { print('updatedAt: $e'); }
    
    try {
      await database.execute('ALTER TABLE timetable ADD COLUMN isSynced INTEGER DEFAULT 1');
      print('✅ Added isSynced column');
    } catch (e) { print('isSynced: $e'); }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database fixed! Now try creating timetable.')),
    );
  },
  child: const Text('Fix Database'),
)
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Select Lecturer',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _lecturerSuggestions; // Show all when empty
            }
            return _lecturerSuggestions.where((lecturer) {
              return lecturer.toLowerCase().contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          onSelected: (value) async {
            _lecturerController.text = value;
            await _validateAndSelectLecturer(value);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync controller
            if (_lecturerController.text != controller.text) {
              controller.text = _lecturerController.text;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type to search lecturer...',
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                suffixIcon: _selectedLecturerId != null
                    ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Select a lecturer';
                if (_selectedLecturerId == null) return 'Select a valid lecturer from suggestions';
                return null;
              },
              onChanged: (value) {
                if (_selectedLecturerName != value) {
                  setState(() {
                    _selectedLecturerId = null;
                    _selectedLecturerName = null;
                  });
                }
                _lecturerController.text = value;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: AppColors.glassSurface,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            option,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
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
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
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
        onPressed: _isLoading ? null : _submitTimetable,
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
            : const Text('Create Timetable', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}