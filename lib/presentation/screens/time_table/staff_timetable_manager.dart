import 'package:flutter/material.dart';

import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_entry_model.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'add_edit_timetable_slot.dart';

class StaffTimetableManager extends StatefulWidget {
  const StaffTimetableManager({super.key});

  @override
  State<StaffTimetableManager> createState() => _StaffTimetableManagerState();
}

class _StaffTimetableManagerState extends State<StaffTimetableManager> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  int _selectedDay = DateTime.now().weekday;
  
  List<TimetableEntry> _timetableEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _selectedDay == 7 ? 6 : _selectedDay;
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final results = await db.getTimetableByDay(_selectedDay);
    setState(() {
      _timetableEntries = results.map((map) => TimetableEntry.fromMap(map)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this timetable entry?'),
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
      final db = DatabaseService();
      await db.deleteTimetableEntry(id);
      _loadTimetable();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Timetable', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToAddEdit(),
            tooltip: 'Add Entry',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTimetable,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                : _timetableEntries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _timetableEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _timetableEntries[index];
                          return _buildTimetableCard(entry);
                        },
                      ),
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
                  _loadTimetable();
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

  Widget _buildTimetableCard(TimetableEntry entry) {
    return Dismissible(
      key: Key(entry.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: Text('Delete ${entry.courseId} - ${entry.courseName}?'),
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
      },
      onDismissed: (direction) => _deleteEntry(entry.id!),
      child: GestureDetector(
        onTap: () => _navigateToAddEdit(entry),
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      entry.startTime,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      entry.endTime,
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
                      '${entry.courseId} - ${entry.courseName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lecturer: ${entry.lecturerName}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.roomNumber}, ${entry.building ?? ''}',
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.vibrantYellow),
                onPressed: () => _navigateToAddEdit(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('No timetable entries', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Tap + to add entries', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  void _navigateToAddEdit([TimetableEntry? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTimetableSlot(entry: entry),
      ),
    ).then((_) => _loadTimetable());
  }
}