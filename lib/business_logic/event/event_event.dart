// lib/business_logic/event/event_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/event/event_model.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}
class LoadPendingEvents extends EventEvent {}
class CreateEvent extends EventEvent {
  final Event event;
  const CreateEvent(this.event);
  @override
  List<Object> get props => [event];
}
class ApproveEvent extends EventEvent {
  final int eventId;
  const ApproveEvent(this.eventId);
  @override
  List<Object> get props => [eventId];
}
class RejectEvent extends EventEvent {
  final int eventId;
  const RejectEvent(this.eventId);
  @override
  List<Object> get props => [eventId];
}
class RegisterForEvent extends EventEvent {
  final int eventId;
  const RegisterForEvent(this.eventId);
  @override
  List<Object> get props => [eventId];
}
class LoadMyRegistrations extends EventEvent {}
class ScanQR extends EventEvent {
  final int eventId;
  final String userId;
  const ScanQR(this.eventId, this.userId);
  @override
  List<Object> get props => [eventId, userId];
}