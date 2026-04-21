import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/bookings/bookings_history.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_history_card.dart';
import 'package:provider/provider.dart';

class BookingHistoryTab extends StatelessWidget {
  final BookingSection section;

  const BookingHistoryTab({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();

        List bookings = provider.bookings.where((booking) {
          switch (section) {
            case BookingSection.upcoming:
              return booking.status == "pending" ||
                  booking.status == "approved";

            case BookingSection.active:
              return booking.status == "ongoing" ||
                  (booking.pickupDate.isBefore(now) &&
                      booking.dropoffDate.isAfter(now));

            case BookingSection.past:
              return booking.status == "completed" ||
                  booking.dropoffDate.isBefore(now);

            case BookingSection.cancelled:
              return booking.status == "cancelled" ||
                  booking.status == "rejected";
          }
        }).toList();

        if (bookings.isEmpty) {
          return Center(child: Text(loc.noBookingsHere));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            final rentalDays = booking.dropoffDate
                .difference(booking.pickupDate)
                .inDays;

            return BookingHistoryCard(booking: booking, rentalDays: rentalDays);
          },
        );
      },
    );
  }
}
