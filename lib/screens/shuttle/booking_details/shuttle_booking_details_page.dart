import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_action_buttons.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_booking_header.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_driver_card.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_passenger_card.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_payment_card.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_route_card.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_timeline_card.dart';
import 'package:kipgo/screens/shuttle/booking_details/widgets/shuttle_vehicle_card.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';

class ShuttleBookingDetailsPage extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleBookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarWidget(title: loc.bookingDetails),
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ShuttleBookingHeader(booking: booking),

            const SizedBox(height: 12),

            ShuttleRouteCard(booking: booking),

            const SizedBox(height: 12),

            ShuttlePassengerCard(booking: booking),

            const SizedBox(height: 12),

            ShuttleVehicleCard(booking: booking),

            const SizedBox(height: 12),

            ShuttleDriverCard(booking: booking),

            const SizedBox(height: 12),

            ShuttlePaymentCard(booking: booking),

            const SizedBox(height: 12),

            ShuttleTimelineCard(booking: booking),

            const SizedBox(height: 24),

            ShuttleActionButtons(booking: booking),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
