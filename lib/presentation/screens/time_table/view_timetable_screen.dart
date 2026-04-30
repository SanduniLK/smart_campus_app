// lib/presentation/screens/time_table/view_timetable_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class ViewTimetableScreen extends StatefulWidget {
  const ViewTimetableScreen({super.key});

  @override
  State<ViewTimetableScreen> createState() => _ViewTimetableScreenState();
}

class _ViewTimetableScreenState extends State<ViewTimetableScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  int _selectedDay = DateTime.now().weekday;
  
  // For filtering
  String _selectedLevel = 'Year 3';
  String _selectedSemester = 'Semester 1';
  bool _showFilters = true;
  
  final List<String> _levels = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  final List<String> _semesters = ['Semester 1', 'Semester 2'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _selectedDay == 7 ? 6 : _selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          if (_showFilters) _buildFilterRow(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTimetableContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_days.length, (index) {
          final dayNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_days[index], style: const TextStyle(color: Colors.white)),
              selected: _selectedDay == dayNumber,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedDay = dayNumber);
                }
              },
              backgroundColor: AppColors.glassSurface,
              selectedColor: AppColors.electricPurple,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedLevel,
              items: _levels,
              onChanged: (value) => setState(() => _selectedLevel = value!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedSemester,
              items: _semesters,
              onChanged: (value) => setState(() => _selectedSemester = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.glassSurface,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildTimetableContent() {
    return FutureBuilder(
      future: DatabaseService().getTimetableByDay(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.electricPurple));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        
        final timetable = snapshot.data ?? [];
        
        // Apply filters
        final filteredTimetable = timetable.where((entry) {
          return entry['level'] == _selectedLevel && entry['semester'] == _selectedSemester;
        }).toList();
        
        if (filteredTimetable.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                const Text('No classes scheduled', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  'For $_selectedLevel - $_selectedSemester',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredTimetable.length,
          itemBuilder: (context, index) {
            final entry = filteredTimetable[index];
            return _buildTimetableCard(entry);
          },
        );
      },
    );
  }

  Widget _buildTimetableCard(Map<String, dynamic> entry) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            child: Column(
              children: [
                Text(
                  entry['startTime'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
                Text(
                  entry['endTime'],
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry['courseId']} - ${entry['courseName']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lecturer: ${entry['lecturerName']}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  'Level: ${entry['level']} | Semester: ${entry['semester']}',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      '${entry['roomNumber']}, ${entry['building'] ?? ''}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}