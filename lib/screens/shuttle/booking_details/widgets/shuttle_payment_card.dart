import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cryptocurrency.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/payment_status_chip.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/shuttle_crypto_payment_screen.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttlePaymentCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttlePaymentCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment;
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkAccent : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  loc.payment,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _PaymentInfoRow(
              title: loc.method,
              value: payment.method.value == 'payOnDelivery'
                  ? loc.payOnDelivery
                  : loc.cryptoPayment,
            ),

            const SizedBox(height: 14),

            _PaymentInfoRow(
              title: loc.amount,
              value: formatCurrency(
                amount: booking.total,
                currencyCode: booking.currency,
                context: context,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(loc.status, style: theme.textTheme.bodyMedium),
                ),

                PaymentStatusChip(payment: payment),
              ],
            ),

            if (payment.method == ShuttlePaymentMethod.crypto) ...[
              Divider(
                height: 30,
                color: isDark
                    ? AppColors.border.withValues(alpha: 0.4)
                    : AppColors.border,
              ),

              _CryptoSection(booking: booking),
            ],

            if (payment.method == ShuttlePaymentMethod.payOnDelivery) ...[
              // const SizedBox(height: 24),
              const Divider(),

              // const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkLayer.withValues(alpha: 0.4)
                      : AppColors.lightAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? AppColors.lightLayer : AppColors.primary,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        loc.yourPaymentWillBeMadeDirectly,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _PaymentInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),

        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CryptoSection extends StatelessWidget {
  final ShuttleBooking booking;

  const _CryptoSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final payment = booking.payment;

    switch (payment.status) {
      case ShuttlePaymentStatus.unpaid:
      case ShuttlePaymentStatus.failed:
      case ShuttlePaymentStatus.pending:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ShuttleCryptoPaymentScreen(bookingId: booking.id),
              ),
            );
          },
          icon: Iconify(Cryptocurrency.usdt, color: AppColors.tron),
          label: Text(loc.continuePayment),
        );

      case ShuttlePaymentStatus.awaitingVerification:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(loc.yourPaymentHasBeenSubmitted),
        );

      case ShuttlePaymentStatus.paid:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),

              SizedBox(width: 12),

              Expanded(child: Text(loc.paymentVerifiedSuccessfully)),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
