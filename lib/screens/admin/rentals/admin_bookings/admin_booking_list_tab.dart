import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_booking_card.dart';
import 'package:kipgo/screens/admin/rentals/admin_rental_bookings.dart';
import 'package:provider/provider.dart';

class AdminBookingListTab extends StatelessWidget {
  final AdminBookingTabType type;

  const AdminBookingListTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    // ScrollController controller = ScrollController();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<BookingModel> bookings;

    switch (type) {
      case AdminBookingTabType.attention:
        bookings = provider.adminAttention;
        break;

      case AdminBookingTabType.upcoming:
        bookings = provider.adminUpcoming;
        break;

      case AdminBookingTabType.ongoing:
        bookings = provider.adminOngoing;
        break;

      case AdminBookingTabType.completed:
        bookings = provider.adminCompleted;
        break;

      case AdminBookingTabType.closed:
        bookings = provider.adminClosed;
        break;
    }

    if (bookings.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noBookingsHere));
    }

    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        // controller: controller,
        itemCount: bookings.length,
        itemBuilder: (_, index) {
          return AdminBookingCard(booking: bookings[index]);
        },
      ),
    );
  }
}

// class AdminBookingListTab extends StatelessWidget {
//   final AdminBookingTabType type;

//   const AdminBookingListTab({super.key, required this.type});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<BookingProvider>();

//     if (provider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final bookings = switch (type) {
//       AdminBookingTabType.attention => provider.adminAttention,
//       AdminBookingTabType.upcoming => provider.adminUpcoming,
//       AdminBookingTabType.ongoing => provider.adminOngoing,
//       AdminBookingTabType.completed => provider.adminCompleted,
//       AdminBookingTabType.closed => provider.adminClosed,
//     };

//     if (bookings.isEmpty) {
//       return Center(child: Text(AppLocalizations.of(context)!.noBookingsHere));
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(12),

//       // ✅ IMPORTANT FIX (prevents scroll conflicts)
//       physics: const AlwaysScrollableScrollPhysics(),

//       itemCount: bookings.length,
//       itemBuilder: (_, index) {
//         return AdminBookingCard(booking: bookings[index]);
//       },
//     );
//   }
// }
