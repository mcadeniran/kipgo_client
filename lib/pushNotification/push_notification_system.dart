import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/pushNotification/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    // 1. Terminated (APP is closed and open directly when notification clicked)
    messaging.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
          remoteMessage.data['rideRequestId'],
          context,
        );
      }
    });

    // 2. Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
        remoteMessage!.data['rideRequestId'],
        context,
      );
    });

    // 3. Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
        remoteMessage!.data['rideRequestId'],
        context,
      );
    });
  }

  void readUserRideRequestInformation(String userRideRequestId, context) {
    String uid = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(userRideRequestId)
        .child('driverId')
        .onValue
        .listen((event) {
          if (event.snapshot.value == 'waiting' ||
              event.snapshot.value == uid) {
            FirebaseDatabase.instance
                .ref()
                .child('All Ride Requests')
                .child(userRideRequestId)
                .once()
                .then((snapData) {
                  if (snapData.snapshot.value != null) {
                    // TODO:
                    // PLAY ALERT AUDIO

                    double originLat = double.parse(
                      (snapData.snapshot.value! as Map)['origin']['latitude'],
                    );
                    double originLng = double.parse(
                      (snapData.snapshot.value! as Map)['origin']['longitude'],
                    );
                    String originAddress =
                        (snapData.snapshot.value as Map)['originAddress'];

                    double destinationLat = double.parse(
                      (snapData.snapshot.value!
                          as Map)['destination']['latitude'],
                    );
                    double destinationLng = double.parse(
                      (snapData.snapshot.value!
                          as Map)['destination']['longitude'],
                    );
                    String destinationAddress =
                        (snapData.snapshot.value as Map)['destinationAddress'];

                    String username =
                        (snapData.snapshot.value! as Map)['username'];

                    String userPhone =
                        (snapData.snapshot.value! as Map)['userPhone'];

                    String? rideRequestId = snapData.snapshot.key;

                    UserRideRequestInformation userRideRequestDetails =
                        UserRideRequestInformation();
                    userRideRequestDetails.originLatLng = LatLng(
                      originLat,
                      originLng,
                    );
                    userRideRequestDetails.destinationLatLng = LatLng(
                      destinationLat,
                      destinationLng,
                    );
                    userRideRequestDetails.destinationAddress =
                        destinationAddress;
                    userRideRequestDetails.originAddress = originAddress;
                    userRideRequestDetails.userPhone = userPhone;
                    userRideRequestDetails.username = username;
                    userRideRequestDetails.rideRequestId = rideRequestId;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => NotificationDialogBox(
                        userRideRequestDetails: userRideRequestDetails,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This Ride does not exists."),
                      ),
                    );
                  }
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This Ride request has been cancelled."),
              ),
            );
            Navigator.pop(context);
          }
        });
  }

  Future generateAndGetToken(BuildContext context) async {
    String? userId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile?.id;
    if (userId == null) {
      return;
    }
    String? registrationToken;

    if (Platform.isIOS) {
      registrationToken = await messaging.getAPNSToken();
      print("FCM Registration Token: $registrationToken");
      // if (apnsToken != null) {
      //   print("FCM Registration Token: $apnsToken");
      //   // await _firebaseMessaging.subscribeToTopic(personID);
      // } else {
      //   await Future<void>.delayed(const Duration(seconds: 3));
      //   apnsToken = await _firebaseMessaging.getAPNSToken();
      //   if (apnsToken != null) {
      //     await _firebaseMessaging.subscribeToTopic(personID);
      //   }
      // }
    } else {
      registrationToken = await messaging.getToken();
      print("FCM Registration Token: $registrationToken");
    }

    await FirebaseFirestore.instance.collection('profiles').doc(userId).update({
      'token': registrationToken,
    });

    messaging.subscribeToTopic('allDrivers');
    messaging.subscribeToTopic('allUsers');
  }
}

// lib/pushNotification/push_notification_system.dart
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:kipgo/controllers/profile_provider.dart';
// import 'package:kipgo/main.dart';
// import 'package:kipgo/models/user_ride_request_information.dart';
// import 'package:kipgo/pushNotification/notification_dialog_box.dart';
// import 'package:kipgo/screens/homes/customer_home.dart';
// import 'package:kipgo/screens/homes/driver_home.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kipgo/firebase_options.dart';

// final FlutterLocalNotificationsPlugin
// _backgroundFlutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications',
//   description: 'This channel is used for important notifications.',
//   importance: Importance.max,
// );

// /// Top-level background handler. Exported so main.dart can register it.
// /// This runs in a background isolate. Must be top-level and async.
// @pragma("vm:entry-point")
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Ensure Firebase is initialized in the background isolate
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize local notifications plugin for background isolate
//   const AndroidInitializationSettings androidInit =
//       AndroidInitializationSettings('mipmap/ic_launcher');
//   // AndroidInitializationSettings('ic_stat_ic_notification');
//   const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
//   const InitializationSettings initSettings = InitializationSettings(
//     android: androidInit,
//     iOS: iosInit,
//   );

//   await _backgroundFlutterLocalNotificationsPlugin.initialize(initSettings);

//   // ensure channel exists
//   await _backgroundFlutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >()
//       ?.createNotificationChannel(_channel);

//   final androidDetails = AndroidNotificationDetails(
//     _channel.id,
//     _channel.name,
//     channelDescription: _channel.description,
//     importance: Importance.max,
//     priority: Priority.high,
//     icon: 'mipmap/ic_launcher',
//     // icon: 'ic_stat_ic_notification',
//   );

//   const iosDetails = DarwinNotificationDetails();

//   final notifDetails = NotificationDetails(
//     android: androidDetails,
//     iOS: iosDetails,
//   );

//   await _backgroundFlutterLocalNotificationsPlugin.show(
//     message.hashCode,
//     message.data['title'] ?? message.notification?.title ?? 'Notification',
//     message.data['body'] ?? message.notification?.body ?? '',
//     notifDetails,
//     payload: message.data['type'] ?? '',
//   );
// }

// class PushNotificationSystem {
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final FlutterLocalNotificationsPlugin localNotifications =
//       FlutterLocalNotificationsPlugin();

//   /// Initialize plugin and create channel. Call this BEFORE runApp or at app startup.
//   Future<void> initializeLocalNotifications() async {
//     // Android: use a white notification icon (ic_stat_ic_notification in res/drawable)
//     const androidInit = AndroidInitializationSettings(
//       'mipmap/ic_launcher',
//       // 'ic_stat_ic_notification',
//     );
//     const iosInit = DarwinInitializationSettings();

//     const initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iosInit,
//     );

//     // Initialize plugin
//     await localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (details) {
//         final payload = details.payload;
//         if (payload != null && payload.isNotEmpty) {
//           _handleLocalNotificationClick(payload);
//         }
//       },
//     );

//     // Create channel (Android)
//     await localNotifications
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(_channel);
//   }

//   /// Show a local notification (foreground messages)
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     try {
//       final androidDetails = AndroidNotificationDetails(
//         _channel.id,
//         _channel.name,
//         channelDescription: _channel.description,
//         importance: Importance.max,
//         priority: Priority.high,
//         icon: 'mipmap/ic_launcher',
//         // icon: 'ic_stat_ic_notification',
//       );

//       const iosDetails = DarwinNotificationDetails();
//       final notifDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       final payload = message.data['type'] == 'accountStatus'
//           ? 'accountStatus-${message.data['role']}'
//           : 'rideRequest-${message.data['rideRequestId']}';

//       await localNotifications.show(
//         message.hashCode,
//         message.data['title'] ?? message.notification?.title ?? "Notification",
//         message.data['body'] ?? message.notification?.body ?? "",
//         notifDetails,
//         payload: payload,
//       );
//     } catch (e, st) {
//       debugPrint("❌ Error showing local notification: $e\n$st");
//     }
//   }

//   /// Set up messaging listeners. Call this once from a Widget's initState (after initializeLocalNotifications).
//   Future<void> initializeCloudMessaging(BuildContext context) async {
//     // Register background handler (top-level function)
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // If app launched from terminated state via notification
//     messaging.getInitialMessage().then((remoteMessage) {
//       if (remoteMessage != null) {
//         _handleNotificationClick(remoteMessage);
//       }
//     });

//     // Foreground messages: show local notification
//     FirebaseMessaging.onMessage.listen((remoteMessage) {
//       _showLocalNotification(remoteMessage);
//     });

//     // When the app is opened from background via notification tap
//     FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
//       _handleNotificationClick(remoteMessage);
//     });
//   }

//   /// Handle tap on the local notification payload string
//   void _handleLocalNotificationClick(String payload) {
//     final parts = payload.split('-');
//     final type = parts[0];

//     if (type == 'accountStatus') {
//       final role = parts.length > 1 ? parts[1] : 'rider';
//       if (role == 'driver') {
//         navigatorKey.currentState?.pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const DriverHome()),
//           (route) => false,
//         );
//       } else {
//         navigatorKey.currentState?.pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const CustomerHome()),
//           (route) => false,
//         );
//       }
//     } else if (type == 'rideRequest') {
//       final rideRequestId = parts.length > 1 ? parts[1] : null;
//       if (rideRequestId != null) {
//         final navContext = navigatorKey.currentState!.context;
//         readUserRideRequestInformation(rideRequestId, navContext);
//       }
//     } else {
//       // unknown payload - ignore
//     }
//   }

//   /// Handle tap on remote message (when app resumed / opened)
//   void _handleNotificationClick(RemoteMessage remoteMessage) {
//     final type = remoteMessage.data['type'];

//     if (type == 'rideRequest') {
//       final rideRequestId = remoteMessage.data['rideRequestId'];
//       final navContext = navigatorKey.currentState!.context;
//       readUserRideRequestInformation(rideRequestId, navContext);
//     } else if (type == 'accountStatus') {
//       final role = remoteMessage.data['role'];
//       final navContext = navigatorKey.currentState!.context;

//       if (role == 'driver') {
//         Navigator.pushAndRemoveUntil(
//           navContext,
//           MaterialPageRoute(builder: (_) => const DriverHome()),
//           (route) => false,
//         );
//       } else {
//         Navigator.pushAndRemoveUntil(
//           navContext,
//           MaterialPageRoute(builder: (_) => const CustomerHome()),
//           (route) => false,
//         );
//       }
//     }
//   }

//   /// Read Ride Request Info and show dialog (same as before)
//   void readUserRideRequestInformation(
//     String userRideRequestId,
//     BuildContext context,
//   ) {
//     String uid = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!.id;

//     FirebaseDatabase.instance
//         .ref()
//         .child('All Ride Requests')
//         .child(userRideRequestId)
//         .child('driverId')
//         .onValue
//         .listen((event) async {
//           if (event.snapshot.value == 'waiting' ||
//               event.snapshot.value == uid) {
//             FirebaseDatabase.instance
//                 .ref()
//                 .child('All Ride Requests')
//                 .child(userRideRequestId)
//                 .once()
//                 .then((snapData) async {
//                   if (snapData.snapshot.value != null) {
//                     // Play sound (asset path)
//                     try {
//                       await _audioPlayer.play(
//                         AssetSource('assets/sounds/notification.mp3'),
//                       );
//                     } catch (e) {
//                       debugPrint("Could not play sound: $e");
//                     }

//                     final data = Map<String, dynamic>.from(
//                       snapData.snapshot.value as Map,
//                     );

//                     UserRideRequestInformation userRideRequestDetails =
//                         UserRideRequestInformation();
//                     userRideRequestDetails.originLatLng = LatLng(
//                       double.parse(data['origin']['latitude'].toString()),
//                       double.parse(data['origin']['longitude'].toString()),
//                     );
//                     userRideRequestDetails.destinationLatLng = LatLng(
//                       double.parse(data['destination']['latitude'].toString()),
//                       double.parse(data['destination']['longitude'].toString()),
//                     );
//                     userRideRequestDetails.originAddress =
//                         data['originAddress']?.toString() ?? '';
//                     userRideRequestDetails.destinationAddress =
//                         data['destinationAddress']?.toString() ?? '';
//                     userRideRequestDetails.username =
//                         data['username']?.toString() ?? '';
//                     userRideRequestDetails.userPhone =
//                         data['userPhone']?.toString() ?? '';
//                     userRideRequestDetails.rideRequestId =
//                         snapData.snapshot.key;

//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) => NotificationDialogBox(
//                         userRideRequestDetails: userRideRequestDetails,
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("This ride does not exist."),
//                       ),
//                     );
//                   }
//                 });
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("This ride request has been cancelled."),
//               ),
//             );
//             Navigator.pop(context);
//           }
//         });
//   }

//   /// Generate and save FCM token
//   Future<void> generateAndGetToken(BuildContext context) async {
//     String userId = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!.id;
//     String? registrationToken = await messaging.getToken();

//     if (registrationToken != null) {
//       await FirebaseFirestore.instance
//           .collection('profiles')
//           .doc(userId)
//           .update({'token': registrationToken});
//       debugPrint("✅ FCM Token: $registrationToken");
//     }

//     messaging.subscribeToTopic('allDrivers');
//     messaging.subscribeToTopic('allUsers');
//   }
// }
