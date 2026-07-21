import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'shuttle_booking.dart';

@immutable
class ShuttleBookingsState {
  /// Whether the first page is currently loading.
  final bool loading;

  /// Whether another page is currently being fetched.
  final bool loadingMore;

  /// Whether more bookings are available.
  final bool hasMore;

  /// Error message returned while loading bookings.
  final String? error;

  /// Current bookings loaded for this group.
  final List<ShuttleBooking> bookings;

  /// Last Firestore document used for pagination.
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  const ShuttleBookingsState({
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
    this.bookings = const [],
    this.lastDocument,
  });

  factory ShuttleBookingsState.initial() {
    return const ShuttleBookingsState();
  }

  ShuttleBookingsState copyWith({
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
    List<ShuttleBooking>? bookings,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) {
    return ShuttleBookingsState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      bookings: bookings ?? this.bookings,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }

  /// Returns true when no bookings have been loaded.
  bool get isEmpty => bookings.isEmpty;

  /// Returns true when at least one booking exists.
  bool get isNotEmpty => bookings.isNotEmpty;

  /// Number of loaded bookings.
  int get length => bookings.length;

  /// Returns true when the initial page is loading.
  bool get isLoading => loading;

  /// Returns true when another page is being fetched.
  bool get isLoadingMore => loadingMore;

  /// Returns true when there is an error.
  bool get hasError => error != null;

  /// Returns true when additional pages can be loaded.
  bool get canLoadMore => hasMore && !loading && !loadingMore;

  ShuttleBooking operator [](int index) => bookings[index];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShuttleBookingsState &&
        other.loading == loading &&
        other.loadingMore == loadingMore &&
        other.hasMore == hasMore &&
        other.error == error &&
        listEquals(other.bookings, bookings) &&
        other.lastDocument?.id == lastDocument?.id;
  }

  @override
  int get hashCode {
    return Object.hash(
      loading,
      loadingMore,
      hasMore,
      error,
      Object.hashAll(bookings),
      lastDocument?.id,
    );
  }

  @override
  String toString() {
    return '''
ShuttleBookingsState(
  loading: $loading,
  loadingMore: $loadingMore,
  hasMore: $hasMore,
  bookings: ${bookings.length},
  error: $error,
  lastDocument: ${lastDocument?.id},
)
''';
  }
}
