// lib/presentation/screens/events/events_list_screen.dart
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
import 'package:smart_campus_app/data/repositories/event/event_repository.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:smart_campus_app/presentation/screens/events/event_detail_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/my_qr_code_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late EventBloc _eventBloc;
  Set<int> _registeredEventIds = {};
  bool _isLoadingRegistrations = true;

  @override
  void initState() {
    super.initState();
    _eventBloc = EventBloc(repository: EventRepository());
    _eventBloc.add(LoadApprovedEvents());
    _loadMyRegistrations();
  }

  Future<void> _loadMyRegistrations() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() => _isLoadingRegistrations = false);
      }
      return;
    }

    try {
      final repository = EventRepository();
      // ✅ FIXED: Using getUserRegistrations instead of getUserEventRegistrations
      final registrations = await repository.getUserRegistrations(authState.user.id);
      if (mounted) {
        setState(() {
          _registeredEventIds = registrations.map((reg) => reg['eventId'] as int).toSet();
          _isLoadingRegistrations = false;
        });
      }
    } catch (e) {
      print('Error loading registrations: $e');
      if (mounted) {
        setState(() => _isLoadingRegistrations = false);
      }
    }
  }

  @override
  void dispose() {
    _eventBloc.close();
    super.dispose();
  }

  Future<void> _registerForEvent(Event event) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to register'), backgroundColor: Colors.red),
      );
      return;
    }

    final userId = authState.user.id;
    
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = EventRepository();
      final uniqueQrData = '${event.id}|$userId|${DateTime.now().millisecondsSinceEpoch}';
      await repository.registerForEvent(event.id!, userId);
      
      if (!mounted) return;
      
      setState(() {
        _registeredEventIds.add(event.id!);
      });
      
      Navigator.pop(context);
      _showRegistrationSuccessDialog(event, uniqueQrData);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRegistrationSuccessDialog(Event event, String qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurface,
        title: const Text('Registration Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 50, color: Colors.green),
            const SizedBox(height: 12),
            const Text('You have registered for:'),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('Your QR code has been generated.'),
            const Text('Show it at the event entrance.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyQRCodeScreen(
                    eventId: event.id!,
                    eventName: event.title,
                    qrData: qrData,
                  ),
                ),
              );
            },
            child: const Text('View QR Code'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campus Events', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _eventBloc.add(LoadApprovedEvents());
              _loadMyRegistrations();
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _eventBloc,
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading && _isLoadingRegistrations) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is EventsLoaded) {
              if (state.events.isEmpty) {
                return const Center(
                  child: Text('No events found', style: TextStyle(color: Colors.white70)),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return _buildEventCard(context, event);
                },
              );
            }
            
            if (state is EventError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _eventBloc.add(LoadApprovedEvents());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final isFull = event.registeredCount >= event.capacity;
    final isRegistered = _registeredEventIds.contains(event.id);
    final isUpcoming = event.eventDate.isAfter(DateTime.now());
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: isFull ? Colors.red : (isUpcoming ? Colors.green : Colors.grey),
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
                      DateFormat('MMM dd, yyyy • hh:mm a').format(event.eventDate),
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FULL',
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
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
              Icon(Icons.location_on, size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.people, size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                '${event.registeredCount}/${event.capacity}',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (isRegistered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Already Registered',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            )
          else if (isFull)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Text(
                  'Event Full',
                  style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _registerForEvent(event),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Register Now',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.electricPurple,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}