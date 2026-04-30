// lib/business_logic/timetable/timetable_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/time_table_model/timetable_entry_model.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
  @override
  List<Object?> get props => [];
}

// Load Events
class LoadTimetableByDay extends TimetableEvent {
  final int dayOfWeek;
  const LoadTimetableByDay(this.dayOfWeek);
  @override
  List<Object> get props => [dayOfWeek];
}

class LoadAllTimetable extends TimetableEvent {}

// Timetable Entry Events
class AddTimetableEntry extends TimetableEvent {
  final TimetableEntry entry;
  const AddTimetableEntry(this.entry);
  @override
  List<Object> get props => [entry];
}

class UpdateTimetableEntry extends TimetableEvent {
  final TimetableEntry entry;
  const UpdateTimetableEntry(this.entry);
  @override
  List<Object> get props => [entry];
}

class DeleteTimetableEntry extends TimetableEvent {
  final int entryId;
  const DeleteTimetableEntry(this.entryId);
  @override
  List<Object> get props => [entryId];
}

class RefreshTimetable extends TimetableEvent {}