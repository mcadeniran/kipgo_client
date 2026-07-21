import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';

import '../models/shuttle_booking/shuttle_booking.dart';
import '../models/shuttle_booking/shuttle_booking_group.dart';
import '../models/shuttle_booking/shuttle_bookings_state.dart';
import '../repositories/shuttle_booking_repository.dart';

class ShuttleBookingsProvider extends ChangeNotifier {
  ShuttleBookingsProvider({ShuttleBookingRepository? repository})
    : _repository = repository ?? ShuttleBookingRepository();

  final ShuttleBookingRepository _repository;

  final Map<ShuttleBookingGroup, StreamSubscription<List<ShuttleBooking>>?>
  _subscriptions = {};

  final Map<ShuttleBookingGroup, ShuttleBookingsState> _states = {
    for (final group in ShuttleBookingGroup.values)
      group: ShuttleBookingsState.initial(),
  };

  ShuttleBookingsState state(ShuttleBookingGroup group) {
    return _states[group]!;
  }

  List<ShuttleBooking> bookings(ShuttleBookingGroup group) {
    return state(group).bookings;
  }

  int count(ShuttleBookingGroup group) {
    return state(group).bookings.length;
  }

  bool get hasAnyBookings {
    return _states.values.any((state) => state.bookings.isNotEmpty);
  }

  void _setState(ShuttleBookingGroup group, ShuttleBookingsState value) {
    _states[group] = value;
    notifyListeners();
  }

  Future<void> initialize(String userId) async {
    watchBookings(userId: userId, group: ShuttleBookingGroup.upcoming);

    watchBookings(userId: userId, group: ShuttleBookingGroup.attention);

    watchBookings(userId: userId, group: ShuttleBookingGroup.ongoing);

    await loadBookings(userId: userId, group: ShuttleBookingGroup.completed);

    await loadBookings(userId: userId, group: ShuttleBookingGroup.closed);
  }

  ShuttleBooking? get upcomingBooking {
    final bookings = [
      ...state(ShuttleBookingGroup.ongoing).bookings,
      ...state(ShuttleBookingGroup.upcoming).bookings,
      ...state(ShuttleBookingGroup.attention).bookings,
    ];

    if (bookings.isEmpty) return null;

    bookings.sort((a, b) {
      final priorityA = _statusPriority(a.status);
      final priorityB = _statusPriority(b.status);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      return a.departureDate.compareTo(b.departureDate);
    });

    return bookings.first;
  }

  int _statusPriority(ShuttleBookingStatus status) {
    switch (status) {
      case ShuttleBookingStatus.driverArriving:
        return 0;

      case ShuttleBookingStatus.driverAssigned:
        return 1;

      case ShuttleBookingStatus.confirmed:
        return 2;

      case ShuttleBookingStatus.approved:
        return 3;

      case ShuttleBookingStatus.reserved:
        return 4;

      case ShuttleBookingStatus.awaitingPayment:
        return 5;

      case ShuttleBookingStatus.paymentSubmitted:
        return 6;

      case ShuttleBookingStatus.pending:
        return 7;

      default:
        return 100;
    }
  }

  void watchBookings({
    required String userId,
    required ShuttleBookingGroup group,
  }) {
    if (_subscriptions[group] != null) {
      return;
    }

    _subscriptions[group]?.cancel();

    _setState(group, state(group).copyWith(loading: true, clearError: true));

    _subscriptions[group] = _repository
        .watchShuttleBookings(userId: userId, group: group)
        .listen(
          (bookings) {
            _setState(
              group,
              state(group).copyWith(
                loading: false,
                bookings: bookings,
                hasMore: false,
                clearError: true,
              ),
            );
          },
          onError: (e) {
            _setState(
              group,
              state(group).copyWith(loading: false, error: e.toString()),
            );
          },
        );
  }

  void stopWatching() {
    for (final subscription in _subscriptions.values) {
      subscription?.cancel();
    }

    _subscriptions.clear();
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }

  Future<void> loadBookings({
    required String userId,
    required ShuttleBookingGroup group,
    bool forceRefresh = false,
  }) async {
    final current = state(group);

    if (current.loading) {
      return;
    }

    if (!forceRefresh && current.bookings.isNotEmpty) {
      return;
    }

    _setState(group, current.copyWith(loading: true, clearError: true));

    try {
      final page = await _repository.getShuttleBookings(
        userId: userId,
        group: group,
      );

      _setState(
        group,
        current.copyWith(
          loading: false,
          bookings: page.bookings,
          lastDocument: page.lastDocument,
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
    } catch (e) {
      _setState(group, current.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh({
    required String userId,
    required ShuttleBookingGroup group,
  }) async {
    _setState(group, ShuttleBookingsState.initial());

    await loadBookings(userId: userId, group: group, forceRefresh: true);
  }

  Future<void> loadMore({
    required String userId,
    required ShuttleBookingGroup group,
  }) async {
    final current = state(group);

    if (!current.canLoadMore) {
      return;
    }

    _setState(group, current.copyWith(loadingMore: true));

    try {
      final page = await _repository.getShuttleBookings(
        userId: userId,
        group: group,
        lastDocument: current.lastDocument,
      );

      _setState(
        group,
        current.copyWith(
          loadingMore: false,
          bookings: [...current.bookings, ...page.bookings],
          lastDocument: page.lastDocument,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      _setState(
        group,
        current.copyWith(loadingMore: false, error: e.toString()),
      );
    }
  }

  ShuttleBooking? bookingById(String bookingId) {
    for (final state in _states.values) {
      for (final booking in state.bookings) {
        if (booking.id == bookingId) {
          return booking;
        }
      }
    }

    return null;
  }

  void updateBooking(ShuttleBooking booking) {
    for (final group in ShuttleBookingGroup.values) {
      final current = state(group);

      final index = current.bookings.indexWhere(
        (element) => element.id == booking.id,
      );

      if (index == -1) {
        continue;
      }

      final updatedBookings = List<ShuttleBooking>.from(current.bookings);

      updatedBookings[index] = booking;

      _setState(group, current.copyWith(bookings: updatedBookings));

      return;
    }
  }

  void removeBooking(String bookingId) {
    for (final group in ShuttleBookingGroup.values) {
      final current = state(group);

      final updatedBookings = current.bookings
          .where((booking) => booking.id != bookingId)
          .toList();

      if (updatedBookings.length == current.bookings.length) {
        continue;
      }

      _setState(group, current.copyWith(bookings: updatedBookings));

      return;
    }
  }

  void clear() {
    for (final group in ShuttleBookingGroup.values) {
      _states[group] = ShuttleBookingsState.initial();
    }

    notifyListeners();
  }
}
