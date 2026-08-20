import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

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

  bookingApproved,

  paymentLinkSent,
}

extension ShuttleBookingTimelineEventExtension on ShuttleBookingTimelineEvent {
  String get value => name;

  static ShuttleBookingTimelineEvent fromString(String? value) {
    return ShuttleBookingTimelineEvent.values.firstWhere(
      (event) => event.name == value,
      orElse: () => ShuttleBookingTimelineEvent.bookingCreated,
    );
  }

  String title(AppLocalizations loc) {
    switch (this) {
      case ShuttleBookingTimelineEvent.bookingCreated:
        return loc.bookingCreated;

      case ShuttleBookingTimelineEvent.paymentRequested:
        return loc.paymentRequested;

      case ShuttleBookingTimelineEvent.paymentSubmitted:
        return loc.paymentSubmitted;

      case ShuttleBookingTimelineEvent.paymentRejected:
        return loc.paymentRejected;

      case ShuttleBookingTimelineEvent.paymentVerified:
        return loc.paymentVerified;

      case ShuttleBookingTimelineEvent.bookingReserved:
        return loc.bookingReserved;

      case ShuttleBookingTimelineEvent.bookingConfirmed:
        return loc.bookingConfirmed;

      case ShuttleBookingTimelineEvent.driverAssigned:
        return loc.driverAssigned;

      case ShuttleBookingTimelineEvent.driverArriving:
        return loc.driverArriving;

      case ShuttleBookingTimelineEvent.passengerPickedUp:
        return loc.passengerPickedUp;

      case ShuttleBookingTimelineEvent.tripStarted:
        return loc.tripStarted;

      case ShuttleBookingTimelineEvent.tripCompleted:
        return loc.tripCompleted;

      case ShuttleBookingTimelineEvent.bookingCancelled:
        return loc.bookingCancelled;

      case ShuttleBookingTimelineEvent.bookingExpired:
        return loc.bookingExpired;

      case ShuttleBookingTimelineEvent.bookingApproved:
        return loc.bookingApproved;

      case ShuttleBookingTimelineEvent.paymentLinkSent:
        return loc.paymentLinkSent;
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

      case ShuttleBookingTimelineEvent.bookingApproved:
        return Icons.verified_outlined;

      case ShuttleBookingTimelineEvent.paymentLinkSent:
        return Icons.dataset_linked_outlined;
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

      case ShuttleBookingTimelineEvent.bookingApproved:
        return Colors.indigo;

      case ShuttleBookingTimelineEvent.paymentLinkSent:
        return Colors.deepOrange;
    }
  }
}
