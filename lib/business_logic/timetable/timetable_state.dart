import 'package:equatable/equatable.dart';
import 'package:smart_campus_app/data/models/time_table_model/course_model.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_slot_model.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();
  @override
  List<Object?> get props => [];
}

class TimetableInitial extends TimetableState {}

class TimetableLoading extends TimetableState {}

class TimetableLoaded extends TimetableState {
  final List<TimetableSlot> slots;
  final int currentDay;
  const TimetableLoaded({required this.slots, required this.currentDay});
  @override
  List<Object> get props => [slots, currentDay];
}

class CoursesLoaded extends TimetableState {
  final List<Course> courses;
  const CoursesLoaded(this.courses);
  @override
  List<Object> get props => [courses];
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