import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String currency;
  final String network;
  final double networkFee;
  final String wallet;

  WalletModel({
    required this.currency,
    required this.network,
    required this.networkFee,
    required this.wallet,
  });

  factory WalletModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      currency: data['currency'],
      network: data['network'],
      wallet: data['wallet'],
      networkFee: (data['network_fee'] ?? 0).toDouble(),
    );
  }
}
