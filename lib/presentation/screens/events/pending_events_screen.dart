// lib/presentation/screens/events/pending_events_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/business_logic/event/event_event.dart';
import 'package:smart_campus_app/business_logic/event/event_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class PendingEventsScreen extends StatefulWidget {
  const PendingEventsScreen({super.key});

  @override
  State<PendingEventsScreen> createState() => _PendingEventsScreenState();
}

class _PendingEventsScreenState extends State<PendingEventsScreen> {
  @override
  void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _debugCheckEvents();
    context.read<EventBloc>().add(LoadPendingEvents());
  });
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pending Events', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PendingEventsLoaded) {
            if (state.events.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text('No pending events', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return _buildPendingEventCard(context, event);
              },
            );
          }
          
          if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EventBloc>().add(LoadPendingEvents()),
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

  Widget _buildPendingEventCard(BuildContext context, Event event) {
    // Use createdByEmail or createdBy as fallback
    final creatorName = event.createdByEmail?.split('@').first ?? 
                        event.createdBy.substring(0, event.createdBy.length > 8 ? 8 : event.createdBy.length);
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created by: $creatorName (${event.createdByRole})',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 16),
            Text(
              event.description,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(event.eventDate),
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveEvent(context, event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectEvent(context, event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveEvent(BuildContext context, Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.glassSurface,
        title: const Text('Approve Event', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to approve "${event.title}"? A push notification will be sent to all users.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final eventId = event.firestoreId ?? event.id.toString();
      context.read<EventBloc>().add(ApproveEvent(eventId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event approved! Push notification sent to all users.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectEvent(BuildContext context, Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.glassSurface,
        title: const Text('Reject Event', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to reject "${event.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final eventId = event.firestoreId ?? event.id.toString();
      context.read<EventBloc>().add(RejectEvent(eventId));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event rejected'), backgroundColor: Colors.red),
      );
    }
  }
  Future<void> _debugCheckEvents() async {
  final db = DatabaseService();
  final allEvents = await db.getAllEvents();
  print('📊 ===== ALL EVENTS IN DATABASE =====');
  print('Total events: ${allEvents.length}');
  for (var event in allEvents) {
    print('ID: ${event['id']}, Title: ${event['title']}, Status: ${event['status']}, CreatedBy: ${event['createdBy']}');
  }
  print('====================================');
  
  final pendingEvents = await db.getPendingEvents();
  print('📊 Pending events count: ${pendingEvents.length}');
  for (var event in pendingEvents) {
    print('Pending: ${event['title']}');
  }
}
}