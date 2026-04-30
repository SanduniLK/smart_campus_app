// lib/data/repositories/announcement/announcement_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_campus_app/data/models/announce/announcement_model.dart';


class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  CollectionReference get _announcements => 
      _firestore.collection('announcements');
  
  // Create announcement
  Future<void> createAnnouncement(Announcement announcement) async {
    try {
      await _announcements.doc(announcement.id).set(announcement.toFirestore());
      print('✅ Announcement created: ${announcement.title}');
    } catch (e) {
      print('❌ Error creating announcement: $e');
      throw Exception('Failed to create announcement: $e');
    }
  }
  
  // Get all announcements with real-time stream
  Stream<List<Announcement>> getAnnouncementsStream() {
    return _announcements
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Announcement.fromFirestore(data, doc.id);
          }).toList();
        });
  }
  
  // Get announcements by type
  Stream<List<Announcement>> getAnnouncementsByTypeStream(String type) {
    return _announcements
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Announcement.fromFirestore(data, doc.id);
          }).toList();
        });
  }
  
  // Get single announcement
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final doc = await _announcements.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Announcement.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting announcement: $e');
      return null;
    }
  }
  
  // Update announcement
  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      await _announcements.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Announcement updated: $id');
    } catch (e) {
      print('❌ Error updating announcement: $e');
      throw Exception('Failed to update announcement: $e');
    }
  }
  
  // Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _announcements.doc(id).delete();
      print('✅ Announcement deleted: $id');
    } catch (e) {
      print('❌ Error deleting announcement: $e');
      throw Exception('Failed to delete announcement: $e');
    }
  }
  
  // Mark announcement as read
  Future<void> markAsRead(String announcementId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      await _announcements.doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([userId])
      });
      print('✅ Announcement marked as read: $announcementId');
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }
  
  // Check if user has read announcement
  Future<bool> hasUserRead(String announcementId, String userId) async {
    try {
      final doc = await _announcements.doc(announcementId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final readBy = List<String>.from(data['readBy'] ?? []);
        return readBy.contains(userId);
      }
      return false;
    } catch (e) {
      print('❌ Error checking read status: $e');
      return false;
    }
  }
  
  // Add reaction to announcement
  Future<void> addReaction(String announcementId, String reaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      await _announcements.doc(announcementId).update({
        'reactions.$userId': reaction
      });
      print('✅ Reaction added: $announcementId');
    } catch (e) {
      print('❌ Error adding reaction: $e');
    }
  }
}