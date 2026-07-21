import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/screens/shuttle/shuttle_bottom_navigation.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/info_card.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/info_row.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/payment_status_chip.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/shuttle_crypto_payment_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleBookingCreatedScreen extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleBookingCreatedScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarWidget(title: loc.bookingCreated),
      backgroundColor: AppColors.primary,
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          minimum: const EdgeInsets.all(22),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.read<ShuttleBookingProvider>().resetDraft();

              if (payment.method == ShuttlePaymentMethod.crypto) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ShuttleCryptoPaymentScreen(bookingId: booking.id),
                  ),
                  (route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ShuttleBottomNavigation(initialIndex: 1),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              payment.method == ShuttlePaymentMethod.crypto
                  ? loc.continueToPayment
                  : loc.trackBooking,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _SuccessHero(booking: booking),

              const SizedBox(height: 24),

              InfoCard(
                title: loc.journey,
                child: Column(
                  children: [
                    InfoRow(
                      label: loc.pickup,
                      value: booking.pickup.displayName,
                    ),
                    InfoRow(
                      label: loc.destination,
                      value: booking.destination.displayName,
                    ),
                    InfoRow(
                      label: loc.departure,
                      value: booking.departureDate.toString(),
                    ),
                    if (booking.roundTrip && booking.returnDate != null)
                      InfoRow(
                        label: loc.returnString,
                        value: booking.returnDate.toString(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              InfoCard(
                title: loc.passenger,
                child: Column(
                  children: [
                    InfoRow(label: loc.name, value: booking.passenger.fullName),
                    InfoRow(
                      label: loc.phone,
                      value: booking.passenger.phoneNumber,
                    ),
                    InfoRow(label: loc.email, value: booking.passenger.email),
                    InfoRow(
                      label: loc.passengers,
                      value: booking.passengers.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (booking.vehicle != null)
                InfoCard(
                  title: loc.vehicle,
                  child: Column(
                    children: [
                      InfoRow(
                        label: loc.vehicle,
                        value: booking.vehicle!.fullName,
                      ),
                      // InfoRow(
                      //   label: loc.plate,
                      //   value: booking.vehicle!.plateNumber,
                      // ),
                      InfoRow(
                        label: loc.seatsLabel,
                        value: booking.vehicle!.seats.toString(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              InfoCard(
                title: loc.payment,
                trailing: PaymentStatusChip(payment: booking.payment),
                child: Column(
                  children: [
                    InfoRow(
                      label: loc.method,
                      value:
                          booking.payment.method == ShuttlePaymentMethod.crypto
                          ? loc.crypto
                          : loc.payOnPickup,
                    ),
                    InfoRow(
                      label: loc.amount,
                      value: formatCurrency(
                        amount: booking.total,
                        currencyCode: booking.currency,
                        context: context,
                      ),
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  final ShuttleBooking booking;

  const _SuccessHero({required this.booking});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 20),
        Text(
          loc.bookingCreatedSuccessfully,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          loc.yourShuttleRequestReceived,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: booking.bookingNumber));

            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.bookingNumberCopied)));
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  loc.bookingNumber,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.bookingNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.tapToCopy,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
