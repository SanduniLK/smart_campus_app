import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/data/repositories/time_table/timetable_repository.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';


class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({required TimetableRepository repository})
      : _repository = repository,
        super(TimetableInitial()) {
    on<LoadTimetableByDay>(_onLoadTimetableByDay);
    on<LoadAllTimetable>(_onLoadAllTimetable);
    on<LoadCourses>(_onLoadCourses);
    on<AddCourse>(_onAddCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<AddTimetableSlot>(_onAddTimetableSlot);
    on<UpdateTimetableSlot>(_onUpdateTimetableSlot);
    on<DeleteTimetableSlot>(_onDeleteTimetableSlot);
    on<RefreshTimetable>(_onRefreshTimetable);
  }

  Future<void> _onLoadTimetableByDay(
    LoadTimetableByDay event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      final slots = await _repository.getTimetableByDay(event.dayOfWeek);
      emit(TimetableLoaded(slots: slots, currentDay: event.dayOfWeek));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onLoadAllTimetable(
    LoadAllTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      final slots = await _repository.getAllTimetableSlots();
      emit(TimetableLoaded(slots: slots, currentDay: 1));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      final courses = await _repository.getAllCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onAddCourse(
    AddCourse event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.addCourse(event.course);
      emit(const TimetableOperationSuccess('Course added successfully'));
      add(LoadCourses());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.deleteCourse(event.courseId);
      emit(const TimetableOperationSuccess('Course deleted successfully'));
      add(LoadCourses());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onAddTimetableSlot(
    AddTimetableSlot event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.addTimetableSlot(event.slot);
      emit(const TimetableOperationSuccess('Timetable slot added successfully'));
      add(LoadAllTimetable());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onUpdateTimetableSlot(
    UpdateTimetableSlot event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.updateTimetableSlot(event.slot);
      emit(const TimetableOperationSuccess('Timetable slot updated successfully'));
      add(LoadAllTimetable());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onDeleteTimetableSlot(
    DeleteTimetableSlot event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.deleteTimetableSlot(event.slotId);
      emit(const TimetableOperationSuccess('Timetable slot deleted successfully'));
      add(LoadAllTimetable());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onRefreshTimetable(
    RefreshTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    if (state is TimetableLoaded) {
      final currentState = state as TimetableLoaded;
      add(LoadTimetableByDay(currentState.currentDay));
    } else {
      add(LoadAllTimetable());
    }
  }
}