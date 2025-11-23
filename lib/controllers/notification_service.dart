import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kipgo/main.dart';

// class NotificationService {
//   final notificationsPlugin = FlutterLocalNotificationsPlugin();

//   final bool _isInitiated = false;

//   bool get isInitiated => _isInitiated;

//   Future<void> initNotification() async {
//     if (_isInitiated) return;
//     // print('INITIALIZING NOTIFICATioNS');
//     const initSettingsAndroid = AndroidInitializationSettings(
//       "@mipmap/ic_launcher",
//     );

//     const initSettingsIos = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIos,
//     );

//     await notificationsPlugin.initialize(initSettings);
//     final ctx = navigatorKey.currentState?.overlay?.context;
//     if (ctx == null) return;

//     if (Theme.of(ctx).platform == TargetPlatform.android) {
//       await notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.requestNotificationsPermission();
//     }
//   }

//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'high_importance_channel',
//         'High Importance Notifications',
//         channelDescription: 'This channel is used for important notifications.',
//         importance: Importance.max,
//         priority: Priority.high,
//         sound: RawResourceAndroidNotificationSound('notification'),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentSound: true,
//         sound: 'notification.aiff',
//       ),
//     );
//   }

//   Future<void> showNotification({
//     int id = 0,
//     required String title,
//     required String body,
//   }) async {
//     return notificationsPlugin.show(id, title, body, NotificationDetails());
//   }
// }

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin;

//   NotificationService(this.notificationsPlugin);

//   bool _isInitiated = false;

//   Future<void> initNotification() async {
//     if (_isInitiated) return;
//     _isInitiated = true;

//     const initSettingsAndroid = AndroidInitializationSettings(
//       "@mipmap/ic_launcher",
//     );
//     const initSettingsIos = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIos,
//     );

//     await notificationsPlugin.initialize(initSettings);

//     // ✅ Request permission properly
//     final androidImpl = notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();

//     await androidImpl?.requestNotificationsPermission();
//   }

//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'high_importance_channel',
//         'High Importance Notifications',
//         channelDescription: 'This channel is used for important notifications.',
//         importance: Importance.max,
//         priority: Priority.high,
//         sound: RawResourceAndroidNotificationSound('notification'),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentSound: true,
//         sound: 'notification.aiff',
//       ),
//     );
//   }

//   Future<void> showNotification({
//     int id = 0,
//     required String title,
//     required String body,
//   }) async {
//     return notificationsPlugin.show(id, title, body, notificationDetails());
//   }
// }

class NotificationService {
  // --- ✅ Singleton Setup ---
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin notificationsPlugin;
  bool _isInitiated = false;

  // --- ✅ Initialize with shared plugin instance ---
  void init(FlutterLocalNotificationsPlugin plugin) {
    if (_isInitiated) return;
    notificationsPlugin = plugin;
    _isInitiated = true;
  }

  Future<void> initNotification() async {
    if (!_isInitiated) return; // Ensure plugin is injected first

    const initSettingsAndroid = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );

    const initSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIos,
    );

    await notificationsPlugin.initialize(initSettings);
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    if (Theme.of(ctx).platform == TargetPlatform.android) {
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: 'notification.aiff',
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }
}
