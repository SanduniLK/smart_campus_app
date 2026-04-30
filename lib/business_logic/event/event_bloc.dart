// lib/business_logic/event/event_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../data/repositories/event/event_repository.dart';

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

  Future<void> _onApproveEvent(ApproveEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repository.approveEvent(event.eventId);
      emit(EventApproved());
      add(LoadPendingEvents());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onRejectEvent(RejectEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repository.rejectEvent(event.eventId);
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

  // ✅ FIXED: _onScanQR now properly handles void return
  Future<void> _onScanQR(ScanQR event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _repository.scanQR(event.eventId, event.userId);
      // After successful scan, emit QRScanned state
      emit(QRScanned());
    } catch (e) {
      // Check if this is an "already scanned" error
      if (e.toString().contains('already') || e.toString().contains('Already')) {
        emit(EventError('QR Code already scanned! You have already marked attendance.'));
      } else {
        emit(EventError(e.toString()));
      }
    }
  }
}