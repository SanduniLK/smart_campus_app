// lib/presentation/screens/events/create_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/business_logic/event/event_event.dart';
import 'package:smart_campus_app/business_logic/event/event_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:smart_campus_app/presentation/widgets/glass_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.electricPurple),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.electricPurple),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Not set';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _submitEvent() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      
      final user = authState.user;
      final isStudent = user.role == 'student';
      
      final event = Event(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        eventDate: _selectedDate,
        startTime: _startTime != null ? _formatTime(_startTime) : null,
        endTime: _endTime != null ? _formatTime(_endTime) : null,
        location: _locationController.text.trim(),
        capacity: int.parse(_capacityController.text),
        status: isStudent ? 'pending' : 'approved',
        createdBy: user.id,
        createdByRole: user.role,
        createdByEmail: user.email,
        createdAt: DateTime.now(),
      );
      
      context.read<EventBloc>().add(CreateEvent(event));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isStudent 
            ? 'Event submitted for approval!' 
            : 'Event created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isStudent = authState is AuthAuthenticated && authState.user.role == 'student';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isStudent ? 'Request Event' : 'Create Event'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GlassTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  icon: Icons.title,
                  validator: (v) => v?.isEmpty ?? true ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _descController,
                  label: 'Description',
                  icon: Icons.description,
                  
                  validator: (v) => v?.isEmpty ?? true ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildTimeFields(),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                  validator: (v) => v?.isEmpty ?? true ? 'Enter location' : null,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _capacityController,
                  label: 'Capacity',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Enter capacity' : null,
                ),
                const SizedBox(height: 24),
                if (isStudent)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This event will be sent for approval to academic staff',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: GlassCard(
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Date: ${DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFields() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(true),
            child: GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Start: ${_formatTime(_startTime)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(false),
            child: GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'End: ${_formatTime(_endTime)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        onPressed: _isSubmitting ? null : _submitEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Create Event', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}