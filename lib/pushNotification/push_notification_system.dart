import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/notification_service.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/pushNotification/notification_dialog_box.dart';
import 'package:kipgo/screens/settings/vehicle_details_screen.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_provider.dart';
import '../models/user_ride_request_information.dart';

class PushNotificationSystem {
  PushNotificationSystem._privateConstructor();
  static final PushNotificationSystem _instance =
      PushNotificationSystem._privateConstructor();
  factory PushNotificationSystem() => _instance;

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool _isDialogShowing = false;
  bool _isProcessingRide = false;
  bool _isInitialized = false;

  void resetRideFlags() {
    _isDialogShowing = false;
    _isProcessingRide = false;
  }

  Future<void> initializeCloudMessaging(BuildContext context) async {
    if (_isInitialized) {
      debugPrint("⚠️ PushNotificationSystem already initialized — skipping");
      return;
    }

    _isInitialized = true;
    debugPrint("🚀 Initializing PushNotificationSystem...");

    FirebaseMessaging.onMessage.drain();
    FirebaseMessaging.onMessageOpenedApp.drain();

    // 1. Terminated state (app was killed)
    messaging.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleNotification(remoteMessage, context, fromUserTap: true);
      }
    });

    // 2. Foreground (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleNotification(remoteMessage, context, fromUserTap: false);
      }
    });

    // 3. Background (app in background, user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        _handleNotification(remoteMessage, context, fromUserTap: true);
      }
    });
  }

  /// Centralized handler
  void _handleNotification(
    RemoteMessage remoteMessage,
    BuildContext context, {
    required bool fromUserTap,
  }) {
    final notificationType = remoteMessage.data['type'];

    if (notificationType == 'rideRequest') {
      final rideRequestId = remoteMessage.data['rideRequestId'];
      if (rideRequestId != null) {
        readUserRideRequestInformation(rideRequestId);
      } else {
        debugPrint("⚠️ Missing rideRequestId in notification data.");
        print(remoteMessage.data);
      }
    } else if (notificationType == 'accountStatus') {
      final title = remoteMessage.data['title'] ?? "Notice";
      final body = remoteMessage.data['body'] ?? "";

      if (fromUserTap) {
        debugPrint("User tapped account status notification");
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => VehicleDetailsScreen()));
      } else {
        _showDialog(title, body);
      }
    } else {
      debugPrint('UNKNOWN NOTIFICATION TYPE RECEIVED');
      NotificationService().showNotification(
        title: remoteMessage.notification?.title ?? 'Message',
        body: remoteMessage.notification?.body ?? 'You have a new notification',
      );
    }
  }

  void _showDialog(String title, String message) {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null || _isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width,
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _isDialogShowing = false;
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(ctx).push(
                MaterialPageRoute(builder: (context) => VehicleDetailsScreen()),
              );
              _isDialogShowing = false;
            },
            child: Text('Vehicle Details'),
          ),
        ],
      ),
    );
  }

  Future<void> readUserRideRequestInformation(String userRideRequestId) async {
    if (_isProcessingRide) {
      debugPrint("🚫 Skipping duplicate ride request — already processing one");
      return;
    }

    _isProcessingRide = true; // 🧩 Mark as busy
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) {
      _isProcessingRide = false;
      return;
    }

    try {
      final uid = Provider.of<ProfileProvider>(ctx, listen: false).profile?.id;
      if (uid == null) {
        _isProcessingRide = false;
        return;
      }

      final driverIdSnap = await FirebaseDatabase.instance
          .ref("All Ride Requests/$userRideRequestId/driverId")
          .get();

      final driverId = driverIdSnap.value?.toString();

      if (driverId == null) {
        _isProcessingRide = false;
        return;
      }

      if (driverId == "waiting" || driverId == uid) {
        final snapData = await FirebaseDatabase.instance
            .ref("All Ride Requests/$userRideRequestId")
            .get();

        if (snapData.value != null && ctx.mounted) {
          final rideData = Map<String, dynamic>.from(snapData.value as Map);
          final userRideRequestDetails =
              UserRideRequestInformation.fromRealtime(snapData.key!, rideData);

          // ✅ Only show if no dialog already active
          if (!_isDialogShowing) {
            _isDialogShowing = true;
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (_) => NotificationDialogBox(
                userRideRequestDetails: userRideRequestDetails,
                onDialogClosed: () {
                  _isDialogShowing = false;
                  _isProcessingRide = false; // reset when dialog closes
                },
              ),
            );
          } else {
            _isProcessingRide = false;
          }
        } else {
          _isProcessingRide = false;
        }
      } else {
        _isProcessingRide = false;
      }
    } catch (e, st) {
      debugPrint("❌ Error reading ride request: $e");
      debugPrintStack(stackTrace: st);
      _isProcessingRide = false;
    }
  }

  /// Save driver token to Firestore
  Future<void> generateAndGetToken(BuildContext context) async {
    final userId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile?.id;
    if (userId == null) return;

    String? registrationToken;

    if (Platform.isIOS) {
      registrationToken = await messaging.getAPNSToken();
    } else {
      registrationToken = await messaging.getToken();
    }

    debugPrint("✅ FCM Token: $registrationToken");

    if (registrationToken != null) {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .update({'token': registrationToken});
    }
  }
}
