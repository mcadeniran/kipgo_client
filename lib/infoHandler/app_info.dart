import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rides/riders/rating_dialog.dart';
import 'package:provider/provider.dart';

class AppInfo extends ChangeNotifier {
  Direction? userPickUpLocation;
  Direction? userDropOffLocation;
  int countTotalTrips = 0;

  bool _hasActiveRide = false;
  bool get hasActiveRide => _hasActiveRide;

  String? _rideId;
  String? get rideId => _rideId;

  Map<String, dynamic>? _activeRideData;
  Map<String, dynamic>? get activeRideData => _activeRideData;

  StreamSubscription<DatabaseEvent>? _rideSubscription;

  final Set<String> _shownEndDialogs = {};
  bool _hasShownDialogFor(String rideId) => _shownEndDialogs.contains(rideId);
  void _markDialogShown(String rideId) => _shownEndDialogs.add(rideId);

  /// Set the rideId (called when creating a ride)
  Future<void> setActiveRideId(
    String rideId, {
    bool startListening = true,
  }) async {
    _rideId = rideId;
    notifyListeners();

    if (startListening) {
      await startRideListener(rideId);
    }
  }

  /// If we already know rideId, listen specifically to that node.
  Future<void> startRideListener(String rideId) async {
    // cancel previous subscription (if exists)
    await _rideSubscription?.cancel();
    _rideSubscription = null;

    final rideRef = FirebaseDatabase.instance
        .ref('All Ride Requests')
        .child(rideId);

    _rideSubscription = rideRef.onValue.listen((DatabaseEvent event) {
      if (!event.snapshot.exists) {
        // ride removed or not found
        _activeRideData = null;
        _hasActiveRide = false;
        notifyListeners();
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _activeRideData = data;
      _hasActiveRide = true;
      _rideId = rideId;

      // If ride status ended/cancelled, cleanup automatically
      final status = (data['status'] ?? '').toString().toLowerCase();
      final isRated = (data['isRated'] ?? false) == true;
      if (status == 'cancelled') {
        // small delay to allow UI to react if needed
        // Note: you might want to keep the final state for a short time
        stopActiveRideListener();
      }

      if (status == 'ended' && !isRated) {
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx != null && !_hasShownDialogFor(rideId)) {
          _markDialogShown(rideId);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (_) => RatingDialog(
                onSubmit: (rating, reviews) async {
                  final userP = Provider.of<ProfileProvider>(
                    ctx,
                    listen: false,
                  ).profile;

                  final review = Review(
                    rating: rating,
                    details: reviews,
                    rideId: rideId,
                    reviewerId: userP!.id,
                    reviewerName: userP.username,
                    reviewerPhotoUrl: userP.personal.photoUrl,
                    createdAt: DateTime.now(),
                  );

                  // Save review to driver profile
                  final driverId = data['driverId'];
                  final docRef = FirebaseFirestore.instance
                      .collection("profiles")
                      .doc(driverId);

                  await docRef.update({
                    "personal.reviews": FieldValue.arrayUnion([review.toMap()]),
                  });

                  // Mark as rated
                  final rideRef = FirebaseDatabase.instance
                      .ref()
                      .child("All Ride Requests")
                      .child(rideId);

                  await rideRef.update({"isRated": true});

                  // ✅ Stop listener & clear active ride
                  stopActiveRideListener();
                },
                onCancel: () {
                  // 👈 Handle cancellation
                  stopActiveRideListener(); // ✅ Stop listening!
                },
              ),
            );
          });
        }
      }

      notifyListeners();
    });
  }

  /// If rideId isn't known (app restarted), find any active ride for this user
  Future<void> recoverActiveRide(String userId) async {
    final ridesRef = FirebaseDatabase.instance.ref('All Ride Requests');
    // One-time read to find an active ride
    final snapshot = await ridesRef
        .orderByChild('userId')
        .equalTo(userId)
        .get();

    if (!snapshot.exists) {
      // nothing to recover
      return;
    }

    String? foundRideId;
    Map<String, dynamic>? foundData;

    for (final child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      final status = data['status']?.toString() ?? '';
      if (status == 'accepted' ||
          status == 'arrived' ||
          status == 'ontrip' ||
          status == 'pending') {
        debugPrint("ACTiVE RIDE STATUS: $status");
        debugPrint("ACTIVE RIDE ID: ${child.key}");
        foundRideId = child.key;
        foundData = data;
        break;
      }
    }

    if (foundRideId != null) {
      _rideId = foundRideId;
      _activeRideData = foundData;
      _hasActiveRide = true;
      notifyListeners();

      // start direct listener for future changes
      await startRideListener(foundRideId);
    }
  }

  /// Stop listener when user logs out or app closes
  Future<void> stopActiveRideListener() async {
    await _rideSubscription?.cancel();
    _rideSubscription = null;
    _activeRideData = null;
    _hasActiveRide = false;
    _rideId = null;
    notifyListeners();
  }

  void updateActiveRideStatus(bool status) {
    _hasActiveRide = status;
    notifyListeners();
  }

  void updatePickUpLocationAddress(Direction userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Direction userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  Future<void> cancelRide(BuildContext context) async {
    try {
      if (_rideId == null) return;

      await FirebaseDatabase.instance
          .ref("All Ride Requests/$_rideId/status")
          .set("cancelled");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.rideCancelledSuccessfully,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await stopActiveRideListener();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.failedToCancelRide} $e",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
