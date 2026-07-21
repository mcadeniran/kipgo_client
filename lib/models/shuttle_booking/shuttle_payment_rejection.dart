import 'package:cloud_firestore/cloud_firestore.dart';

class ShuttlePaymentRejection {
  final String? reason;

  final String? rejectedBy;

  final DateTime? rejectedAt;

  const ShuttlePaymentRejection({
    this.reason,
    this.rejectedBy,
    this.rejectedAt,
  });

  factory ShuttlePaymentRejection.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ShuttlePaymentRejection();
    }

    return ShuttlePaymentRejection(
      reason: map['reason'],
      rejectedBy: map['rejectedBy'],
      rejectedAt: map['rejectedAt'] is Timestamp
          ? (map['rejectedAt'] as Timestamp).toDate()
          : map['rejectedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt,
    };
  }
}
