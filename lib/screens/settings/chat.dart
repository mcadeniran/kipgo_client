import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final user = Provider.of<ProfileProvider>(context, listen: false).profile!;
    final messageText = _controller.text.trim();

    final message = {
      "sender": "user",
      "text": messageText,
      "timestamp": FieldValue.serverTimestamp(),
      "username": user.username,
    };

    final chatDoc = FirebaseFirestore.instance
        .collection("supportChats")
        .doc(user.id);

    // Save message in subcollection
    await chatDoc.collection("messages").add(message);

    // Update parent chat doc with last message info
    await chatDoc.set({
      "username": user.username,
      "avatarUrl": user.personal.photoUrl, // if available
      "role": user.role,
      "lastMessage": messageText,
      "lastMessageSender": "user",
      "lastMessageTime": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final userId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    final messagesRef = FirebaseFirestore.instance
        .collection("supportChats")
        .doc(userId)
        .collection("messages")
        .orderBy("timestamp", descending: true);

    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.supportChat.toUpperCase(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: messagesRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            messages[index].data() as Map<String, dynamic>;
                        final isUser = msg["sender"] == "user";

                        // Convert Firestore timestamp to DateTime
                        final Timestamp? ts = msg["timestamp"];
                        final DateTime? time = ts?.toDate();
                        final String formattedTime = time != null
                            ? timeago.format(time)
                            : "";

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? isDark
                                        ? AppColors.primary
                                        : AppColors.primary
                                  : isDark
                                  ? AppColors.darkLayer
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg["text"] ?? "",
                                  style: TextStyle(
                                    color: !isUser && !isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedTime, // e.g. "2 minutes ago"
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: (isUser
                                        ? Colors.white70
                                        : isDark
                                        ? Colors.white70
                                        : Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 3,
                        minLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.typeYourMessage,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: Icon(
                        Icons.send,
                        color: isDark ? AppColors.darkLayer : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
