import 'package:cloud_firestore/cloud_firestore.dart';

import 'shuttle_booking_crypto.dart';
import 'shuttle_payment_method.dart';
import 'shuttle_payment_rejection.dart';
import 'shuttle_payment_status.dart';
import 'shuttle_payment_verification.dart';

class ShuttleBookingPayment {
  final ShuttlePaymentMethod method;

  final ShuttlePaymentStatus status;

  final bool verified;

  final bool completed;

  final String? reference;

  final DateTime? paidAt;

  final DateTime? expiresAt;

  final ShuttleBookingCrypto? crypto;

  final ShuttlePaymentVerification? verification;

  final ShuttlePaymentRejection? rejection;

  const ShuttleBookingPayment({
    required this.method,
    required this.status,
    required this.verified,
    required this.completed,
    this.reference,
    this.paidAt,
    this.expiresAt,
    this.crypto,
    this.verification,
    this.rejection,
  });

  factory ShuttleBookingPayment.empty() {
    return const ShuttleBookingPayment(
      method: ShuttlePaymentMethod.payOnDelivery,
      status: ShuttlePaymentStatus.unpaid,
      verified: false,
      completed: false,
    );
  }

  factory ShuttleBookingPayment.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingPayment.empty();
    }

    return ShuttleBookingPayment(
      method: ShuttlePaymentMethod.fromString(map['method']),
      status: ShuttlePaymentStatus.fromString(map['status']),
      verified: map['verified'] ?? false,
      completed: map['completed'] ?? false,
      reference: map['reference'],
      paidAt: map['paidAt'] is Timestamp
          ? (map['paidAt'] as Timestamp).toDate()
          : map['paidAt'],
      expiresAt: map['expiresAt'] is Timestamp
          ? (map['expiresAt'] as Timestamp).toDate()
          : map['expiresAt'],
      crypto: map['crypto'] != null
          ? ShuttleBookingCrypto.fromMap(map['crypto'])
          : null,
      verification: map['verification'] != null
          ? ShuttlePaymentVerification.fromMap(map['verification'])
          : null,
      rejection: map['rejection'] != null
          ? ShuttlePaymentRejection.fromMap(map['rejection'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method.value,
      'status': status.value,
      'verified': verified,
      'completed': completed,
      'reference': reference,
      'paidAt': paidAt,
      'expiresAt': expiresAt,
      'crypto': crypto?.toMap(),
      'verification': verification?.toMap(),
      'rejection': rejection?.toMap(),
    };
  }

  ShuttleBookingPayment copyWith({
    ShuttlePaymentMethod? method,
    ShuttlePaymentStatus? status,
    bool? verified,
    bool? completed,
    String? reference,
    DateTime? paidAt,
    DateTime? expiresAt,
    ShuttleBookingCrypto? crypto,
    ShuttlePaymentVerification? verification,
    ShuttlePaymentRejection? rejection,
  }) {
    return ShuttleBookingPayment(
      method: method ?? this.method,
      status: status ?? this.status,
      verified: verified ?? this.verified,
      completed: completed ?? this.completed,
      reference: reference ?? this.reference,
      paidAt: paidAt ?? this.paidAt,
      expiresAt: expiresAt ?? this.expiresAt,
      crypto: crypto ?? this.crypto,
      verification: verification ?? this.verification,
      rejection: rejection ?? this.rejection,
    );
  }
}
