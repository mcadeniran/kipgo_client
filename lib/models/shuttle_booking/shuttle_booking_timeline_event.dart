import 'package:flutter/material.dart';

enum ShuttleBookingTimelineEvent {
  bookingCreated,

  paymentRequested,

  paymentSubmitted,

  paymentRejected,

  paymentVerified,

  bookingReserved,

  bookingConfirmed,

  driverAssigned,

  driverArriving,

  passengerPickedUp,

  tripStarted,

  tripCompleted,

  bookingCancelled,

  bookingExpired,
}

extension ShuttleBookingTimelineEventExtension on ShuttleBookingTimelineEvent {
  String get value => name;

  static ShuttleBookingTimelineEvent fromString(String? value) {
    return ShuttleBookingTimelineEvent.values.firstWhere(
      (event) => event.name == value,
      orElse: () => ShuttleBookingTimelineEvent.bookingCreated,
    );
  }

  String get title {
    switch (this) {
      case ShuttleBookingTimelineEvent.bookingCreated:
        return "Booking Created";

      case ShuttleBookingTimelineEvent.paymentRequested:
        return "Payment Requested";

      case ShuttleBookingTimelineEvent.paymentSubmitted:
        return "Payment Submitted";

      case ShuttleBookingTimelineEvent.paymentRejected:
        return "Payment Rejected";

      case ShuttleBookingTimelineEvent.paymentVerified:
        return "Payment Verified";

      case ShuttleBookingTimelineEvent.bookingReserved:
        return "Booking Reserved";

      case ShuttleBookingTimelineEvent.bookingConfirmed:
        return "Booking Confirmed";

      case ShuttleBookingTimelineEvent.driverAssigned:
        return "Driver Assigned";

      case ShuttleBookingTimelineEvent.driverArriving:
        return "Driver Arriving";

      case ShuttleBookingTimelineEvent.passengerPickedUp:
        return "Passenger Picked Up";

      case ShuttleBookingTimelineEvent.tripStarted:
        return "Trip Started";

      case ShuttleBookingTimelineEvent.tripCompleted:
        return "Trip Completed";

      case ShuttleBookingTimelineEvent.bookingCancelled:
        return "Booking Cancelled";

      case ShuttleBookingTimelineEvent.bookingExpired:
        return "Booking Expired";
    }
  }
}

extension ShuttleBookingTimelineEventUI on ShuttleBookingTimelineEvent {
  IconData get icon {
    switch (this) {
      case ShuttleBookingTimelineEvent.bookingCreated:
        return Icons.receipt_long;

      case ShuttleBookingTimelineEvent.paymentRequested:
        return Icons.payments_outlined;

      case ShuttleBookingTimelineEvent.paymentSubmitted:
        return Icons.upload;

      case ShuttleBookingTimelineEvent.paymentRejected:
        return Icons.cancel;

      case ShuttleBookingTimelineEvent.paymentVerified:
        return Icons.verified;

      case ShuttleBookingTimelineEvent.bookingReserved:
        return Icons.event_available;

      case ShuttleBookingTimelineEvent.bookingConfirmed:
        return Icons.check_circle;

      case ShuttleBookingTimelineEvent.driverAssigned:
        return Icons.badge;

      case ShuttleBookingTimelineEvent.driverArriving:
        return Icons.directions_car;

      case ShuttleBookingTimelineEvent.passengerPickedUp:
        return Icons.person_pin_circle;

      case ShuttleBookingTimelineEvent.tripStarted:
        return Icons.play_circle_fill;

      case ShuttleBookingTimelineEvent.tripCompleted:
        return Icons.flag;

      case ShuttleBookingTimelineEvent.bookingCancelled:
        return Icons.block;

      case ShuttleBookingTimelineEvent.bookingExpired:
        return Icons.timer_off;
    }
  }

  Color get color {
    switch (this) {
      case ShuttleBookingTimelineEvent.bookingCreated:
        return Colors.grey;

      case ShuttleBookingTimelineEvent.paymentRequested:
        return Colors.orange;

      case ShuttleBookingTimelineEvent.paymentSubmitted:
        return Colors.deepOrange;

      case ShuttleBookingTimelineEvent.paymentRejected:
        return Colors.red;

      case ShuttleBookingTimelineEvent.paymentVerified:
        return Colors.green;

      case ShuttleBookingTimelineEvent.bookingReserved:
        return Colors.indigo;

      case ShuttleBookingTimelineEvent.bookingConfirmed:
        return Colors.blue;

      case ShuttleBookingTimelineEvent.driverAssigned:
        return Colors.teal;

      case ShuttleBookingTimelineEvent.driverArriving:
        return Colors.cyan;

      case ShuttleBookingTimelineEvent.passengerPickedUp:
        return Colors.purple;

      case ShuttleBookingTimelineEvent.tripStarted:
        return Colors.green;

      case ShuttleBookingTimelineEvent.tripCompleted:
        return Colors.green.shade700;

      case ShuttleBookingTimelineEvent.bookingCancelled:
        return Colors.red;

      case ShuttleBookingTimelineEvent.bookingExpired:
        return Colors.brown;
    }
  }
}
