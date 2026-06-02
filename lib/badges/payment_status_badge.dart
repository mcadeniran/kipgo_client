import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    String text;
    AppLocalizations loc = AppLocalizations.of(context)!;

    switch (status) {
      case 'pending':
        color = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        text = loc.pending;
        break;
      case 'unpaid':
        color = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        text = loc.unpaid;
        break;
      case 'paid':
        color = Colors.green.shade100;
        textColor = Colors.green.shade900;
        text = loc.paid;
        break;
      case 'awaiting_verification':
        color = Colors.deepPurple.shade100;
        textColor = Colors.deepPurple.shade900;
        text = loc.awaitingVerification;
        break;
      case 'failed':
        color = Colors.red.shade100;
        textColor = Colors.red.shade900;
        text = loc.failed;
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
