// lib/data/repositories/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_campus_app/data/models/notifications/notification_model.dart';


class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').doc(notification.id).set(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('targetAudience', arrayContains: userId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}