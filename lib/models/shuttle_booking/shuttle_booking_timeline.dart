import 'package:cloud_firestore/cloud_firestore.dart';

class ShuttleBookingTimeline {
  final DateTime? createdAt;

  final DateTime? paymentRequestedAt;

  final DateTime? paymentSubmittedAt;

  final DateTime? paymentVerifiedAt;

  final DateTime? confirmedAt;

  final DateTime? driverAssignedAt;

  final DateTime? driverArrivingAt;

  final DateTime? tripStartedAt;

  final DateTime? completedAt;

  final DateTime? cancelledAt;

  final DateTime? expiredAt;

  const ShuttleBookingTimeline({
    this.createdAt,
    this.paymentRequestedAt,
    this.paymentSubmittedAt,
    this.paymentVerifiedAt,
    this.confirmedAt,
    this.driverAssignedAt,
    this.driverArrivingAt,
    this.tripStartedAt,
    this.completedAt,
    this.cancelledAt,
    this.expiredAt,
  });

  factory ShuttleBookingTimeline.empty() {
    return ShuttleBookingTimeline(createdAt: DateTime.now());
  }

  factory ShuttleBookingTimeline.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingTimeline.empty();
    }

    return ShuttleBookingTimeline(
      createdAt: _parseTimestamp(map['createdAt']),
      paymentRequestedAt: _parseTimestamp(map['paymentRequestedAt']),
      paymentSubmittedAt: _parseTimestamp(map['paymentSubmittedAt']),
      paymentVerifiedAt: _parseTimestamp(map['paymentVerifiedAt']),
      confirmedAt: _parseTimestamp(map['confirmedAt']),
      driverAssignedAt: _parseTimestamp(map['driverAssignedAt']),
      driverArrivingAt: _parseTimestamp(map['driverArrivingAt']),
      tripStartedAt: _parseTimestamp(map['tripStartedAt']),
      completedAt: _parseTimestamp(map['completedAt']),
      cancelledAt: _parseTimestamp(map['cancelledAt']),
      expiredAt: _parseTimestamp(map['expiredAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'paymentRequestedAt': paymentRequestedAt,
      'paymentSubmittedAt': paymentSubmittedAt,
      'paymentVerifiedAt': paymentVerifiedAt,
      'confirmedAt': confirmedAt,
      'driverAssignedAt': driverAssignedAt,
      'driverArrivingAt': driverArrivingAt,
      'tripStartedAt': tripStartedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'expiredAt': expiredAt,
    };
  }

  ShuttleBookingTimeline copyWith({
    DateTime? createdAt,
    DateTime? paymentRequestedAt,
    DateTime? paymentSubmittedAt,
    DateTime? paymentVerifiedAt,
    DateTime? confirmedAt,
    DateTime? driverAssignedAt,
    DateTime? driverArrivingAt,
    DateTime? tripStartedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? expiredAt,
  }) {
    return ShuttleBookingTimeline(
      createdAt: createdAt ?? this.createdAt,
      paymentRequestedAt: paymentRequestedAt ?? this.paymentRequestedAt,
      paymentSubmittedAt: paymentSubmittedAt ?? this.paymentSubmittedAt,
      paymentVerifiedAt: paymentVerifiedAt ?? this.paymentVerifiedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      driverAssignedAt: driverAssignedAt ?? this.driverAssignedAt,
      driverArrivingAt: driverArrivingAt ?? this.driverArrivingAt,
      tripStartedAt: tripStartedAt ?? this.tripStartedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      expiredAt: expiredAt ?? this.expiredAt,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
