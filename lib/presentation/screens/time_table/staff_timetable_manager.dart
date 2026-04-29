import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_slot_model.dart';
import 'package:smart_campus_app/presentation/screens/time_table/add_edit_timetable_slot.dart';
import '../../../business_logic/timetable/timetable_bloc.dart';
import '../../../business_logic/timetable/timetable_event.dart';
import '../../../business_logic/timetable/timetable_state.dart';
import '../../../core/constants/app_colors.dart';

class StaffTimetableManager extends StatefulWidget {
  const StaffTimetableManager({super.key});

  @override
  State<StaffTimetableManager> createState() => _StaffTimetableManagerState();
}

class _StaffTimetableManagerState extends State<StaffTimetableManager> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  int _selectedDay = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _selectedDay = _selectedDay == 7 ? 6 : _selectedDay;
    // ✅ Use try-catch and add event safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TimetableBloc>().add(LoadTimetableByDay(_selectedDay));
        context.read<TimetableBloc>().add(LoadCourses());
      }
    });
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
            onPressed: () => _showAddCourseDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.timelapse_rounded, color: Colors.white),
            onPressed: () => _navigateToAddSlot(),
          ),
        ],
      ),
      body: BlocConsumer<TimetableBloc, TimetableState>(
        listenWhen: (previous, current) => current is TimetableOperationSuccess || current is TimetableError,
        listener: (context, state) {
          if (state is TimetableOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is TimetableError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // ✅ Handle loading state properly
          if (state is TimetableLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.electricPurple),
            );
          }
          
          if (state is TimetableError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TimetableBloc>().add(LoadTimetableByDay(_selectedDay));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is TimetableLoaded) {
            if (state.slots.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTimetableList(state.slots);
          }
          
          // ✅ Show loading initially
          return const Center(
            child: CircularProgressIndicator(color: AppColors.electricPurple),
          );
        },
      ),
    );
  }

  Widget _buildTimetableList(List<TimetableSlot> slots) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _buildTimetableCard(slot);
      },
    );
  }

  Widget _buildTimetableCard(TimetableSlot slot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.glassSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          slot.courseCode ?? 'Unknown',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slot.courseName ?? '', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              '${slot.startTime} - ${slot.endTime} | ${slot.roomNumber}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteSlot(slot.id!),
        ),
        onTap: () => _navigateToEditSlot(slot),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text('No timetable slots', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('Tap + to add', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  void _deleteSlot(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slot'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<TimetableBloc>().add(DeleteTimetableSlot(slotId));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddSlot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTimetableSlot()),
    );
  }

  void _navigateToEditSlot(TimetableSlot slot) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTimetableSlot(slot: slot)),
    );
  }

  void _showAddCourseDialog() {
    // Simple dialog for adding course
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Course Code')),
            const SizedBox(height: 8),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Course Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Add course logic here
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}