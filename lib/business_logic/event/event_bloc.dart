// lib/business_logic/event/event_bloc.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus_app/data/models/event/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../data/repositories/event/event_repository.dart';
import '../../core/services/notification_service.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repository;

  EventBloc({required EventRepository repository})
      : _repository = repository,
        super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadApprovedEvents>(_onLoadApprovedEvents);
    on<LoadPendingEvents>(_onLoadPendingEvents);
    on<CreateEvent>(_onCreateEvent);
    on<ApproveEvent>(_onApproveEvent);
    on<RejectEvent>(_onRejectEvent);
    on<RegisterForEvent>(_onRegisterForEvent);
    on<LoadMyRegistrations>(_onLoadMyRegistrations);
    on<ScanQR>(_onScanQR);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _repository.getAllEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadApprovedEvents(LoadApprovedEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _repository.getApprovedEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadPendingEvents(LoadPendingEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _repository.getPendingEvents();
      emit(PendingEventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repository.createEvent(event.event);
      emit(EventCreated());
      add(LoadEvents());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
// lib/business_logic/event/event_bloc.dart

Future<void> _onApproveEvent(ApproveEvent event, Emitter<EventState> emit) async {
  emit(EventLoading());
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    final approverName = currentUser?.displayName ?? 'Academic Staff';
    
    final eventDetails = await _repository.getEventByFirestoreId(event.eventId);
    
    if (eventDetails == null) {
      emit(EventError('Event not found'));
      return;
    }
    
    final eventIdInt = int.tryParse(event.eventId) ?? 0;
    await _repository.approveEvent(eventIdInt);
    
    final notificationService = NotificationService();
    final formattedDate = DateFormat('MMM dd, yyyy').format(eventDetails.eventDate);
    final startTime = eventDetails.startTime ?? '';
    final timeString = startTime.isNotEmpty ? ' at $startTime' : '';
    
    // Send push notifications
    await notificationService.sendEventApprovedNotification(
      eventDetails.title,
      '$formattedDate$timeString',
      eventDetails.location,
      approverName,
    );
    
    // ✅ SAVE TO FIRESTORE FOR NOTIFICATION SCREEN
    await FirebaseFirestore.instance.collection('user_notifications').add({
      'userId': 'all',
      'title': '✅ Event Approved!',
      'body': '"${eventDetails.title}" on $formattedDate at ${eventDetails.location} has been approved by $approverName',
      'type': 'event_approved',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'eventId': event.eventId,
    });
    
    debugPrint('✅ Event approval notification saved to Firestore');
    
    emit(EventApproved());
    add(LoadPendingEvents());
  } catch (e) {
    emit(EventError(e.toString()));
  }
}
Future<String?> _getUserDeviceToken(String userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['fcmToken'] as String?;
  } catch (e) {
    debugPrint('Error getting device token: $e');
    return null;
  }
}
Future<void> _saveNotificationToFirestore(
  Event event,
  String approverName,
  String formattedDate,
  String startTime,
  String endTime,
) async {
  try {
    final timeRange = startTime.isNotEmpty && endTime.isNotEmpty ? ' $startTime - $endTime' : '';
    
    // Save for ALL USERS (new event notification)
    await FirebaseFirestore.instance.collection('user_notifications').add({
      'userId': 'all',
      'title': '🎉 New Event Available!',
      'body': '"${event.title}" on $formattedDate at ${event.location}$timeRange',
      'type': 'new_event',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'eventId': event.firestoreId,
    });
    
    // Save for CREATOR specifically (approval notification)
    await FirebaseFirestore.instance.collection('user_notifications').add({
      'userId': event.createdBy,
      'title': '✅ Event Approved!',
      'body': 'Your event "${event.title}" has been approved by $approverName and will be held on $formattedDate at ${event.location}$timeRange',
      'type': 'event_approved',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'eventId': event.firestoreId,
    });
    
    debugPrint('✅ Notifications saved to Firestore');
  } catch (e) {
    debugPrint('Error saving to Firestore: $e');
  }
}

  Future<void> _onRejectEvent(RejectEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final eventIdInt = int.tryParse(event.eventId) ?? 0;
      await _repository.rejectEvent(eventIdInt);
      emit(EventRejected());
      add(LoadPendingEvents());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onRegisterForEvent(RegisterForEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final qrData = await _repository.registerForEvent(event.eventId, userId);
      emit(EventRegistered(qrData));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadMyRegistrations(LoadMyRegistrations event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final registrations = await _repository.getUserRegistrations(userId);
      emit(RegistrationsLoaded(registrations));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onScanQR(ScanQR event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repository.scanQR(event.eventId, event.userId);
      emit(QRScanned());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}