import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ride_history.dart';

class RideHistoryProvider with ChangeNotifier {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref(
    "All Ride Requests",
  );

  List<RideHistory> _userRides = [];
  List<RideHistory> get userRides => _userRides;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch rides for a specific userId
  Future<void> fetchUserRides(String userId) async {
    _isLoading = true;
    notifyListeners();

    _ridesRef.orderByChild("userId").equalTo(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _userRides = data.entries.map((entry) {
          final rideData = Map<String, dynamic>.from(entry.value);
          return RideHistory.fromRealtime(rideData, entry.key);
        }).toList();

        _userRides.sort((a, b) => b.time.compareTo(a.time));
      } else {
        _userRides = [];
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> deleteRide(String rideId) async {
    // Find the ride before removal (so we can rollback if needed)
    final rideToDelete = _userRides.firstWhere(
      (ride) => ride.id == rideId,
      orElse: () => throw Exception("Ride not found"),
    );

    // Optimistically remove from local list
    _userRides.removeWhere((ride) => ride.id == rideId);
    notifyListeners();

    try {
      // Try deleting from Firebase
      await _ridesRef.child(rideId).remove();
    } catch (e) {
      // Rollback (put the ride back if deletion fails)
      _userRides.add(rideToDelete);

      // Re-sort to maintain order
      _userRides.sort((a, b) => b.time.compareTo(a.time));
      notifyListeners();

      throw Exception("Error deleting ride: $e");
    }
  }

  void restoreRide(RideHistory ride, int index) {
    _userRides.insert(index, ride);
    notifyListeners();
  }
}
