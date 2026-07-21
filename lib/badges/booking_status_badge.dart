import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    String text;
    AppLocalizations loc = AppLocalizations.of(context)!;

    switch (status) {
      case 'pending':
      case 'awaitingPayment':
        color = Colors.yellow.shade100;
        textColor = Colors.yellow.shade900;
        text = status == 'pending' ? loc.pending : loc.awaitingPayment;
        break;
      case 'payment_submitted':
      case 'paymentSubmitted':
        color = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        text = loc.paymentSubmitted;
        break;
      case 'approved':
        color = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        text = loc.approved;
        break;
      case 'reserved':
        color = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        text = loc.reserved;
        break;
      case 'ongoing':
        color = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        text = loc.ongoing;
        break;
      case 'completed':
        color = Colors.green.shade100;
        textColor = Colors.green.shade900;
        text = loc.completed;
        break;
      case 'cancelled':
        color = Colors.red.shade100;
        textColor = Colors.red.shade900;
        text = loc.cancelled;
        break;
      case 'rejected':
        color = Colors.red.shade100;
        textColor = Colors.red.shade900;
        text = loc.rejected;
        break;
      case 'expired':
        color = Colors.blueGrey.shade100;
        textColor = Colors.blueGrey.shade900;
        text = loc.expired;
        break;
      default:
        color = Colors.grey.shade100;
        textColor = Colors.red.shade900;
        text = loc.unknown;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
