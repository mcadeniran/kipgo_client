import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';

class ShuttleBookingStatusBadge extends StatelessWidget {
  final ShuttleBookingStatus status;

  const ShuttleBookingStatusBadge({super.key, required this.status});

  Color get backgroundColor {
    switch (status) {
      case ShuttleBookingStatus.pending:
      case ShuttleBookingStatus.awaitingPayment:
      case ShuttleBookingStatus.paymentSubmitted:
        return Colors.orange.shade100;

      case ShuttleBookingStatus.reserved:
      case ShuttleBookingStatus.confirmed:
      case ShuttleBookingStatus.approved:
        return Colors.green.shade100;

      case ShuttleBookingStatus.driverAssigned:
      case ShuttleBookingStatus.driverArriving:
      case ShuttleBookingStatus.inProgress:
        return Colors.blue.shade100;

      case ShuttleBookingStatus.completed:
        return Colors.grey.shade300;

      case ShuttleBookingStatus.cancelled:
      case ShuttleBookingStatus.rejected:
      case ShuttleBookingStatus.expired:
        return Colors.red.shade100;
    }
  }

  Color get textColor {
    switch (status) {
      case ShuttleBookingStatus.pending:
      case ShuttleBookingStatus.awaitingPayment:
      case ShuttleBookingStatus.paymentSubmitted:
        return Colors.orange.shade900;

      case ShuttleBookingStatus.reserved:
      case ShuttleBookingStatus.confirmed:
      case ShuttleBookingStatus.approved:
        return Colors.green.shade900;

      case ShuttleBookingStatus.driverAssigned:
      case ShuttleBookingStatus.driverArriving:
      case ShuttleBookingStatus.inProgress:
        return Colors.blue.shade900;

      case ShuttleBookingStatus.completed:
        return Colors.grey.shade800;

      case ShuttleBookingStatus.cancelled:
      case ShuttleBookingStatus.rejected:
      case ShuttleBookingStatus.expired:
        return Colors.red.shade900;
    }
  }

  String get title {
    switch (status) {
      case ShuttleBookingStatus.pending:
        return "Pending";

      case ShuttleBookingStatus.awaitingPayment:
        return "Awaiting Payment";

      case ShuttleBookingStatus.paymentSubmitted:
        return "Payment Submitted";

      case ShuttleBookingStatus.reserved:
        return "Reserved";

      case ShuttleBookingStatus.approved:
        return "Approved";

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
