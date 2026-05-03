// lib/presentation/screens/events/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/business_logic/event/event_event.dart';

import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';


class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }
    

    final isRegistered = false; // You can check from state
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(event.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: event.status == 'approved' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: event.status == 'approved' ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEEE, MMM d, yyyy').format(event.eventDate)),
                  if (event.startTime != null) _buildInfoRow(Icons.access_time, 'Time', '${event.startTime} - ${event.endTime ?? ''}'),
                  _buildInfoRow(Icons.location_on, 'Location', event.location),
                  _buildInfoRow(Icons.people, 'Capacity', '${event.registeredCount}/${event.capacity}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (event.status == 'approved')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isRegistered
                      ? () {
                         
                        }
                      : () {
                          context.read<EventBloc>().add(RegisterForEvent(event.id!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registered successfully!'), backgroundColor: Colors.green),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered ? Colors.green : AppColors.electricPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isRegistered ? 'Show QR Code' : 'Register for Event',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}