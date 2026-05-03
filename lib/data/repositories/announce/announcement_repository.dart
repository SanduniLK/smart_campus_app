// lib/data/repositories/announce/announcement_repository.dart

import 'package:smart_campus_app/core/services/rest_api_service.dart';
import '../../models/announce/announcement_model.dart';

class AnnouncementRepository {
  // GET all announcements
  Future<List<Announcement>> getAnnouncements() async {
    final data = await AnnouncementRestApi.getAnnouncements();
    return data.map((json) => Announcement.fromJson(json)).toList();
  }
  
  // GET single announcement
  Future<Announcement?> getAnnouncementById(String id) async {
    final data = await AnnouncementRestApi.getAnnouncementById(id);
    if (data != null) {
      return Announcement.fromJson(data);
    }
    return null;
  }
  
  // POST create announcement
  Future<String?> createAnnouncement(Announcement announcement) async {
    return await AnnouncementRestApi.createAnnouncement(announcement.toJson());
  }
  
  // PATCH update announcement
  Future<bool> updateAnnouncement(String id, Map<String, dynamic> data) async {
    return await AnnouncementRestApi.updateAnnouncement(id, data);
  }
  
  // PATCH mark as read
  Future<bool> markAsRead(String id, String userId) async {
    return await AnnouncementRestApi.markAsRead(id, userId);
  }
  
  // DELETE announcement
  Future<bool> deleteAnnouncement(String id) async {
    return await AnnouncementRestApi.deleteAnnouncement(id);
  }
  
  // POST add reaction
  Future<bool> addReaction(String id, String userId, String reaction) async {
    return await AnnouncementRestApi.addReaction(id, userId, reaction);
  }
}