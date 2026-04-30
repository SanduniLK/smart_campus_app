// lib/presentation/screens/events/student_events_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';

import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'package:smart_campus_app/data/repositories/event/event_repository.dart';
import 'package:smart_campus_app/presentation/screens/events/create_event_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/event_detail_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/my_qr_code_screen.dart';
import 'package:smart_campus_app/presentation/screens/events/qr_scanner_screen.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() => _StudentEventsScreenState();
}

class _StudentEventsScreenState extends State<StudentEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EventBloc _eventBloc;
  List<Event> _myEvents = [];
  List<Event> _registeredEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _eventBloc = EventBloc(repository: EventRepository());
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventBloc.close();
    super.dispose();
  }

 // In student_events_screen.dart - Only load from SQLite, not Firebase

Future<void> _loadData() async {
  if (!mounted) return;
  
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to view events';
        });
      }
      return;
    }

    final userId = authState.user.id;
    final db = DatabaseService();

    // ✅ ONLY get events from SQLite, NOT from Firebase
    final allEvents = await db.getAllEvents();
    
    // Clear lists
    _myEvents = [];
    _registeredEvents = [];
    
    // Use Set to track unique event IDs
    final uniqueEventIds = <int>{};
    
    // My created events (events I created)
    for (var map in allEvents) {
      final createdBy = map['createdBy'] as String?;
      final eventId = map['id'] as int;
      
      // Skip if we already have this event
      if (uniqueEventIds.contains(eventId)) continue;
      
      if (createdBy == userId) {
        try {
          final event = Event.fromMap(map);
          _myEvents.add(event);
          uniqueEventIds.add(eventId);
        } catch (e) {
          debugPrint('❌ Error parsing event: $e');
        }
      }
    }

    // Get events I registered for
    final myRegistrations = await db.getUserEventRegistrations(userId);
    final registeredEventIds = myRegistrations
        .map((reg) {
          final eventId = reg['eventId'];
          if (eventId is int) return eventId;
          if (eventId is String) return int.tryParse(eventId);
          return null;
        })
        .where((id) => id != null && !uniqueEventIds.contains(id))
        .cast<int>()
        .toSet();
    
    for (var map in allEvents) {
      final id = map['id'];
      int eventId;
      if (id is int) {
        eventId = id;
      } else if (id is String) {
        eventId = int.tryParse(id) ?? -1;
      } else {
        eventId = -1;
      }
      
      if (registeredEventIds.contains(eventId) && !uniqueEventIds.contains(eventId)) {
        try {
          final event = Event.fromMap(map);
          _registeredEvents.add(event);
          uniqueEventIds.add(eventId);
        } catch (e) {
          debugPrint('❌ Error parsing registered event: $e');
        }
      }
    }

    debugPrint('📊 My created events: ${_myEvents.length}');
    debugPrint('📊 Registered events: ${_registeredEvents.length}');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error loading events: $e');
    debugPrint('Stack trace: $stackTrace');
    if (mounted) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
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
      final qrData = await repository.registerForEvent(event.id!, userId);
      
      if (!mounted) return;
      Navigator.pop(context);
      _showRegistrationSuccessDialog(event, qrData);
      await _loadData();
      
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
            const Text('You have successfully registered for:'),
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

  // Scanner for organizer (to scan attendees)
  void _scanAttendeeQR(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          eventId: event.id!,
          eventName: event.title,
          isOrganizer: true, // This is for organizers to scan attendees
        ),
      ),
    );
    
    if (result == true) {
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Events', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.electricPurple,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.electricPurple,
          tabs: const [
            Tab(text: 'Create Event'),
            Tab(text: 'My Events'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCreateEventTab(),
                    _buildMyEventsTab(),
                  ],
                ),
    );
  }

  Widget _buildCreateEventTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 80, color: AppColors.electricPurple),
            const SizedBox(height: 24),
            Text(
              'Create New Event',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Organize a campus event, workshop, or meeting.\nYour event will be sent for approval to academic staff.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricPurple, AppColors.softMagenta],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                  ).then((_) => _loadData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Create Event',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Events require approval before they become visible',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEventsTab() {
    final hasCreatedEvents = _myEvents.isNotEmpty;
    final hasRegisteredEvents = _registeredEvents.isNotEmpty;

    if (!hasCreatedEvents && !hasRegisteredEvents) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an event or register for existing ones',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCreatedEvents) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Created Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vibrantYellow,
                  ),
                ),
                const Icon(Icons.star, color: AppColors.vibrantYellow, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            ..._myEvents.map((event) => _buildEventCard(event, isCreated: true)),
            const SizedBox(height: 24),
          ],
          
          if (hasRegisteredEvents) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events I Registered For',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricPurple,
                  ),
                ),
                const Icon(Icons.event_available, color: AppColors.electricPurple, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            ..._registeredEvents.map((event) => _buildEventCard(event, isCreated: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, {required bool isCreated}) {
    final isApproved = event.status == 'approved';
    final isPending = event.status == 'pending';
    final isRejected = event.status == 'rejected';
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red),
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
                    _buildStatusBadge(event.status),
                  ],
                ),
                const Divider(color: Colors.white24, height: 16),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ✅ SCANNER BUTTON FOR CREATED EVENTS (Organizer scans attendees)
          if (isCreated && isApproved) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scanAttendeeQR(event),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan Attendee QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Register button for non-created approved events
          if (!isCreated && isApproved) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _registerForEvent(event),
                    icon: const Icon(Icons.event_available, size: 18),
                    label: const Text('Register Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (isCreated && isPending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.pending, size: 14, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waiting for approval from academic staff',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (isCreated && isRejected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel, size: 14, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Event was rejected. Please contact academic staff.',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'APPROVED';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'PENDING';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricPurple),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}