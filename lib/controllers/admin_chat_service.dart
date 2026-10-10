import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_chat_model.dart';

class AdminChatService {
  AdminChatService._();

  static final AdminChatService instance = AdminChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _supportChats =>
      _firestore.collection('supportChats');

  Stream<List<AdminChatPreview>> watchChats() {
    return _supportChats
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(AdminChatPreview.fromFirestore).toList(),
        );
  }

  Stream<List<AdminChatMessage>> watchMessages(String userId) {
    return _supportChats
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(AdminChatMessage.fromFirestore).toList(),
        );
  }

  Stream<AdminChatPreview?> watchChat(String userId) {
    return _supportChats.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return AdminChatPreview.fromFirestore(snapshot);
    });
  }

  Future<void> sendAdminMessage({
    required String userId,
    required String text,
  }) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      return;
    }

    final chatRef = _supportChats.doc(userId);

    final messageRef = chatRef.collection('messages').doc();

    final now = Timestamp.now();

    final batch = _firestore.batch();

    batch.set(messageRef, {
      'sender': 'admin',
      'text': trimmed,
      'timestamp': now,
    });

    batch.update(chatRef, {
      'lastMessage': trimmed,
      'lastMessageSender': 'admin',
      'lastMessageTime': now,
    });

    await batch.commit();
  }
}
