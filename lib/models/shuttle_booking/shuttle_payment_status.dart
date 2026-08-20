import 'package:flutter/material.dart';

enum ShuttlePaymentStatus {
  unpaid,
  pending,
  awaitingPayment,
  awaitingVerification,
  paid,
  failed,
  expired;

  String get value => name;

  static ShuttlePaymentStatus fromString(String? value) {
    return ShuttlePaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ShuttlePaymentStatus.unpaid,
    );
  }
}

extension ShuttlePaymentStatusExtension on ShuttlePaymentStatus {
  String get label {
    switch (this) {
      case ShuttlePaymentStatus.unpaid:
        return "Unpaid";

      case ShuttlePaymentStatus.awaitingPayment:
        return "Awaiting Payment";

      case ShuttlePaymentStatus.pending:
        return "Pending";

      case ShuttlePaymentStatus.awaitingVerification:
        return "Awaiting Verification";

      case ShuttlePaymentStatus.paid:
        return "Paid";

      case ShuttlePaymentStatus.failed:
        return "Failed";

      case ShuttlePaymentStatus.expired:
        return "Expired";
    }
  }

  Color get color {
    switch (this) {
      case ShuttlePaymentStatus.unpaid:
        return Colors.red;

      case ShuttlePaymentStatus.awaitingPayment:
        return Colors.red;

      case ShuttlePaymentStatus.pending:
        return Colors.orange;

      case ShuttlePaymentStatus.awaitingVerification:
        return Colors.blue;

      case ShuttlePaymentStatus.paid:
        return Colors.green;

      case ShuttlePaymentStatus.failed:
        return Colors.red.shade700;

      case ShuttlePaymentStatus.expired:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case ShuttlePaymentStatus.unpaid:
        return Icons.payment;

      case ShuttlePaymentStatus.awaitingPayment:
        return Icons.schedule;

      case ShuttlePaymentStatus.pending:
        return Icons.schedule;

      case ShuttlePaymentStatus.awaitingVerification:
        return Icons.hourglass_top;

      case ShuttlePaymentStatus.paid:
        return Icons.verified;

      case ShuttlePaymentStatus.failed:
        return Icons.error;

      case ShuttlePaymentStatus.expired:
        return Icons.timer_off;
    }
  }
}
