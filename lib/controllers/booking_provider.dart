import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<BookingModel> bookings = [];
  List<BookingModel> adminBookings = [];

  List<BookingModel> get attention {
    final items = bookings.where((b) {
      return ['pending', 'payment_submitted'].contains(b.status);
    }).toList();

    items.sort((a, b) {
      if (a.status == 'payment_submitted' && b.status == 'pending') {
        return -1;
      }
      if (a.status == 'pending' && b.status == 'payment_submitted') {
        return 1;
      }
      return 0;
    });

    return items;
  }

  List<BookingModel> get upcoming => bookings.where((b) {
    return ['reserved', 'approved'].contains(b.status);
  }).toList();

  List<BookingModel> get ongoing =>
      bookings.where((b) => b.status == 'ongoing').toList();

  List<BookingModel> get completed =>
      bookings.where((b) => b.status == 'completed').toList();

  List<BookingModel> get closed => bookings.where((b) {
    return ['rejected', 'cancelled', 'expired'].contains(b.status);
  }).toList();

  List<BookingModel> get adminAttention {
    final items = adminBookings.where((b) {
      return ['pending', 'payment_submitted'].contains(b.status);
    }).toList();

    items.sort((a, b) {
      if (a.status == 'payment_submitted' && b.status == 'pending') {
        return -1;
      }
      if (a.status == 'pending' && b.status == 'payment_submitted') {
        return 1;
      }
      return 0;
    });

    return items;
  }

  List<BookingModel> get adminUpcoming => adminBookings.where((b) {
    return ['reserved', 'approved'].contains(b.status);
  }).toList();

  List<BookingModel> get adminOngoing =>
      adminBookings.where((b) => b.status == 'ongoing').toList();

  List<BookingModel> get adminCompleted =>
      adminBookings.where((b) => b.status == 'completed').toList();

  List<BookingModel> get adminClosed => adminBookings.where((b) {
    return ['rejected', 'cancelled', 'expired'].contains(b.status);
  }).toList();

  // List<BookingModel> get pending =>
  //     bookings.where((b) => b.status == 'pending').toList();

  // List<BookingModel> get paymentSubmitted =>
  //     bookings.where((b) => b.status == 'payment_submitted').toList();

  // List<BookingModel> get approved =>
  //     bookings.where((b) => b.status == 'approved').toList();

  // List<BookingModel> get rejected =>
  //     bookings.where((b) => b.status == 'rejected').toList();

  // List<BookingModel> get reserved =>
  //     bookings.where((b) => b.status == 'reserved').toList();

  // List<BookingModel> get expired =>
  //     bookings.where((b) => b.status == 'expired').toList();

  List<BookingModel> get cancelled =>
      bookings.where((b) => b.status == 'cancelled').toList();

  List<BookingModel> get adminCancelled =>
      adminBookings.where((b) => b.status == 'cancelled').toList();

  int get activeBookings => ongoing.length;

  bool isLoading = false;

  StreamSubscription? _bookingSubscription;
  StreamSubscription? _adminBookingSubscription;

  void listenToUserBookings(String userId) {
    _bookingSubscription?.cancel();

    _bookingSubscription = _repository.streamUserBookings(userId).listen((
      bookingList,
    ) {
      bookings = bookingList;
      notifyListeners();
    });
  }

  void listenToShopBookings(String shopId) {
    _bookingSubscription?.cancel();

    isLoading = true;
    notifyListeners();

    _bookingSubscription = _repository.streamShopBookings(shopId).listen((
      bookingList,
    ) {
      bookings = bookingList;
      isLoading = false;
      notifyListeners();
    });
  }

  void listenToAdminBookings() {
    _adminBookingSubscription?.cancel();

    isLoading = true;
    notifyListeners();

    _adminBookingSubscription = _repository.streamAdminBookings().listen((
      blists,
    ) {
      adminBookings = blists;
      isLoading = false;
      notifyListeners();
    });
  }

  double get monthlyRevenue {
    final now = DateTime.now();

    return bookings
        .where(
          (b) =>
              b.status == 'completed' &&
              b.completedAt != null &&
              b.completedAt!.month == now.month &&
              b.completedAt!.year == now.year,
        )
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get offlineRevenue {
    final now = DateTime.now();

    return bookings
        .where(
          (b) =>
              b.status == 'completed' &&
              b.source == 'manual' &&
              b.completedAt != null &&
              b.completedAt!.month == now.month &&
              b.completedAt!.year == now.year,
        )
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get onlineRevenue {
    final now = DateTime.now();

    return bookings
        .where(
          (b) =>
              b.status == 'completed' &&
              b.source == 'app' &&
              b.completedAt != null &&
              b.completedAt!.month == now.month &&
              b.completedAt!.year == now.year,
        )
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get allTimeRevenue {
    return bookings
        .where((b) => b.status == 'completed')
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  List<Map<String, dynamic>> getRevenueChart({int days = 7}) {
    final now = DateTime.now();

    // Generate last N days
    final List<DateTime> dateRange = List.generate(
      days,
      (index) => DateTime(now.year, now.month, now.day - (days - 1 - index)),
    );

    return dateRange.map((date) {
      final total = bookings
          .where(
            (b) =>
                b.status == 'completed' &&
                b.completedAt != null &&
                b.completedAt!.year == date.year &&
                b.completedAt!.month == date.month &&
                b.completedAt!.day == date.day,
          )
          .fold(0.0, (sum, b) => sum + b.totalPrice);

      return {"date": date, "value": total};
    }).toList();
  }

  List<BookingModel> getRatedBookingsByCar(String carId) {
    return bookings
        .where((b) => b.carId == carId && b.isRated == true)
        .toList();
  }

  Future<void> acceptBooking(String bookingId) async {
    await _repository.updateBookingStatus(
      bookingId: bookingId,
      status: 'accepted',
    );
  }

  Future<void> rejectBooking(String bookingId) async {
    await _repository.updateBookingStatus(
      bookingId: bookingId,
      status: 'rejected',
    );
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}
