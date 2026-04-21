import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<BookingModel> bookings = [];

  bool isLoading = false;

  StreamSubscription? _bookingSubscription;

  void listenToUserBookings(String userId) {
    _bookingSubscription?.cancel();

    _bookingSubscription = _repository.streamUserBookings(userId).listen((
      bookingList,
    ) {
      bookings = bookingList;
      notifyListeners();
    });
  }

  List<BookingModel> getRatedBookingsByCar(String carId) {
    return bookings
        .where((b) => b.carId == carId && b.isRated == true)
        .toList();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}
