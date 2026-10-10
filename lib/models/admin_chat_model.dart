import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminChatSender { user, admin }

class AdminChatMessage {
  final String id;
  final AdminChatSender sender;
  final String text;
  final DateTime timestamp;

  const AdminChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  bool get isAdmin => sender == AdminChatSender.admin;
  bool get isUser => sender == AdminChatSender.user;

  factory AdminChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final senderValue = data['sender'] as String?;

    return AdminChatMessage(
      id: doc.id,
      sender: senderValue == 'admin'
          ? AdminChatSender.admin
          : AdminChatSender.user,
      text: data['text'] as String? ?? '',
      timestamp: _parseTimestamp(data['timestamp']),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}

class AdminChatPreview {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String role;
  final String? lastMessage;
  final AdminChatSender? lastMessageSender;
  final DateTime? lastMessageTime;

  const AdminChatPreview({
    required this.userId,
    required this.username,
    required this.role,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime,
  });

  bool get needsAttention => lastMessageSender == AdminChatSender.user;

  bool get isDriver => role == 'driver';

  bool get isRider => role == 'rider';

  factory AdminChatPreview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final sender = data['lastMessageSender'] as String?;

    return AdminChatPreview(
      userId: doc.id,
      username: data['username'] as String? ?? 'User',
      avatarUrl: data['avatarUrl'] as String?,
      role: data['role'] as String? ?? 'rider',
      lastMessage: data['lastMessage'] as String?,
      lastMessageSender: sender == 'admin'
          ? AdminChatSender.admin
          : sender == 'user'
          ? AdminChatSender.user
          : null,
      lastMessageTime: _parseTimestampNullable(data['lastMessageTime']),
    );
  }

  static DateTime? _parseTimestampNullable(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
