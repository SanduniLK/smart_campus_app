// lib/business_logic/announcement/announcement_event.dart
import 'package:equatable/equatable.dart';
import 'package:smart_campus_app/data/models/announce/announcement_model.dart';


abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementEvent {}

class LoadAnnouncementsByType extends AnnouncementEvent {
  final String type;
  const LoadAnnouncementsByType(this.type);
  @override
  List<Object> get props => [type];
}

class CreateAnnouncement extends AnnouncementEvent {
  final Announcement announcement;
  const CreateAnnouncement(this.announcement);
  @override
  List<Object> get props => [announcement];
}

class UpdateAnnouncement extends AnnouncementEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateAnnouncement(this.id, this.data);
  @override
  List<Object> get props => [id, data];
}

class DeleteAnnouncement extends AnnouncementEvent {
  final String id;
  const DeleteAnnouncement(this.id);
  @override
  List<Object> get props => [id];
}

class MarkAnnouncementAsRead extends AnnouncementEvent {
  final String id;
  const MarkAnnouncementAsRead(this.id);
  @override
  List<Object> get props => [id];
}

class AddReaction extends AnnouncementEvent {
  final String id;
  final String reaction;
  const AddReaction(this.id, this.reaction);
  @override
  List<Object> get props => [id, reaction];
}