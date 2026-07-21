import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';

class ShuttlePaymentBadge extends StatelessWidget {
  final ShuttlePaymentMethod method;

  const ShuttlePaymentBadge({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final bool crypto = method == ShuttlePaymentMethod.crypto;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: crypto ? Colors.deepPurple.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        crypto ? "Crypto" : "Pay on Delivery",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: crypto ? Colors.deepPurple.shade900 : Colors.green.shade900,
        ),
      ),
    );
  }
}
