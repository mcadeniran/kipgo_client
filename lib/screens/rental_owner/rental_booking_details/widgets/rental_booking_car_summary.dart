import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/utils/car_properties_translations.dart';

class RentalBookingCarSummary extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalBookingCarSummary({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        carSummaryCard(
          title: loc.name,
          details:
              '${booking.car.year} ${booking.car.brand} ${booking.car.model}',
        ),
        SizedBox(height: 8),
        carSummaryCard(
          title: loc.transmission,
          details: carPropertiesTranslations(context, booking.car.transmission),
        ),
        SizedBox(height: 8),
        carSummaryCard(
          title: loc.seatsLabel,
          details: booking.car.seats.toString(),
        ),
        SizedBox(height: 8),
        carSummaryCard(
          title: loc.fuel,
          details: carPropertiesTranslations(context, booking.car.fuel),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Row carSummaryCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(details),
      ],
    );
  }
}
