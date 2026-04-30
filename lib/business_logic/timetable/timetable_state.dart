// lib/business_logic/timetable/timetable_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/time_table_model/timetable_entry_model.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();
  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableLoaded extends TimetableState {
  final List<TimetableEntry> entries;
  final int currentDay;
  const TimetableLoaded({required this.entries, required this.currentDay});
  @override
  List<Object> get props => [entries, currentDay];
}

class TimetableOperationSuccess extends TimetableState {
  final String message;
  const TimetableOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class TimetableError extends TimetableState {
  final String message;
  const TimetableError(this.message);
  @override
  List<Object> get props => [message];
}