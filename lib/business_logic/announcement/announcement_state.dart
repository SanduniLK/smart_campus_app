// lib/business_logic/announcement/announcement_state.dart
import 'package:equatable/equatable.dart';
import 'package:smart_campus_app/data/models/announce/announcement_model.dart';


abstract class AnnouncementState extends Equatable {
  const AnnouncementState();
  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementsLoaded extends AnnouncementState {
  final List<Announcement> announcements;
  const AnnouncementsLoaded(this.announcements);
  @override
  List<Object> get props => [announcements];
}

class AnnouncementCreated extends AnnouncementState {}

class AnnouncementUpdated extends AnnouncementState {}

class AnnouncementDeleted extends AnnouncementState {}

class AnnouncementError extends AnnouncementState {
  final String message;
  const AnnouncementError(this.message);
  @override
  List<Object> get props => [message];
}