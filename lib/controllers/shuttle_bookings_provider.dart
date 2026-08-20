import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';

import '../models/shuttle_booking/shuttle_booking.dart';
import '../models/shuttle_booking/shuttle_booking_group.dart';
import '../models/shuttle_booking/shuttle_bookings_state.dart';
import '../repositories/shuttle_booking_repository.dart';

class ShuttleBookingsProvider extends ChangeNotifier {
  ShuttleBookingsProvider({ShuttleBookingRepository? repository})
    : _repository = repository ?? ShuttleBookingRepository();

  final ShuttleBookingRepository _repository;

  bool _submittingCardPayment = false;

  bool get submittingCardPayment => _submittingCardPayment;

  List<ShuttleBooking> _bookings = [];

  StreamSubscription<List<ShuttleBooking>>? _subscription;

  bool _loading = true;

  String? _error;

  List<ShuttleBooking> get allBookings => List.unmodifiable(_bookings);

  bool get loading => _loading;

  String? get error => _error;

  ShuttleBookingGroup bookingGroup(ShuttleBooking booking) {
    switch (booking.status) {
      case ShuttleBookingStatus.completed:
        return ShuttleBookingGroup.completed;

      case ShuttleBookingStatus.cancelled:
      case ShuttleBookingStatus.rejected:
      case ShuttleBookingStatus.expired:
        return ShuttleBookingGroup.closed;

      case ShuttleBookingStatus.inProgress:
        return ShuttleBookingGroup.ongoing;

      case ShuttleBookingStatus.driverAssigned:
      case ShuttleBookingStatus.driverArriving:
      case ShuttleBookingStatus.confirmed:
        return ShuttleBookingGroup.upcoming;

      case ShuttleBookingStatus.pending:
        return ShuttleBookingGroup.attention;

      case ShuttleBookingStatus.awaitingPayment:
        return ShuttleBookingGroup.attention;

      case ShuttleBookingStatus.paymentSubmitted:
        return ShuttleBookingGroup.attention;

      case ShuttleBookingStatus.reserved:
        if (booking.payment.status == ShuttlePaymentStatus.paid) {
          return ShuttleBookingGroup.upcoming;
        }

        return ShuttleBookingGroup.attention;

      case ShuttleBookingStatus.approved:
        if (booking.payment.status == ShuttlePaymentStatus.paid) {
          return ShuttleBookingGroup.upcoming;
        }

        return ShuttleBookingGroup.attention;
    }
  }

  Future<void> initialize(String userId) async {
    _subscription?.cancel();

    _loading = true;

    notifyListeners();

    _subscription = _repository
        .watchUserBookings(userId: userId)
        .listen(
          (bookings) {
            bookings.sort(_sortBookings);

            _bookings = bookings;

            _loading = false;

            _error = null;

            notifyListeners();
          },
          onError: (e) {
            _loading = false;

            _error = e.toString();

            notifyListeners();
          },
        );
  }

  int _sortBookings(ShuttleBooking a, ShuttleBooking b) {
    final priorityA = _priority(a);

    final priorityB = _priority(b);

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    return a.departureDate.compareTo(b.departureDate);
  }

  int _priority(ShuttleBooking booking) {
    switch (booking.status) {
      case ShuttleBookingStatus.driverArriving:
        return 0;

      case ShuttleBookingStatus.driverAssigned:
        return 1;

      case ShuttleBookingStatus.confirmed:
        return 2;

      case ShuttleBookingStatus.approved:
        return booking.payment.status == ShuttlePaymentStatus.paid ? 3 : 8;

      case ShuttleBookingStatus.reserved:
        return 4;

      case ShuttleBookingStatus.awaitingPayment:
        return 9;

      case ShuttleBookingStatus.paymentSubmitted:
        return 10;

      case ShuttleBookingStatus.pending:
        return 11;

      default:
        return 99;
    }
  }

  List<ShuttleBooking> bookings(ShuttleBookingGroup group) {
    return _bookings
        .where((booking) => bookingGroup(booking) == group)
        .toList();
  }

  int count(ShuttleBookingGroup group) {
    return bookings(group).length;
  }

  ShuttleBooking? bookingById(String id) {
    try {
      return _bookings.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Stream<ShuttleBooking> watchBooking(String bookingId) {
    return _repository.watchBooking(bookingId);
  }

  ShuttleBooking? get upcomingBooking {
    if (_bookings.isEmpty) {
      return null;
    }

    return _bookings.first;
  }

  void stopWatching() {
    _subscription?.cancel();

    _subscription = null;
  }

  @override
  void dispose() {
    stopWatching();

    super.dispose();
  }

  void clear() {
    _bookings = [];

    _loading = true;

    _error = null;

    notifyListeners();
  }

  Future<void> submitCardPayment(String bookingId) async {
    if (_submittingCardPayment) return;

    _submittingCardPayment = true;
    notifyListeners();

    try {
      await _repository.submitCardPayment(bookingId: bookingId);
    } finally {
      _submittingCardPayment = false;
      notifyListeners();
    }
  }
}
