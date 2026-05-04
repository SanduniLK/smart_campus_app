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
import 'package:google_fonts/google_fonts.dart';

class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() => _StudentEventsScreenState();
}

class _StudentEventsScreenState extends State<StudentEventsScreen>
    with TickerProviderStateMixin {
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

      final allEvents = await db.getAllEvents();
      
      _myEvents = [];
      _registeredEvents = [];
      
      final uniqueEventIds = <int>{};
      
      for (var map in allEvents) {
        final createdBy = map['createdBy'] as String?;
        final eventId = map['id'] as int;
        
        if (uniqueEventIds.contains(eventId)) continue;
        
        if (createdBy == userId) {
          try {
            final event = Event.fromMap(map);
            _myEvents.add(event);
            uniqueEventIds.add(eventId);
          } catch (e) {
            debugPrint('Error parsing event: $e');
          }
        }
      }

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
            debugPrint('Error parsing registered event: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading events: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View QR Code'),
          ),
        ],
      ),
    );
  }

  void _scanAttendeeQR(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          eventId: event.id!,
          eventName: event.title,
          isOrganizer: true,
        ),
      ),
    );
    
    if (result == true && mounted) {
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
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.electricPurple,
              unselectedLabelColor: Colors.white60,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.electricPurple.withValues(alpha: 0.2),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Create Event', icon: Icon(Icons.add_circle_outline)),
                Tab(text: 'My Events', icon: Icon(Icons.event_note)),
              ],
            ),
          ),
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.electricPurple, AppColors.softMagenta],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricPurple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.add_circle_outline, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Create New Event',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Organize a campus event, workshop, or meeting.\nYour event will be sent for approval to academic staff.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricPurple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Note: Events require approval\n before they become visible',
                    style: GoogleFonts.poppins(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
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
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an event or register for existing ones',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
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
            Container(
              margin: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.vibrantYellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Created Events',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_myEvents.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vibrantYellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ..._myEvents.map((event) => _buildEventCard(event, isCreated: true)),
            const SizedBox(height: 24),
          ],
          
          if (hasRegisteredEvents) ...[
            Container(
              margin: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Events I Registered For',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_registeredEvents.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electricPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        margin: EdgeInsets.zero,
        borderColor: isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red),
        borderWidth: 0.5,
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
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a').format(event.eventDate),
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isApproved ? Colors.green.withValues(alpha: 0.2) : 
                                   (isPending ? Colors.orange.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isApproved ? 'APPROVED' : (isPending ? 'PENDING' : 'REJECTED'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      event.description,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
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
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${event.registeredCount}/${event.capacity}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Scanner button for created approved events
                  if (isCreated && isApproved)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _scanAttendeeQR(event),
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text('Scan Attendee QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  
                  // Register button for non-created approved events
                  if (!isCreated && isApproved)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _registerForEvent(event),
                        icon: const Icon(Icons.event_available, size: 20),
                        label: const Text('Register Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  
                  // Pending status message
                  if (isCreated && isPending)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pending, size: 16, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Waiting for approval from academic staff',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Rejected status message
                  if (isCreated && isRejected)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 16, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Event was rejected. Please contact academic staff.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
          Text(_errorMessage!, style: GoogleFonts.poppins(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}