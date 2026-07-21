import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_crypto.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_payment.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/models/wallet.dart';
import 'package:kipgo/utils/convert_to_usdt.dart';
import 'package:kipgo/models/shuttle_draft.dart';

class ShuttlePaymentRepository {
  final FirebaseFirestore _firestore;

  ShuttlePaymentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<ShuttleBookingPayment> buildPayment({
    required ShuttleDraft draft,
  }) async {
    switch (draft.payment.method) {
      case ShuttlePaymentMethod.crypto:
        return _buildCryptoPayment(draft);

      case ShuttlePaymentMethod.payOnDelivery:
        return _buildPayOnPickupPayment();
    }
  }

  Future<ShuttleBookingPayment> _buildPayOnPickupPayment() async {
    return ShuttleBookingPayment(
      method: ShuttlePaymentMethod.payOnDelivery,
      status: ShuttlePaymentStatus.unpaid,
      verified: false,
      completed: false,
      reference: null,
      paidAt: null,
      expiresAt: null,
      crypto: null,
      verification: null,
      rejection: null,
    );
  }

  Future<ShuttleBookingPayment> _buildCryptoPayment(ShuttleDraft draft) async {
    final wallet = await _getWallet();

    final cryptoAmount = await convertToUsdt(
      draft.totalPrice,
      draft.selectedVehicle!.currency,
      wallet.networkFee,
    );

    return ShuttleBookingPayment(
      method: ShuttlePaymentMethod.crypto,
      status: ShuttlePaymentStatus.pending,
      verified: false,
      completed: false,
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      crypto: ShuttleBookingCrypto(
        walletAddress: wallet.wallet,
        network: wallet.network,
        currency: wallet.currency,
        amount: cryptoAmount,
        networkFee: wallet.networkFee,
        transactionVerified: false,
      ),
    );
  }

  Future<WalletModel> _getWallet() async {
    final doc = await _firestore.collection("misc").doc("wallet").get();

    return WalletModel.fromSnapshot(doc);
  }
}
