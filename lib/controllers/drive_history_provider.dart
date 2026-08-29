import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ride_history.dart';

class DriveHistoryProvider with ChangeNotifier {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref(
    'All Ride Requests',
  );

  List<RideHistory> _driverRides = [];

  List<RideHistory> get driverRides => _driverRides;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<DatabaseEvent>? _ridesSubscription;

  Future<void> fetchDriverRides(String driverId) async {
    // Cancel any previous listener.
    await _ridesSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    final query = _ridesRef.orderByChild('driverId').equalTo(driverId);

    _ridesSubscription = query.onValue.listen(
      (event) {
        try {
          final value = event.snapshot.value;

          // debugPrint('========================================');
          // debugPrint('DRIVER RIDE HISTORY');
          // debugPrint('Driver ID: $driverId');
          // debugPrint('Snapshot exists: ${event.snapshot.exists}');
          // debugPrint('Snapshot value type: ${value.runtimeType}');
          // debugPrint('Snapshot value: $value');
          // debugPrint('========================================');

          if (value == null) {
            _driverRides = [];
          } else if (value is Map) {
            final rides = <RideHistory>[];

            value.forEach((key, rawRide) {
              if (rawRide is! Map) {
                debugPrint(
                  'Skipping ride $key because value is '
                  '${rawRide.runtimeType}, not a Map.',
                );
                return;
              }

              try {
                final rideData = Map<String, dynamic>.from(rawRide);

                // debugPrint(
                //   'Matched ride: $key | '
                //   'driverId=${rideData['driverId']} | '
                //   'status=${rideData['status']} | '
                //   'proposedFare=${rideData['proposedFare']}',
                // );

                rides.add(RideHistory.fromRealtime(rideData, key.toString()));
              } catch (e, stackTrace) {
                debugPrint('Failed to parse ride $key: $e');
                debugPrintStack(stackTrace: stackTrace);
              }
            });

            rides.sort((a, b) => b.time.compareTo(a.time));

            _driverRides = rides;
          } else {
            debugPrint(
              'Unexpected Realtime Database structure: '
              '${value.runtimeType}',
            );

            _driverRides = [];
          }

          _isLoading = false;
          notifyListeners();
        } catch (e, stackTrace) {
          debugPrint('Error processing driver rides: $e');
          debugPrintStack(stackTrace: stackTrace);

          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Realtime Database listener error: $error');
        debugPrintStack(stackTrace: stackTrace);

        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _ridesSubscription?.cancel();
    super.dispose();
  }
}

// class DriveHistoryProvider with ChangeNotifier {
//   final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref(
//     "All Ride Requests",
//   );

//   List<RideHistory> _driverRides = [];
//   List<RideHistory> get driverRides => _driverRides;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   /// Fetch rides for a specific driverId
//   Future<void> fetchDriverRides(String driverId) async {
//     _isLoading = true;
//     notifyListeners();

//     _ridesRef.orderByChild("driverId").equalTo(driverId).onValue.listen((
//       event,
//     ) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;

//       if (data != null) {
//         _driverRides = data.entries.map((entry) {
//           final rideData = Map<String, dynamic>.from(entry.value);
//           return RideHistory.fromRealtime(rideData, entry.key);
//         }).toList();
//         _driverRides.sort((a, b) => b.time.compareTo(a.time));
//       } else {
//         _driverRides = [];
//       }

//       _isLoading = false;
//       notifyListeners();
//     });
//   }
// }
