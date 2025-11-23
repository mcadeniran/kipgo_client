import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kipgo/models/ride_history.dart';

class DriverRideProvider with ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  StreamSubscription<DatabaseEvent>? _driverAssignmentSub;
  StreamSubscription<DatabaseEvent>? _driveStatusSub;

  bool _hasActiveDrive = false;
  bool get hasActiveDrive => _hasActiveDrive;

  RideHistory? _driveData;
  RideHistory? get driveData => _driveData;

  String? _activeDriveId;
  String? get activeDriveId => _activeDriveId;

  /// Listen for any assigned ride to this driver
  Future<void> listenForActiveRide(String driverId) async {
    await detachListener(); // cancel existing listeners first

    // 1️⃣ Listen to "drivers/{driverId}/newRide"
    _driverAssignmentSub = _db
        .child("drivers/$driverId/newRide")
        .onValue
        .listen((event) {
          final rideId = event.snapshot.value?.toString();

          if (rideId == null || rideId == "waiting" || rideId.isEmpty) {
            _clearRide();
            notifyListeners();
            return;
          }

          // 2️⃣ Found a ride ID → start listening to it
          _listenToRideNode(rideId);
        });
  }

  void _listenToRideNode(String rideId) {
    _driveStatusSub?.cancel(); // cancel previous listener if any
    _activeDriveId = rideId;

    _driveStatusSub = _db.child("All Ride Requests/$rideId").onValue.listen((
      DatabaseEvent event,
    ) {
      if (event.snapshot.value == null) {
        _clearRide();
        notifyListeners();
        return;
      }

      final ride = Map<String, dynamic>.from(event.snapshot.value as Map);
      final status = ride["status"]?.toString().toLowerCase() ?? "ended";

      if (["pending", "accepted", "arrived", "ontrip"].contains(status)) {
        _hasActiveDrive = true;
        _driveData = RideHistory.fromRealtime(ride, event.snapshot.key!);
        notifyListeners();
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          _clearRide();
          notifyListeners();
        });
        // _clearRide();
      }
    });
  }

  void _clearRide() {
    _hasActiveDrive = false;
    _driveData = null;
    _activeDriveId = null;
  }

  Future<void> detachListener() async {
    await _driverAssignmentSub?.cancel();
    await _driveStatusSub?.cancel();
    _driverAssignmentSub = null;
    _driveStatusSub = null;
  }

  @override
  void dispose() {
    detachListener();
    super.dispose();
  }
}
