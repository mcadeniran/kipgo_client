import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/cards/shuttle_booking_card.dart';

class ShuttleBookingList extends StatelessWidget {
  final List<ShuttleBooking> bookings;

  final Future<void> Function()? onRefresh;

  final VoidCallback? onLoadMore;

  final bool hasMore;

  final bool loadingMore;

  final void Function(ShuttleBooking booking)? onBookingTap;

  const ShuttleBookingList({
    super.key,
    required this.bookings,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.loadingMore = false,
    this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 250 &&
            hasMore &&
            !loadingMore) {
          onLoadMore?.call();
        }

        return false;
      },

      child: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},

        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.only(top: 8, bottom: 24),

          itemCount: bookings.length + (loadingMore ? 1 : 0),

          itemBuilder: (context, index) {
            if (index == bookings.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final booking = bookings[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ShuttleBookingCard(
                booking: booking,
                onTap: () {
                  onBookingTap?.call(booking);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
