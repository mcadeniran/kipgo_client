import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/shuttle_bookings_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/screens/shuttle/booking_details/shuttle_booking_details_page.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class UpcomingBookingCard extends StatelessWidget {
  const UpcomingBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final booking = context.watch<ShuttleBookingsProvider>().upcomingBooking;

    if (booking == null) {
      return const SizedBox.shrink();
    }

    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

    String getTitle(ShuttleBookingStatus status) {
      switch (status) {
        case ShuttleBookingStatus.awaitingPayment:
          return loc.paymentRequired;
        case ShuttleBookingStatus.pending:
          return loc.awaitingApproval;
        case ShuttleBookingStatus.approved:
          return loc.upcomingTrip;
        case ShuttleBookingStatus.confirmed:
          return loc.upcomingTrip;
        case ShuttleBookingStatus.driverAssigned:
          return loc.driverAssigned;
        case ShuttleBookingStatus.driverArriving:
          return loc.yourDriverIsArriving;
        default:
          return loc.upcomingEvent;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),

              const SizedBox(width: 8),

              Text(
                getTitle(booking.status),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            // BookingDateFormatter.format(context, booking.departureDate),
            formatDate(context, booking.departureDate),
            style: theme.textTheme.titleSmall,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Icon(Icons.location_on),

              SizedBox(width: 8),

              Expanded(child: Text(booking.pickup.displayName)),
            ],
          ),

          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: SizedBox(height: 22, child: VerticalDivider()),
          ),

          Row(
            children: [
              Icon(Icons.flag),

              SizedBox(width: 8),

              Expanded(child: Text(booking.destination.displayName)),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.groups),

              const SizedBox(width: 8),

              Text(loc.passengersCount(booking.passengers)),

              const Spacer(),

              BookingStatusBadge(status: booking.status.value),
            ],
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShuttleBookingDetailsPage(booking: booking),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(loc.viewBooking),
            ),
          ),
        ],
      ),
    );
  }
}
