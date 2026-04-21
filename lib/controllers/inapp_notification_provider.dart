import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/models/app_notification.dart';

class InAppNotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void listenToNotifications(String userId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _notifications.clear();
          for (var doc in snapshot.docs) {
            _notifications.add(AppNotification.fromFirestore(doc));
          }
          notifyListeners();
        });
  }

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update(
      {'isRead': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = FirebaseFirestore.instance.batch();

    final unread = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
