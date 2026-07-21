import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_payment.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';

class PaymentStatusChip extends StatelessWidget {
  final ShuttleBookingPayment payment;

  const PaymentStatusChip({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    Color color;

    IconData icon;

    String text;

    switch (payment.status) {
      case ShuttlePaymentStatus.unpaid:
        color = Colors.blue;
        icon = Icons.schedule;
        text = loc.unpaid;
        break;

      case ShuttlePaymentStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        text = loc.pending;
        break;

      case ShuttlePaymentStatus.awaitingVerification:
        color = Colors.deepOrange;
        icon = Icons.verified_user_outlined;
        text = loc.awaitingVerification;
        break;

      case ShuttlePaymentStatus.paid:
        color = Colors.green;
        icon = Icons.check_circle;
        text = loc.paid;
        break;

      case ShuttlePaymentStatus.failed:
        color = Colors.red;
        icon = Icons.cancel;
        text = loc.failed;
        break;

      case ShuttlePaymentStatus.expired:
        color = Colors.grey;
        icon = Icons.timer_off;
        text = loc.expired;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
