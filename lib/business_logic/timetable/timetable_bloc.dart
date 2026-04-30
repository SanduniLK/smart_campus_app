// lib/business_logic/timetable/timetable_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';
import '../../data/repositories/time_table/timetable_repository.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({required TimetableRepository repository})
      : _repository = repository,
        super(TimetableInitial()) {
    on<LoadTimetableByDay>(_onLoadTimetableByDay);
    on<LoadAllTimetable>(_onLoadAllTimetable);
    on<AddTimetableEntry>(_onAddTimetableEntry);
    on<UpdateTimetableEntry>(_onUpdateTimetableEntry);
    on<DeleteTimetableEntry>(_onDeleteTimetableEntry);
    on<RefreshTimetable>(_onRefreshTimetable);
  }

  Future<void> _onLoadTimetableByDay(
    LoadTimetableByDay event,
    Emitter<TimetableState> emit,
  ) async {
    emit(TimetableLoading());
    try {
      final entries = await _repository.getEntriesByDay(event.dayOfWeek);
      emit(TimetableLoaded(entries: entries, currentDay: event.dayOfWeek));
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
      final entries = await _repository.getAllTimetableEntries();
      emit(TimetableLoaded(entries: entries, currentDay: 1));
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onAddTimetableEntry(
    AddTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.addTimetableEntry(event.entry);
      emit(const TimetableOperationSuccess('Timetable entry added successfully'));
      add(LoadAllTimetable());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onUpdateTimetableEntry(
    UpdateTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.updateTimetableEntry(event.entry);
      emit(const TimetableOperationSuccess('Timetable entry updated successfully'));
      add(LoadAllTimetable());
    } catch (e) {
      emit(TimetableError(e.toString()));
    }
  }

  Future<void> _onDeleteTimetableEntry(
    DeleteTimetableEntry event,
    Emitter<TimetableState> emit,
  ) async {
    try {
      await _repository.deleteTimetableEntry(event.entryId, null);
      emit(const TimetableOperationSuccess('Timetable entry deleted successfully'));
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