import 'dart:async';

import 'package:flutter/material.dart';
import '../models/ride_history.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RideHistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RideHistory> _userRides = [];

  List<RideHistory> get userRides => _userRides;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _ridesStream;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void fetchUserRides(String userId) {
    // Cancel any previous listener.
    _subscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _ridesStream = _firestore
        .collection('taxiRideHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots();

    _subscription = _ridesStream!.listen(
      (snapshot) {
        _userRides = snapshot.docs.map((doc) {
          return RideHistory.fromFirestore(doc.data(), doc.id);
        }).toList();

        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error fetching taxi ride history: $error');

        _userRides = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Delete a ride from Firestore history.
  ///
  /// This does NOT touch the Realtime Database because completed
  /// rides are now permanently stored in Firestore.
  Future<void> deleteRide(String rideId) async {
    final rideIndex = _userRides.indexWhere((ride) => ride.id == rideId);

    if (rideIndex == -1) {
      throw Exception('Ride not found');
    }

    final rideToDelete = _userRides[rideIndex];

    // Optimistically remove from local list.
    _userRides.removeAt(rideIndex);
    notifyListeners();

    try {
      await _firestore.collection('taxiRideHistory').doc(rideId).delete();
    } catch (e) {
      // Rollback if Firestore deletion fails.
      _userRides.insert(rideIndex, rideToDelete);

      _userRides.sort((a, b) => b.time.compareTo(a.time));

      notifyListeners();

      debugPrint('❌ Error deleting taxi ride history: $e');

      throw Exception('Error deleting ride: $e');
    }
  }

  /// Restore a ride locally.
  ///
  /// Usually not needed when using Firestore snapshots because
  /// the listener will automatically update the list, but kept
  /// for compatibility with existing UI code.
  void restoreRide(RideHistory ride, int index) {
    if (index < 0 || index > _userRides.length) {
      _userRides.add(ride);
    } else {
      _userRides.insert(index, ride);
    }

    _userRides.sort((a, b) => b.time.compareTo(a.time));

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
