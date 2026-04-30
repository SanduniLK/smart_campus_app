// lib/business_logic/event/event_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/event/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}
class EventLoading extends EventState {}
class EventsLoaded extends EventState {
  final List<Event> events;
  const EventsLoaded(this.events);
  @override
  List<Object> get props => [events];
}
class PendingEventsLoaded extends EventState {
  final List<Event> events;
  const PendingEventsLoaded(this.events);
  @override
  List<Object> get props => [events];
}
class RegistrationsLoaded extends EventState {
  final List<Map<String, dynamic>> registrations;
  const RegistrationsLoaded(this.registrations);
  @override
  List<Object> get props => [registrations];
}
class EventCreated extends EventState {}
class EventApproved extends EventState {}
class EventRejected extends EventState {}
class EventRegistered extends EventState {
  final String qrData;
  const EventRegistered(this.qrData);
  @override
  List<Object> get props => [qrData];
}
class QRScanned extends EventState {}
class EventError extends EventState {
  final String message;
  const EventError(this.message);
  @override
  List<Object> get props => [message];
}