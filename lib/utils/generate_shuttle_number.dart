import 'dart:math';

String generateShuttleInvoiceNumber() {
  final now = DateTime.now();

  final date =
      "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

  final random = Random().nextInt(9000) + 1000;

  return "SH-$date-$random";
}
