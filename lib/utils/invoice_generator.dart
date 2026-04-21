import 'dart:math';

String generateInvoiceNumber() {
  final now = DateTime.now();

  final date =
      "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

  final random = Random().nextInt(9000) + 1000;

  return "KIP-$date-$random";
}
