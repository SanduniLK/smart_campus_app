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
    try {
      final announcements = await _repository.getAnnouncements();
      emit(AnnouncementsLoaded(announcements));
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    try {
      await _repository.createAnnouncement(event.announcement);
      emit(AnnouncementCreated());
      add(LoadAnnouncements());
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
      emit(AnnouncementUpdated());
      add(LoadAnnouncements());
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
      add(LoadAnnouncements());
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAnnouncementAsRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _repository.markAsRead(event.id, event.userId);
    add(LoadAnnouncements());
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _repository.addReaction(event.id, event.userId, event.reaction);
    add(LoadAnnouncements());
  }
}