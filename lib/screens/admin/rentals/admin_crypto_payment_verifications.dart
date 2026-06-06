import 'package:flutter/material.dart';
import 'package:kipgo/controllers/crypto_verification_provider.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/crypto_payment_slip.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminCryptoPaymentVerifications extends StatefulWidget {
  const AdminCryptoPaymentVerifications({super.key});

  @override
  State<AdminCryptoPaymentVerifications> createState() =>
      _AdminCryptoPaymentVerificationsState();
}

class _AdminCryptoPaymentVerificationsState
    extends State<AdminCryptoPaymentVerifications> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<CryptoVerificationProvider>().listenForAwaitingPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Consumer<CryptoVerificationProvider>(
          builder: (_, provider, _) {
            final bookings = provider.bookings;

            if (bookings.isEmpty) {
              return const Center(
                child: Text('No payments awaiting verification'),
              );
            }

            return ListView.builder(
              itemCount: bookings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, index) {
                final booking = bookings[index];
                return CryptoPaymentSlip(booking: booking);
              },
            );
          },
        ),
      ),
    );
  }
}
