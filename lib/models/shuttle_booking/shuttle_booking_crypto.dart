import 'package:cloud_firestore/cloud_firestore.dart';

class ShuttleBookingCrypto {
  final String walletAddress;

  final String network;

  final String currency;

  final double amount;

  final double networkFee;

  final String? transactionId;

  final bool transactionVerified;

  final String? rejectionReason;

  final DateTime? submittedAt;

  const ShuttleBookingCrypto({
    required this.walletAddress,
    required this.network,
    required this.currency,
    required this.amount,
    required this.networkFee,
    this.transactionId,
    required this.transactionVerified,
    this.rejectionReason,
    this.submittedAt,
  });

  factory ShuttleBookingCrypto.empty() {
    return const ShuttleBookingCrypto(
      walletAddress: '',
      network: 'TRC20',
      currency: 'USDT',
      amount: 0,
      networkFee: 0,
      transactionVerified: false,
    );
  }

  factory ShuttleBookingCrypto.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingCrypto.empty();
    }

    return ShuttleBookingCrypto(
      walletAddress: map['walletAddress'] ?? '',
      network: map['network'] ?? 'TRC20',
      currency: map['currency'] ?? 'USDT',
      amount: (map['amount'] ?? 0).toDouble(),
      networkFee: (map['networkFee'] ?? 0).toDouble(),
      transactionId: map['transactionId'],
      transactionVerified: map['transactionVerified'] ?? false,
      rejectionReason: map['rejectionReason'],
      submittedAt: map['submittedAt'] is Timestamp
          ? (map['submittedAt'] as Timestamp).toDate()
          : map['submittedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletAddress': walletAddress,
      'network': network,
      'currency': currency,
      'amount': amount,
      'networkFee': networkFee,
      'transactionId': transactionId,
      'transactionVerified': transactionVerified,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt,
    };
  }

  ShuttleBookingCrypto copyWith({
    String? walletAddress,
    String? network,
    String? currency,
    double? amount,
    double? networkFee,
    String? transactionId,
    bool? transactionVerified,
    String? rejectionReason,
    DateTime? submittedAt,
  }) {
    return ShuttleBookingCrypto(
      walletAddress: walletAddress ?? this.walletAddress,
      network: network ?? this.network,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      networkFee: networkFee ?? this.networkFee,
      transactionId: transactionId ?? this.transactionId,
      transactionVerified: transactionVerified ?? this.transactionVerified,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
