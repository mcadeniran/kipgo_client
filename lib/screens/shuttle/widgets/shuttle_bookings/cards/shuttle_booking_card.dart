import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/payment_status_chip.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/booking_info_chip.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/location_tile.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleBookingCard extends StatelessWidget {
  final ShuttleBooking booking;

  final VoidCallback? onTap;

  const ShuttleBookingCard({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
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
                _Header(booking),
                Divider(
                  height: 30,
                  color: isDark
                      ? AppColors.border.withValues(alpha: 0.4)
                      : AppColors.border,
                ),

                _RouteSection(booking),

                Divider(
                  height: 30,
                  color: isDark
                      ? AppColors.border.withValues(alpha: 0.4)
                      : AppColors.border,
                ),

                _TripInfoSection(booking),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: booking.driver != null
                      ? _DriverSection(booking)
                      : const SizedBox.shrink(),
                ),

                Divider(
                  height: 30,
                  color: isDark
                      ? AppColors.border.withValues(alpha: 0.4)
                      : AppColors.border,
                ),

                PaymentStatusChip(payment: booking.payment),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ShuttleBooking booking;

  const _Header(this.booking);

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.bookingNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.lightAccent : AppColors.darkAccent,
                ),
              ),
            ],
          ),
        ),
        BookingStatusBadge(status: booking.status.value),
      ],
    );
  }
}

class _RouteSection extends StatelessWidget {
  final ShuttleBooking booking;

  const _RouteSection(this.booking);

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationTile(
          title: loc.pickup,
          name: booking.pickup.displayName,
          address: booking.pickup.address,
        ),

        const SizedBox(height: 12),

        LocationTile(
          title: loc.destination,
          name: booking.destination.displayName,
          address: booking.destination.address,
        ),
      ],
    );
  }
}

class _TripInfoSection extends StatelessWidget {
  final ShuttleBooking booking;

  const _TripInfoSection(this.booking);

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('MMM d • HH:mm', '$locale').format(date);
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        BookingInfoChip(
          icon: Icons.calendar_today,
          label: loc.departure,
          value: formatDate(context, booking.departureDate),
        ),

        BookingInfoChip(
          icon: Icons.people,
          label: loc.passengers,
          value: booking.passengers.toString(),
        ),

        BookingInfoChip(
          icon: Icons.payments,
          label: loc.payment,
          value: booking.payment.method.value == 'payOnDelivery'
              ? loc.cash
              : loc.crypto,
        ),

        BookingInfoChip(
          icon: Icons.account_balance_wallet,
          label: loc.amount,
          value: formatCurrency(
            amount: booking.total,
            currencyCode: booking.currency,
            context: context,
          ),
        ),
      ],
    );
  }
}

class _DriverSection extends StatelessWidget {
  final ShuttleBooking booking;

  const _DriverSection(this.booking);

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final driver = booking.driver!;
    final vehicle = booking.vehicle;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, child: Icon(Icons.person)),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                if (vehicle != null)
                  Text(
                    vehicle.fullName,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
