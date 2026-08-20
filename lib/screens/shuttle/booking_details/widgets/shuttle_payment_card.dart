import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cryptocurrency.dart';
import 'package:kipgo/controllers/shuttle_bookings_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/payment_status_chip.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/shuttle_crypto_payment_screen.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  : payment.method.value == 'creditCard'
                  ? loc.cardPayment
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

            if (payment.method == ShuttlePaymentMethod.creditCard) ...[
              Divider(
                height: 30,
                color: isDark
                    ? AppColors.border.withValues(alpha: .4)
                    : AppColors.border,
              ),

              _CardPaymentSection(booking: booking),
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

class _CardPaymentSection extends StatelessWidget {
  final ShuttleBooking booking;

  const _CardPaymentSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment;
    final loc = AppLocalizations.of(context)!;
    final provider = context.watch<ShuttleBookingsProvider>();
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    Future<void> confirmPayment(
      BuildContext context,
      ShuttleBookingsProvider provider,
    ) async {
      final loc = AppLocalizations.of(context)!;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(loc.confirmPayment),

            content: Text(loc.confirmPaymentDescription),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(loc.cancel),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(loc.confirmPayment),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

      try {
        await provider.submitCardPayment(booking.id);

        if (!context.mounted) return;

        ReusableToast.success(
          context,
          loc.success,
          loc.yourPaymentSubmittedSuccessfully,
        );
      } catch (e) {
        if (!context.mounted) return;

        ReusableToast.error(context, loc.error, e.toString());
      }
    }
    //--------------------------------------------------------
    // Booking not yet approved
    //--------------------------------------------------------

    if (booking.status == ShuttleBookingStatus.pending) {
      return _PaymentMessage(
        icon: Icons.schedule,
        color: Colors.orange,
        message: loc.yourBookingIsAwaitingApproval,
      );
    }

    //--------------------------------------------------------
    // Approved but payment link not created
    //--------------------------------------------------------

    if (payment.paymentLink == null || payment.paymentLink!.trim().isEmpty) {
      return _PaymentMessage(
        icon: Icons.link_off,
        color: Colors.orange,
        message: loc.paymentLinkWillAppearHereOnceGenerated,
      );
    }

    //--------------------------------------------------------
    // Waiting for payment
    //--------------------------------------------------------

    if (payment.status == ShuttlePaymentStatus.unpaid ||
        payment.status == ShuttlePaymentStatus.awaitingPayment) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white : AppColors.primary,
            ),
            icon: const Icon(Icons.open_in_new),
            label: Text(loc.openPaymentPage),
            onPressed: () async {
              final uri = Uri.parse(payment.paymentLink!);

              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: provider.submittingCardPayment
                ? null
                : () => confirmPayment(context, provider),

            icon: provider.submittingCardPayment
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),

            label: Text(
              provider.submittingCardPayment
                  ? loc.submitting
                  : loc.iHaveCompletedPayment,
            ),
          ),
        ],
      );
    }

    //--------------------------------------------------------
    // Waiting for company verification
    //--------------------------------------------------------

    if (payment.status == ShuttlePaymentStatus.awaitingVerification) {
      return _PaymentMessage(
        icon: Icons.hourglass_top,
        color: Colors.orange,
        message: loc.weAreVerifyingYourPayment,
      );
    }

    //--------------------------------------------------------
    // Paid
    //--------------------------------------------------------

    if (payment.status == ShuttlePaymentStatus.paid) {
      return _PaymentMessage(
        icon: Icons.check_circle,
        color: Colors.green,
        message: loc.paymentVerifiedSuccessfully,
      );
    }

    //--------------------------------------------------------
    // Failed
    //--------------------------------------------------------

    if (payment.status == ShuttlePaymentStatus.failed) {
      return Column(
        children: [
          _PaymentMessage(
            icon: Icons.error_outline,
            color: Colors.red,
            message: loc.paymentFailedPleaseTryAgain,
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(loc.tryAgain),
            onPressed: () async {
              final uri = Uri.parse(payment.paymentLink!);

              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _PaymentMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _PaymentMessage({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 12),

          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
