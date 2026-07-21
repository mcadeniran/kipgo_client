import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'shuttle_booking.dart';

@immutable
class ShuttleBookingsPage {
  /// Bookings returned from Firestore
  final List<ShuttleBooking> bookings;

  /// Last fetched document.
  /// Used for pagination.
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  /// Whether there are more bookings to fetch.
  final bool hasMore;

  const ShuttleBookingsPage({
    required this.bookings,
    required this.lastDocument,
    required this.hasMore,
  });

  factory ShuttleBookingsPage.empty() {
    return const ShuttleBookingsPage(
      bookings: [],
      lastDocument: null,
      hasMore: false,
    );
  }

  ShuttleBookingsPage copyWith({
    List<ShuttleBooking>? bookings,
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument,
    bool? hasMore,
  }) {
    return ShuttleBookingsPage(
      bookings: bookings ?? this.bookings,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  bool get isEmpty => bookings.isEmpty;

  bool get isNotEmpty => bookings.isNotEmpty;

  int get length => bookings.length;

  ShuttleBooking operator [](int index) => bookings[index];
}
