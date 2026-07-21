import 'package:flutter/material.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/cards/shuttle_booking_skeleton.dart';

class ShuttleBookingLoading extends StatelessWidget {
  const ShuttleBookingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,

      itemBuilder: (_, _) => const ShuttleBookingSkeleton(),
    );
  }
}
