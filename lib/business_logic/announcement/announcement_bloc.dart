// lib/business_logic/announcement/announcement_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus_app/data/repositories/announce/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';


class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;
  
  AnnouncementBloc({required AnnouncementRepository repository})
      : _repository = repository,
        super(AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<LoadAnnouncementsByType>(_onLoadAnnouncementsByType);
    on<CreateAnnouncement>(_onCreateAnnouncement);
    on<UpdateAnnouncement>(_onUpdateAnnouncement);
    on<DeleteAnnouncement>(_onDeleteAnnouncement);
    on<MarkAnnouncementAsRead>(_onMarkAsRead);
    on<AddReaction>(_onAddReaction);
  }
  
  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    await emit.forEach(
      _repository.getAnnouncementsStream(),
      onData: (announcements) => AnnouncementsLoaded(announcements),
      onError: (error, stackTrace) => AnnouncementError(error.toString()),
    );
  }
  
  Future<void> _onLoadAnnouncementsByType(
    LoadAnnouncementsByType event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    await emit.forEach(
      _repository.getAnnouncementsByTypeStream(event.type),
      onData: (announcements) => AnnouncementsLoaded(announcements),
      onError: (error, stackTrace) => AnnouncementError(error.toString()),
    );
  }
  
  Future<void> _onCreateAnnouncement(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.createAnnouncement(event.announcement);
      emit(AnnouncementCreated());
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }
  
  Future<void> _onUpdateAnnouncement(
    UpdateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.updateAnnouncement(event.id, event.data);
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }
  
  Future<void> _onDeleteAnnouncement(
    DeleteAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.deleteAnnouncement(event.id);
      emit(AnnouncementDeleted());
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }
  
  Future<void> _onMarkAsRead(
    MarkAnnouncementAsRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _repository.markAsRead(event.id);
  }
  
  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _repository.addReaction(event.id, event.reaction);
  }
}