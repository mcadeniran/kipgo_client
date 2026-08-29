import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/notification_service.dart';
import 'package:kipgo/controllers/ringtone_service.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/pushNotification/notification_dialog_box.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_crypto_payment_details_page.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/rental_booking_details_page.dart';
import 'package:kipgo/screens/rides/drivers/new_trip_screen.dart';
import 'package:kipgo/screens/settings/vehicle_details_screen.dart';
import 'package:kipgo/screens/shuttle/booking_details/shuttle_booking_details_page.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_provider.dart';
import '../models/user_ride_request_information.dart';

class PushNotificationSystem {
  PushNotificationSystem._privateConstructor();
  static final PushNotificationSystem _instance =
      PushNotificationSystem._privateConstructor();
  factory PushNotificationSystem() => _instance;

  VoidCallback? onAcceptRide;
  VoidCallback? onRejectRide;

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground FCM received");

      // 🔔 iOS foreground sound handling
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final title = message.notification?.title ?? message.data['title'];
        final body = message.notification?.body ?? message.data['body'];

        // Play sound + show banner manually
        NotificationService().showNotification(
          title: title ?? 'Notification',
          body: body ?? '',
        );
      }

      // 🧠 KEEP your existing routing logic
      _handleNotification(message, context, fromUserTap: false);
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
    // final service = remoteMessage.data['service'] ?? 'rental';

    if (notificationType == 'rideRequest') {
      final rideRequestId = remoteMessage.data['rideRequestId'];
      if (rideRequestId != null) {
        readUserRideRequestInformation(rideRequestId);
      } else {
        debugPrint("⚠️ Missing rideRequestId in notification data.");
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
    } else if (_isBusinessNotification(notificationType)) {
      if (fromUserTap) {
        _navigateFromNotification(context, remoteMessage.data);
      } else {
        _showNotificationToast(context, remoteMessage);
      }
    } else {
      debugPrint('UNKNOWN NOTIFICATION TYPE RECEIVED');
    }

    if (!fromUserTap && !_isBusinessNotification(notificationType)) {
      NotificationService().showNotification(
        title: remoteMessage.notification?.title ?? remoteMessage.data['title'],

        body: remoteMessage.notification?.body ?? remoteMessage.data['body'],
      );
    }
  }

  // bool _isRentalService(Map<String, dynamic> data) {
  //   return (data['service'] ?? 'rental') == 'rental';
  // }

  // bool _isShuttleService(Map<String, dynamic> data) {
  //   return (data['service'] ?? 'rental') == 'shuttle';
  // }

  bool _isBusinessNotification(String? type) {
    return const [
      // Rental
      'bookingUpdate',
      'paymentUpdate',
      'dropoffReminder',
      'newBooking',
      'cryptoVerification',

      // Shuttle
      'shuttleBookingUpdate',
      'shuttlePaymentUpdate',
      'newShuttleBooking',
      'shuttleCryptoVerification',
    ].contains(type);
  }

  void _navigateFromNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final audience = data['audience'];
    final bookingId = data['bookingId'];
    final service = data['service'] ?? 'rental';

    if (bookingId == null) return;

    switch (audience) {
      case 'customer':
        switch (service) {
          case 'shuttle':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShuttleBookingDetailsPage(bookingId: bookingId),
              ),
            );
            break;

          case 'rental':
          default:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookingDetailsPage(bookingId: bookingId),
              ),
            );
        }
        break;

      case 'shop':
        if (service == 'shuttle') {
          // Shuttle admin is handled on the web.
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RentalBookingDetailsPage(bookingId: bookingId),
          ),
        );
        break;

      case 'admin':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminCryptoPaymentDetailsPage(bookingId: bookingId),
          ),
        );
        break;
    }
  }

  void _showNotificationToast(BuildContext context, RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';

    final body = message.notification?.body ?? message.data['body'] ?? '';

    ReusableToast.info(
      context,
      title,
      body,
      () => _navigateFromNotification(context, message.data),
    );
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
            child: Text(AppLocalizations.of(ctx)!.ok),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(ctx).push(
                MaterialPageRoute(builder: (context) => VehicleDetailsScreen()),
              );
              _isDialogShowing = false;
            },
            child: Text(AppLocalizations.of(ctx)!.vehicleDetails),
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

    TextEditingController priceController = TextEditingController();
    final priceKey = GlobalKey<FormState>();

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
              UserRideRequestInformation.fromRealtime(
                snapData.key!,
                rideData,
                driverId,
              );

          // ✅ Only show if no dialog already active
          if (!_isDialogShowing) {
            // 🔔 Start ringing sound
            RingtoneService().playRideRequestTone();

            _isDialogShowing = true;
            showRideRequestBottomSheet(
              context: ctx,
              ride: userRideRequestDetails,
              onDialogClosed: () {
                RingtoneService().stop();
                _isDialogShowing = false;
                _isProcessingRide = false;
              },
              priceKey: priceKey,
              priceController: priceController,
            );
          } else {
            _isProcessingRide = false;
          }
        } else {
          _isProcessingRide = false;
        }
      } else {
        _isProcessingRide = false;
        await FirebaseDatabase.instance.ref("drivers/$uid").update({
          "status": "idle",
          "currentRideId": null,
          "pendingSince": null,
        });
      }
    } catch (e, st) {
      debugPrint("❌ Error reading ride request: $e");
      debugPrintStack(stackTrace: st);
      _isProcessingRide = false;
    }
  }

  void showFareAcceptedDialog(UserRideRequestInformation ride) {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    // 🔕 STOP RINGING
    RingtoneService().stop();

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.fareAccepted),
        content: Text(AppLocalizations.of(ctx)!.theRiderAcceptedFare),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();

              if (onAcceptRide != null) {
                onAcceptRide!();
              }

              Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => NewTripScreen(userRideRequestDetails: ride),
                ),
              );
            },
            child: Text(AppLocalizations.of(ctx)!.ok),
          ),
        ],
      ),
    );
  }

  void showFareRejectedDialog() {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    // 🔕 STOP RINGING
    RingtoneService().stop();

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.fareRejected),
        content: Text(AppLocalizations.of(ctx)!.theRiderRejectedFare),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(AppLocalizations.of(ctx)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> generateAndGetToken(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final uid = auth.firebaseUser?.uid;
    final role = auth.role;

    if (uid == null || role == null) {
      debugPrint("⚠️ No authenticated user yet");
      return;
    }

    String? fcmToken;

    // ===============================
    // 🍏 iOS Handling
    // ===============================
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;

      final bool isSimulator = !iosInfo.isPhysicalDevice;

      if (!isSimulator) {
        String? apnsToken;

        for (int i = 0; i < 10 && apnsToken == null; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (apnsToken == null) {
          debugPrint("⚠️ APNs token not available");
          return;
        }

        fcmToken = await FirebaseMessaging.instance.getToken();
      } else {
        debugPrint("🧪 iOS Simulator detected — skipping APNs");
      }
    } else {
      // 🤖 Android
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (fcmToken == null) return;

    debugPrint("✅ FCM Token: $fcmToken");

    final firestore = FirebaseFirestore.instance;

    // ===============================
    // 🎯 ROLE-BASED STORAGE
    // ===============================
    try {
      if (role == 'rental_admin' || role == 'shuttle_admin') {
        // ✅ MULTI TOKEN (ARRAY)
        await firestore
            .collection(
              role == 'rental_admin' ? 'rentalShops' : 'shuttleRental',
            )
            .doc(uid)
            .update({
              'tokens': FieldValue.arrayUnion([fcmToken]),
            });

        debugPrint("🏢 Token added to rentalShop");
      } else {
        // ✅ SINGLE TOKEN
        await firestore.collection('profiles').doc(uid).update({
          'token': fcmToken,
        });

        debugPrint("👤 Token saved to profile");
      }
    } catch (e) {
      debugPrint("❌ Failed to save token: $e");
    }
  }

  void initTokenRefreshListener(BuildContext context) {
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String newToken) async {
        debugPrint("🔄 FCM Token refreshed: $newToken");

        final auth = Provider.of<AuthProvider>(context, listen: false);

        final uid = auth.firebaseUser?.uid;
        final role = auth.role;

        if (uid == null || role == null) return;

        if (role == 'rental_admin' || role == 'shuttle_admin') {
          await FirebaseFirestore.instance
              .collection(
                role == 'rental_admin' ? 'rentalShops' : 'shuttleRental',
              )
              .doc(uid)
              .update({
                'tokens': FieldValue.arrayUnion([newToken]),
              });
        } else {
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(uid)
              .update({'token': newToken});
        }

        debugPrint("✅ New token saved to Firestore");
      },
      onError: (e) {
        debugPrint("❌ Token refresh error: $e");
      },
    );
  }

  Future<void> removeTokenOnLogout(BuildContext context) async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.firebaseUser?.uid;
    final role = auth.role;

    if (uid == null || role == null) return;

    if (role == 'rental_admin' || role == 'shuttle_admin') {
      await FirebaseFirestore.instance
          .collection(role == 'rental_admin' ? 'rentalShops' : 'shuttleRental')
          .doc(uid)
          .update({
            'tokens': FieldValue.arrayRemove([token]),
          });
    }
  }

  void registerRideCallbacks({
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    onAcceptRide = onAccept;
    onRejectRide = onReject;
  }
}
