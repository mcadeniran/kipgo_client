import 'package:flutter/material.dart';

enum ShuttleBookingStatus {
  pending,
  awaitingPayment,
  paymentSubmitted,
  reserved,
  approved,
  confirmed,
  driverAssigned,
  driverArriving,
  inProgress,
  completed,
  cancelled,
  rejected,
  expired;

  String get value => name;

  static ShuttleBookingStatus fromString(String? value) {
    return ShuttleBookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ShuttleBookingStatus.pending,
    );
  }
}

extension ShuttleBookingStatusExtension on ShuttleBookingStatus {
  String get label {
    switch (this) {
      case ShuttleBookingStatus.pending:
        return "Pending";

      case ShuttleBookingStatus.awaitingPayment:
        return "Awaiting Payment";

      case ShuttleBookingStatus.paymentSubmitted:
        return "Payment Submitted";

      case ShuttleBookingStatus.approved:
        return "Approved";

      case ShuttleBookingStatus.reserved:
        return "Reserved";

      case ShuttleBookingStatus.confirmed:
        return "Confirmed";

      case ShuttleBookingStatus.driverAssigned:
        return "Driver Assigned";

      case ShuttleBookingStatus.driverArriving:
        return "Driver Arriving";

      case ShuttleBookingStatus.inProgress:
        return "In Progress";

      case ShuttleBookingStatus.completed:
        return "Completed";

      case ShuttleBookingStatus.cancelled:
        return "Cancelled";

      case ShuttleBookingStatus.rejected:
        return "Rejected";

      case ShuttleBookingStatus.expired:
        return "Expired";
    }
  }

  Color get color {
    switch (this) {
      case ShuttleBookingStatus.pending:
        return Colors.grey;

      case ShuttleBookingStatus.awaitingPayment:
        return Colors.orange;

      case ShuttleBookingStatus.paymentSubmitted:
        return Colors.deepOrange;

      case ShuttleBookingStatus.reserved:
        return Colors.indigo;

      case ShuttleBookingStatus.confirmed:
        return Colors.blue;

      case ShuttleBookingStatus.approved:
        return Colors.blue;

      case ShuttleBookingStatus.driverAssigned:
        return Colors.teal;

      case ShuttleBookingStatus.driverArriving:
        return Colors.cyan;

      case ShuttleBookingStatus.inProgress:
        return Colors.green;

      case ShuttleBookingStatus.completed:
        return Colors.green;

      case ShuttleBookingStatus.cancelled:
        return Colors.red;

      case ShuttleBookingStatus.rejected:
        return Colors.red.shade700;

      case ShuttleBookingStatus.expired:
        return Colors.brown;
    }
  }

  IconData get icon {
    switch (this) {
      case ShuttleBookingStatus.pending:
        return Icons.hourglass_empty;

      case ShuttleBookingStatus.awaitingPayment:
        return Icons.account_balance_wallet_outlined;

      case ShuttleBookingStatus.paymentSubmitted:
        return Icons.upload_file;

      case ShuttleBookingStatus.reserved:
        return Icons.event_available;

      case ShuttleBookingStatus.approved:
        return Icons.event_available;

      case ShuttleBookingStatus.confirmed:
        return Icons.verified;

      case ShuttleBookingStatus.driverAssigned:
        return Icons.person_pin_circle;

      case ShuttleBookingStatus.driverArriving:
        return Icons.directions_car;

      case ShuttleBookingStatus.inProgress:
        return Icons.route;

      case ShuttleBookingStatus.completed:
        return Icons.check_circle;

      case ShuttleBookingStatus.cancelled:
        return Icons.cancel;

      case ShuttleBookingStatus.rejected:
        return Icons.block;

      case ShuttleBookingStatus.expired:
        return Icons.timer_off;
    }
  }
}
