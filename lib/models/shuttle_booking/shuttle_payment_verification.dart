import 'package:cloud_firestore/cloud_firestore.dart';

class ShuttlePaymentVerification {
  final String? verifiedBy;

  final DateTime? verifiedAt;

  const ShuttlePaymentVerification({this.verifiedBy, this.verifiedAt});

  factory ShuttlePaymentVerification.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ShuttlePaymentVerification();
    }

    return ShuttlePaymentVerification(
      verifiedBy: map['verifiedBy'],
      verifiedAt: map['verifiedAt'] is Timestamp
          ? (map['verifiedAt'] as Timestamp).toDate()
          : map['verifiedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'verifiedBy': verifiedBy, 'verifiedAt': verifiedAt};
  }
}
