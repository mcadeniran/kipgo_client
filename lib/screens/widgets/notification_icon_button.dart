import 'package:flutter/material.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/screens/widgets/notification_screen.dart';
import 'package:provider/provider.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InAppNotificationProvider>(
      builder: (_, provider, __) {
        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen()),
            );
          },
          icon: buildCustomBadge(
            child: Icon(Icons.notifications),
            value: provider.unreadCount > 99
                ? '99+'
                : provider.unreadCount.toString(),
          ),
        );
      },
    );
  }

  Widget buildCustomBadge({required String value, required Widget child}) {
    // final text = value.toString();
    final deltaFontSize = (value.length - 1) * 3.0;

    return Stack(
      // fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -10,
          right: -10,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 12,
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14 - deltaFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
