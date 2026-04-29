import 'package:equatable/equatable.dart';
import 'package:smart_campus_app/data/models/time_table_model/course_model.dart';
import 'package:smart_campus_app/data/models/time_table_model/timetable_slot_model.dart';


abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
  @override
  List<Object?> get props => [];
}

class LoadTimetableByDay extends TimetableEvent {
  final int dayOfWeek;
  const LoadTimetableByDay(this.dayOfWeek);
  @override
  List<Object> get props => [dayOfWeek];
}

class LoadAllTimetable extends TimetableEvent {}

class LoadCourses extends TimetableEvent {}

class AddCourse extends TimetableEvent {
  final Course course;
  const AddCourse(this.course);
  @override
  List<Object> get props => [course];
}

class DeleteCourse extends TimetableEvent {
  final int courseId;
  const DeleteCourse(this.courseId);
  @override
  List<Object> get props => [courseId];
}

class AddTimetableSlot extends TimetableEvent {
  final TimetableSlot slot;
  const AddTimetableSlot(this.slot);
  @override
  List<Object> get props => [slot];
}

class UpdateTimetableSlot extends TimetableEvent {
  final TimetableSlot slot;
  const UpdateTimetableSlot(this.slot);
  @override
  List<Object> get props => [slot];
}

class DeleteTimetableSlot extends TimetableEvent {
  final int slotId;
  const DeleteTimetableSlot(this.slotId);
  @override
  List<Object> get props => [slotId];
}

class RefreshTimetable extends TimetableEvent {}