import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/screens/rides/drivers/new_trip_screen.dart';
import 'package:kipgo/utils/colors.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformation userRideRequestDetails;
  final VoidCallback? onDialogClosed;

  const NotificationDialogBox({
    super.key,
    required this.userRideRequestDetails,
    this.onDialogClosed,
  });

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(2),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
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
                          widget.userRideRequestDetails.originAddress!,
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
                        color: isDark ? AppColors.tertiary : AppColors.tertiary,
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails.destinationAddress!,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 2, thickness: 2, color: AppColors.border),
            Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Stop audio
                      widget.onDialogClosed?.call();
                      rejectRideRequest(context);
                      // Navigator.pop(context);
                    },
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
                    onPressed: () {
                      // TODO:
                      // Stop audio
                      debugPrint('REQUEST ACCEPTED');
                      widget.onDialogClosed?.call();
                      acceptRideRequest(context);
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
        ),
      ),
    );
  }

  // void acceptRideRequest(BuildContext context) async {
  //   String driverId = Provider.of<ProfileProvider>(
  //     context,
  //     listen: false,
  //   ).profile!.id;

  //   await FirebaseFirestore.instance
  //       .collection("profiles")
  //       .doc(driverId)
  //       .get()
  //       .then((dataSnapshot) async {
  //         var driverKeyInfo = dataSnapshot.data();
  //         var driverStatus = driverKeyInfo!['newRideStatus'];

  //         if (driverStatus == null || driverStatus == 'idle') {
  //           await FirebaseFirestore.instance
  //               .collection('profiles')
  //               .doc(driverId)
  //               .update({'newRideStatus': 'accepted'});

  //           // AppMethods.pauseLiveLocationUpdates(userId: driverId);

  //           // streamSubscriptionPosition!.pause();
  //           // Provider.of<DriverStatusProvider>(
  //           //   context,
  //           //   listen: false,
  //           // ).setDriverOffline(driverId);

  //           Provider.of<DriverStatusProvider>(
  //             context,
  //             listen: false,
  //           ).toggleStatus(false, context);

  //           Navigator.pop(context);

  //           // Trip started now, send driver to new tripScreen
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (c) => NewTripScreen(
  //                 userRideRequestDetails: widget.userRideRequestDetails,
  //               ),
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 AppLocalizations.of(context)!.rideRequestIsNotAvailable,
  //               ),
  //             ),
  //           );
  //           Navigator.pop(context);
  //         }
  //       });
  // }

  void acceptRideRequest(BuildContext context) async {
    final driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;

    final rideRequestId = widget.userRideRequestDetails.rideRequestId;

    try {
      // 1️⃣ Check if the ride request still exists in Realtime DB
      final rideSnapshot = await FirebaseDatabase.instance
          .ref("All Ride Requests/$rideRequestId")
          .get();

      if (!rideSnapshot.exists) {
        // 🚫 Rider has probably cancelled — stop flow
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.rideRequestIsNotAvailable,
              ),
            ),
          );
          Navigator.pop(context); // close dialog
        }
        return;
      }

      // 2️⃣ Confirm driver is idle before accepting
      final driverDoc = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(driverId)
          .get();

      final driverStatus = driverDoc.data()?['newRideStatus'];

      if (driverStatus == null || driverStatus == 'idle') {
        // 3️⃣ Update driver status → accepted
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(driverId)
            .update({'newRideStatus': 'accepted'});

        // Optionally set driver offline
        Provider.of<DriverStatusProvider>(
          context,
          listen: false,
        ).toggleStatus(false, context);

        // 4️⃣ Close dialog before navigating
        if (context.mounted) Navigator.pop(context);

        // 5️⃣ Proceed to trip screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => NewTripScreen(
                userRideRequestDetails: widget.userRideRequestDetails,
              ),
            ),
          );
        }
      } else {
        // 6️⃣ Another ride already accepted or status mismatch
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.rideRequestIsNotAvailable,
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("❌ Error while accepting ride: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorProcessingRideRequest,
            ),
          ),
        );
      }
    }
  }

  void rejectRideRequest(BuildContext context) async {
    String driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;

    final rideRequestId = widget.userRideRequestDetails.rideRequestId;

    try {
      // 1️⃣ Check if the ride request still exists in Realtime DB
      final rideSnapshot = await FirebaseDatabase.instance
          .ref("All Ride Requests/$rideRequestId")
          .get();

      if (!rideSnapshot.exists) {
        // 🚫 Rider has probably cancelled — stop flow
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.rideRequestIsNotAvailable,
              ),
            ),
          );
          Navigator.pop(context); // close dialog
        }
        return;
      }

      // Update driver status back to idle (or rejected state)
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(driverId)
          .update({'newRideStatus': 'idle'});

      DatabaseReference databaseReference = FirebaseDatabase.instance
          .ref()
          .child('All Ride Requests')
          .child(widget.userRideRequestDetails.rideRequestId!);

      databaseReference.child('status').set('rejected');

      debugPrint("REJECTING RIDE...");

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.rideRequestRejected),
        ),
      );
    } catch (e) {
      debugPrint("Error rejecting ride: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to reject ride")));
    }
  }
}
