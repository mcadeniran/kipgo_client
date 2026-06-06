import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/models/booking_model.dart';

class CryptoVerificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  StreamSubscription? _subscription;

  void listenForAwaitingPayments() {
    _subscription?.cancel();

    _subscription = _firestore
        .collection('bookings')
        .where('payment.method', isEqualTo: 'crypto')
        .where('payment.status', isEqualTo: 'awaiting_verification')
        .snapshots()
        .listen((snapshot) {
          _bookings = snapshot.docs
              .map((e) => BookingModel.fromFirestore(e))
              .toList();

          notifyListeners();
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
