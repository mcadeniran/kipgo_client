import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

class RentalBookingDelivery extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalBookingDelivery({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        rentalDeliveryCard(
          title: loc.deliveryType,
          // details: carPropertiesTranslations(context, booking.deliveryType),
          details: booking.deliveryType == 'delivery'
              ? loc.homeDelivery
              : loc.officePickup,
        ),
        if (booking.deliveryType == 'delivery' &&
            booking.deliveryAddress != '') ...[
          SizedBox(height: 8),
          rentalDeliveryCard(
            title: loc.dropoffAddress,
            details: booking.deliveryAddress,
          ),
        ],
        if (booking.note != '') ...[
          SizedBox(height: 8),
          rentalDeliveryCard(title: loc.additionalNote, details: booking.note),
        ],
      ],
    );
  }

  Row rentalDeliveryCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(width: 8),
        Expanded(child: Text(details, textAlign: TextAlign.end)),
      ],
    );
  }
}
