import 'package:cloud_firestore/cloud_firestore.dart';

import 'shuttle_booking_location.dart';
import 'shuttle_booking_timeline_event.dart';

class ShuttleBookingTimelineItem {
  final ShuttleBookingTimelineEvent event;

  final DateTime timestamp;

  final String? performedBy;

  final String? note;

  final ShuttleBookingLocation? location;

  const ShuttleBookingTimelineItem({
    required this.event,
    required this.timestamp,
    this.performedBy,
    this.note,
    this.location,
  });

  factory ShuttleBookingTimelineItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingTimelineItem.empty();
    }

    return ShuttleBookingTimelineItem(
      event: ShuttleBookingTimelineEventExtension.fromString(map['event']),
      timestamp: _parseTimestamp(map['timestamp']) ?? DateTime.now(),
      performedBy: map['performedBy'],
      note: map['note'],
      location: map['location'] != null
          ? ShuttleBookingLocation.fromMap(map['location'])
          : null,
    );
  }

  factory ShuttleBookingTimelineItem.empty() {
    return ShuttleBookingTimelineItem(
      event: ShuttleBookingTimelineEvent.bookingCreated,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event': event.value,
      'timestamp': timestamp,
      'performedBy': performedBy,
      'note': note,
      'location': location?.toMap(),
    };
  }

  ShuttleBookingTimelineItem copyWith({
    ShuttleBookingTimelineEvent? event,
    DateTime? timestamp,
    String? performedBy,
    String? note,
    ShuttleBookingLocation? location,
  }) {
    return ShuttleBookingTimelineItem(
      event: event ?? this.event,
      timestamp: timestamp ?? this.timestamp,
      performedBy: performedBy ?? this.performedBy,
      note: note ?? this.note,
      location: location ?? this.location,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
