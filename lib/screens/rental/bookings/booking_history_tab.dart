import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/bookings/bookings_history.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_history_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/empty/shuttle_booking_empty_state.dart';
import 'package:provider/provider.dart';

class BookingHistoryTab extends StatelessWidget {
  final BookingSection section;

  const BookingHistoryTab({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    String getEmptyTitle(BookingSection section) {
      switch (section.name) {
        case 'attention':
          return loc.allCaughtUp;
        case 'upcoming':
          return loc.noUpcomingRentals;
        case 'ongoing':
          return loc.noActiveRental;
        case 'completed':
          return loc.noCompletedRentals;
        case 'closed':
          return loc.noClosedRentals;
        default:
          return '';
      }
    }

    String getEmptyMessage(BookingSection section) {
      switch (section.name) {
        case 'attention':
          return loc.allCaughtUpSubtitle;
        case 'upcoming':
          return loc.yourConfirmedRentals;
        case 'ongoing':
          return loc.onceYourRentalPeriodStarts;
        case 'completed':
          return loc.yourRentalHistory;
        case 'closed':
          return loc.noClosedBookingsSubtitle;
        default:
          return '';
      }
    }

    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List bookings = [];

        switch (section) {
          case BookingSection.attention:
            bookings = provider.attention;
            break;

          case BookingSection.upcoming:
            bookings = provider.upcoming;
            break;

          case BookingSection.ongoing:
            bookings = provider.ongoing;
            break;

          case BookingSection.completed:
            bookings = provider.completed;
            break;

          case BookingSection.closed:
            bookings = provider.closed;
            break;
        }

        // if (bookings.isEmpty) {
        //   return Center(child: Text(loc.noBookingsHere));
        // }

        if (bookings.isEmpty) {
          return ShuttleBookingEmptyState(
            title: getEmptyTitle(section),
            subtitle: getEmptyMessage(section),
            iconify: GameIcons.cardboard_box,
          );
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
