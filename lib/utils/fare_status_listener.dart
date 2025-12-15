import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FareStatusListener {
  static StreamSubscription? _sub;
  static bool _dialogShowing = false;

  static void start({
    required String rideRequestId,
    required VoidCallback onAccepted,
    required VoidCallback onRejected,
  }) {
    stop();

    final ref = FirebaseDatabase.instance.ref(
      "All Ride Requests/$rideRequestId",
    );

    _sub = ref.onValue.listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final status = data['fareStatus'];

      if (status == 'accepted' && !_dialogShowing) {
        _dialogShowing = true;
        onAccepted();
      }

      if (status == 'rejected' && !_dialogShowing) {
        _dialogShowing = true;
        onRejected();
      }
    });
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
    _dialogShowing = false;
  }
}
