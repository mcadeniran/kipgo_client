import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String audience;
  final String body;
  final String type;
  final String? bookingId;
  final String? status;
  final bool isRead;
  final DateTime createdAt;
  final String service;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.audience,
    this.bookingId,
    this.status,
    required this.isRead,
    required this.createdAt,
    required this.service,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      audience: data['audience'] ?? '',
      type: data['type'] ?? '',
      bookingId: data['bookingId'],
      status: data['status'],
      isRead: data['isRead'] ?? false,
      service: data['service'] ?? 'rental',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
