import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental_owner/rental_owner_bookings.dart';
import 'package:kipgo/screens/rental_owner/widgets/booking_card.dart';
import 'package:provider/provider.dart';

class BookingListTab extends StatelessWidget {
  final BookingTabType type;

  const BookingListTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<BookingModel> bookings;

    switch (type) {
      case BookingTabType.attention:
        bookings = provider.attention;
        break;

      case BookingTabType.upcoming:
        bookings = provider.upcoming;
        break;

      case BookingTabType.ongoing:
        bookings = provider.ongoing;
        break;

      case BookingTabType.completed:
        bookings = provider.completed;
        break;

      case BookingTabType.closed:
        bookings = provider.closed;
        break;
    }

    if (bookings.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noBookingsHere));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (_, index) {
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}
