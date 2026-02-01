import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/ringtone_service.dart';
// import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/fare_status_listener.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/screens/rides/drivers/new_trip_screen.dart';
import 'package:kipgo/utils/colors.dart';

// class NotificationDialogBox extends StatefulWidget {
//   final UserRideRequestInformation userRideRequestDetails;
//   final VoidCallback? onDialogClosed;

//   const NotificationDialogBox({
//     super.key,
//     required this.userRideRequestDetails,
//     this.onDialogClosed,
//   });

//   @override
//   State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
// }

// class _NotificationDialogBoxState extends State<NotificationDialogBox> {
//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       child: Container(
//         margin: EdgeInsets.all(2),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Theme.of(context).scaffoldBackgroundColor,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset('assets/images/taksi.png', width: 150, height: 150),
//             SizedBox(height: 0),
//             Text(
//               AppLocalizations.of(context)!.newRideRequest,
//               style: Theme.of(
//                 context,
//               ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 14),
//             Divider(height: 2, thickness: 2, color: AppColors.border),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               child: Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Image.asset(
//                         'assets/images/origin.png',
//                         color: isDark ? Colors.tealAccent : AppColors.primary,
//                         width: 30,
//                         height: 30,
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           widget.userRideRequestDetails.originAddress!,
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Image.asset(
//                         'assets/images/destination.png',
//                         color: isDark ? AppColors.tertiary : AppColors.tertiary,
//                         width: 30,
//                         height: 30,
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           widget.userRideRequestDetails.destinationAddress!,
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Divider(height: 2, thickness: 2, color: AppColors.border),
//             Padding(
//               padding: EdgeInsets.all(14),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Stop audio
//                       widget.onDialogClosed?.call();
//                       rejectRideRequest(context);
//                       // Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.tertiary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     child: Text(
//                       AppLocalizations.of(context)!.reject,
//                       style: TextStyle(fontSize: 15, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       // TODO:
//                       // Stop audio
//                       debugPrint('REQUEST ACCEPTED');
//                       widget.onDialogClosed?.call();
//                       acceptRideRequest(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     child: Text(
//                       AppLocalizations.of(context)!.accept,
//                       style: TextStyle(fontSize: 15, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void acceptRideRequest(BuildContext context) async {
//     final driverId = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!.id;

//     final rideRequestId = widget.userRideRequestDetails.rideRequestId;

//     try {
//       // 1️⃣ Check if the ride request still exists in Realtime DB
//       final rideSnapshot = await FirebaseDatabase.instance
//           .ref("All Ride Requests/$rideRequestId")
//           .get();

//       if (!rideSnapshot.exists) {
//         // 🚫 Rider has probably cancelled — stop flow
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 AppLocalizations.of(context)!.rideRequestIsNotAvailable,
//               ),
//             ),
//           );
//           Navigator.pop(context); // close dialog
//         }
//         return;
//       }

//       // 2️⃣ Confirm driver is idle before accepting
//       final driverDoc = await FirebaseFirestore.instance
//           .collection("profiles")
//           .doc(driverId)
//           .get();

//       final driverStatus = driverDoc.data()?['newRideStatus'];

//       if (driverStatus == null || driverStatus == 'idle') {
//         // 3️⃣ Update driver status → accepted
//         await FirebaseFirestore.instance
//             .collection('profiles')
//             .doc(driverId)
//             .update({'newRideStatus': 'accepted'});

//         // Optionally set driver offline
//         Provider.of<DriverStatusProvider>(
//           context,
//           listen: false,
//         ).toggleStatus(false, context);

//         // 4️⃣ Close dialog before navigating
//         if (context.mounted) Navigator.pop(context);

//         // 5️⃣ Proceed to trip screen
//         if (context.mounted) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (c) => NewTripScreen(
//                 userRideRequestDetails: widget.userRideRequestDetails,
//               ),
//             ),
//           );
//         }
//       } else {
//         // 6️⃣ Another ride already accepted or status mismatch
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 AppLocalizations.of(context)!.rideRequestIsNotAvailable,
//               ),
//             ),
//           );
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error while accepting ride: $e");
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               AppLocalizations.of(context)!.errorProcessingRideRequest,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void rejectRideRequest(BuildContext context) async {
//     String driverId = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!.id;

//     final rideRequestId = widget.userRideRequestDetails.rideRequestId;

//     try {
//       // 1️⃣ Check if the ride request still exists in Realtime DB
//       final rideSnapshot = await FirebaseDatabase.instance
//           .ref("All Ride Requests/$rideRequestId")
//           .get();

//       if (!rideSnapshot.exists) {
//         // 🚫 Rider has probably cancelled — stop flow
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 AppLocalizations.of(context)!.rideRequestIsNotAvailable,
//               ),
//             ),
//           );
//           Navigator.pop(context); // close dialog
//         }
//         return;
//       }

//       // Update driver status back to idle (or rejected state)
//       await FirebaseFirestore.instance
//           .collection('profiles')
//           .doc(driverId)
//           .update({'newRideStatus': 'idle'});

//       DatabaseReference databaseReference = FirebaseDatabase.instance
//           .ref()
//           .child('All Ride Requests')
//           .child(widget.userRideRequestDetails.rideRequestId!);

//       databaseReference.child('status').set('rejected');

//       debugPrint("REJECTING RIDE...");

//       Navigator.pop(context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocalizations.of(context)!.rideRequestRejected),
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error rejecting ride: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to reject ride")));
//     }
//   }
// }

class _RideRequestSheetContent extends StatefulWidget {
  final UserRideRequestInformation ride;
  final GlobalKey<FormState> priceKey;
  final TextEditingController priceController;
  final VoidCallback? onDialogClosed;

  const _RideRequestSheetContent({
    required this.ride,
    required this.priceKey,
    required this.priceController,
    required this.onDialogClosed,
  });

  @override
  State<_RideRequestSheetContent> createState() =>
      _RideRequestSheetContentState();
}

class _RideRequestSheetContentState extends State<_RideRequestSheetContent> {
  final AudioPlayer player = AudioPlayer();
  StreamSubscription? fareSubscription;
  bool _isShowingSingleDialog = false;

  BuildContext get safeContext {
    if (mounted) return context;
    if (navigatorKey.currentContext != null) {
      return navigatorKey.currentContext!;
    }
    throw Exception("No valid context available");
  }

  Future<bool> _isRideStillAvailable() async {
    final ref = FirebaseDatabase.instance.ref(
      "All Ride Requests/${widget.ride.rideRequestId}",
    );

    final snapshot = await ref.get();

    if (!snapshot.exists) return false;

    return true;
  }

  Future<bool> _guardRideAvailability() async {
    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return false;
    }

    return true;
  }

  Future<void> _showRideCancelledDialog() async {
    await _showSingleDialog(
      title: AppLocalizations.of(safeContext)!.rideCancelled,
      message: AppLocalizations.of(safeContext)!.riderHasCancelledTheRequest,
      onOk: () {
        Navigator.of(navigatorKey.currentContext!).pop(); // close sheet
      },
    );
  }

  Future<void> proposeFare(double enteredFare) async {
    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return;
    }
    await FirebaseDatabase.instance
        .ref('All Ride Requests/${widget.ride.rideRequestId}')
        .update({
          "proposedFare": enteredFare, // e.g. 1500
          "fareStatus": "waiting_for_rider",
        });
  }

  void listenForRiderFareAcceptance() {
    final ref = FirebaseDatabase.instance.ref(
      "All Ride Requests/${widget.ride.rideRequestId}",
    );

    fareSubscription?.cancel();

    fareSubscription = ref.onValue.listen((event) async {
      if (!mounted) return;

      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final status = data["fareStatus"];

      // Rider accepted the proposed fare
      if (status == "accepted") {
        // Close loading dialog safely
        _closeProgressDialogSafely();

        await player.play(AssetSource('sounds/notification.mp3'));

        // final ctx = safeContext;

        await _showSingleDialog(
          title: AppLocalizations.of(context)!.fareAccepted,
          message: AppLocalizations.of(context)!.theRiderAcceptedFare,
          onOk: () {
            // acceptRide();
          },
        );
      }

      // Rider rejected the fare
      if (status == "rejected") {
        _closeProgressDialogSafely();

        final ctx = safeContext;

        await _showSingleDialog(
          title: AppLocalizations.of(ctx)!.fareRejected,
          message: AppLocalizations.of(ctx)!.theRiderRejectedFare,
          onOk: () {},
        );
      }
    });
  }

  // ───────────────────────────────────────────
  // SAFE DIALOG (SINGLE INSTANCE)
  // ───────────────────────────────────────────
  Future<void> _showSingleDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
    String okLabel = "OK",
  }) async {
    if (_isShowingSingleDialog) return;
    _isShowingSingleDialog = true;

    BuildContext dialogCtx;
    try {
      dialogCtx = safeContext;
    } catch (_) {
      _isShowingSingleDialog = false;
      return;
    }

    if (!mounted) {
      _isShowingSingleDialog = false;
      return;
    }

    await showDialog<void>(
      context: dialogCtx,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(c)) Navigator.pop(c);
              onOk();
            },
            child: Text(okLabel),
          ),
        ],
      ),
    ).whenComplete(() {
      _isShowingSingleDialog = false;
    });
  }

  // ─────────────────────────
  // SAFE POP FOR LOADING DIALOG
  // ─────────────────────────
  void _closeProgressDialogSafely() {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    if (Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    PushNotificationSystem().registerRideCallbacks(
      onAccept: () {
        acceptRide();
      },
      onReject: () {
        // optional: rejectRide();
      },
    );
  }

  // ───────
  // DISPOSE
  // ───────
  @override
  void dispose() {
    fareSubscription?.cancel();
    RingtoneService().stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/taksi.png', width: 150, height: 150),
        SizedBox(height: 0),
        Text(
          AppLocalizations.of(context)!.newRideRequest,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 14),
        Divider(height: 2, thickness: 2, color: AppColors.border),

        // ORIGIN + DESTINATION
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/origin.png',
                    color: isDark ? Colors.tealAccent : AppColors.primary,
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.ride.originAddress!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/destination.png',
                    color: AppColors.tertiary,
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.ride.destinationAddress!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Divider(height: 2, thickness: 2, color: AppColors.border),
        SizedBox(height: 10),

        // ENTER FARE
        Text(
          AppLocalizations.of(context)!.enterFare,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        TextFormField(
          controller: widget.priceController,
          keyboardType: TextInputType.number,
          decoration: inputDecoration(
            context: context,
            hint: AppLocalizations.of(context)!.enterPrice,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.priceCannotBeEmpty;
            }

            final cleaned = value.replaceAll(",", "").trim();
            final amount = double.tryParse(cleaned);

            if (amount == null) {
              return AppLocalizations.of(context)!.invalidFare;
            }
            if (amount < 1) {
              return AppLocalizations.of(context)!.fareCannotBeLessThan;
            }

            return null;
          },
        ),

        // BUTTONS
        Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => rejectRide(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.reject,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  if (widget.priceKey.currentState!.validate()) {
                    final canProceed = await _guardRideAvailability();
                    if (!canProceed) return;
                    Navigator.of(context).pop();

                    showDialog(
                      context: navigatorKey.currentContext!,
                      builder: (_) => ProgressDialog(
                        message: AppLocalizations.of(
                          context,
                        )!.waitingForRiderResponse,
                      ),
                    );

                    proposeFare(double.parse(widget.priceController.text));

                    // listen for rider response
                    // listenForRiderFareAcceptance();
                    FareStatusListener.start(
                      rideRequestId: widget.ride.rideRequestId!,
                      onAccepted: () {
                        _closeProgressDialogSafely();
                        FareStatusListener.stop();
                        // acceptRide();
                        PushNotificationSystem().showFareAcceptedDialog(
                          widget.ride,
                        );
                      },
                      onRejected: () {
                        _closeProgressDialogSafely();
                        FareStatusListener.stop();
                        // _showFareRejectedDialog();
                        PushNotificationSystem().showFareRejectedDialog();
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.accept,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────
  // REJECT RIDE
  // ───────────
  void rejectRide() async {
    widget.onDialogClosed?.call();

    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return;
    }

    final driverId = Provider.of<ProfileProvider>(
      navigatorKey.currentContext!,
      listen: false,
    ).profile!.id;

    try {
      await FirebaseDatabase.instance
          .ref("All Ride Requests/${widget.ride.rideRequestId}")
          .update({"status": "rejected"});

      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(driverId)
          .update({'newRideStatus': 'idle'});

      Navigator.of(navigatorKey.currentContext!).pop();
    } catch (e) {
      debugPrint("Reject error: $e");
    }
  }

  // void rejectRide() async {
  //   widget.onDialogClosed?.call();
  //   final driverId = Provider.of<ProfileProvider>(
  //     context,
  //     listen: false,
  //   ).profile!.id;

  //   try {
  //     DatabaseReference ref = FirebaseDatabase.instance.ref(
  //       "All Ride Requests/${widget.ride.rideRequestId}",
  //     );

  //     if (!(await ref.get()).exists) {
  //       if (mounted) {
  //         Navigator.pop(context);
  //       } else if (navigatorKey.currentContext != null) {
  //         Navigator.pop(navigatorKey.currentContext!);
  //       }
  //       return;
  //     }

  //     await FirebaseFirestore.instance
  //         .collection("profiles")
  //         .doc(driverId)
  //         .update({'newRideStatus': 'idle'});

  //     ref.child("status").set("rejected");

  //     if (context.mounted) {
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     debugPrint("Reject error: $e");
  //   }
  // }

  // ───────────
  // ACCEPT RIDE
  // ───────────
  void acceptRide() async {
    widget.onDialogClosed?.call();

    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return;
    }

    final driverId = Provider.of<ProfileProvider>(
      navigatorKey.currentContext!,
      listen: false,
    ).profile!.id;

    final rideRequestId = widget.ride.rideRequestId;

    try {
      final rideSnapshot = await FirebaseDatabase.instance
          .ref("All Ride Requests/$rideRequestId")
          .get();

      if (!rideSnapshot.exists) return;

      // Optionally set driver offline
      await Provider.of<DriverStatusProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).forceOfflineForTrip(driverId);

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(driverId)
          .update({'newRideStatus': 'accepted'});

      // 🚀 SINGLE SOURCE OF NAVIGATION
      Navigator.of(navigatorKey.currentContext!).pushReplacement(
        MaterialPageRoute(
          builder: (_) => NewTripScreen(userRideRequestDetails: widget.ride),
        ),
      );
    } catch (e) {
      debugPrint("Accept error: $e");
    }
  }

  // void acceptRide() async {
  //   widget.onDialogClosed?.call();
  //   final driverId = Provider.of<ProfileProvider>(
  //     context,
  //     listen: false,
  //   ).profile!.id;

  //   final rideRequestId = widget.ride.rideRequestId;

  //   try {
  //     final rideSnapshot = await FirebaseDatabase.instance
  //         .ref("All Ride Requests/$rideRequestId")
  //         .get();

  //     if (!rideSnapshot.exists) {
  //       if (mounted) {
  //         Navigator.pop(context);
  //       } else if (navigatorKey.currentContext != null) {
  //         Navigator.pop(navigatorKey.currentContext!);
  //       }
  //       return;
  //     }

  //     final driverDoc = await FirebaseFirestore.instance
  //         .collection("profiles")
  //         .doc(driverId)
  //         .get();

  //     if (driverDoc.data()?['newRideStatus'] == 'idle') {
  //       await FirebaseFirestore.instance
  //           .collection('profiles')
  //           .doc(driverId)
  //           .update({'newRideStatus': 'accepted'});

  //       if (mounted) {
  //         Navigator.pop(context);
  //       } else if (navigatorKey.currentContext != null) {
  //         Navigator.pop(navigatorKey.currentContext!);
  //       }

  //       if (context.mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (c) =>
  //                 NewTripScreen(userRideRequestDetails: widget.ride),
  //           ),
  //         );
  //       }
  //     } else {
  //       if (mounted) {
  //         Navigator.pop(context);
  //       } else if (navigatorKey.currentContext != null) {
  //         Navigator.pop(navigatorKey.currentContext!);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Accept error: $e");
  //   }
  // }
}

// Future<void> showRideRequestBottomSheet({
//   required BuildContext context,
//   required UserRideRequestInformation ride,
//   required VoidCallback? onDialogClosed,
//   required GlobalKey<FormState> priceKey,
//   required TextEditingController priceController,
// }) async {
//   bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

//   await showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     isScrollControlled: true,
//     backgroundColor: isDark ? AppColors.darkLayer : AppColors.lightLayer,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//           left: 12,
//           right: 12,
//           top: 12,
//         ),
//         child: Form(
//           key: priceKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: _RideRequestSheetContent(
//             ride: ride,
//             priceKey: priceKey,
//             priceController: priceController,
//             onDialogClosed: onDialogClosed,
//           ),
//         ),
//       );
//     },
//   );
// }

Future<void> showRideRequestBottomSheet({
  required BuildContext context,
  required UserRideRequestInformation ride,
  required VoidCallback? onDialogClosed,
  required GlobalKey<FormState> priceKey,
  required TextEditingController priceController,
}) async {
  bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkLayer : AppColors.lightLayer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 12,
          right: 12,
          top: 12,
        ),
        child: Form(
          key: priceKey,
          child: _RideRequestSheetContent(
            ride: ride,
            priceKey: priceKey,
            priceController: priceController,
            onDialogClosed: onDialogClosed,
          ),
        ),
      );
    },
  ).whenComplete(() {
    onDialogClosed?.call();
  });
}
