import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:provider/provider.dart';

class RentalBookingSchedule extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalBookingSchedule({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;

    int calculateRentalDays() {
      final duration = booking.dropoffDate.difference(booking.pickupDate);
      final totalDays = duration.inHours / 24;
      final chargeableDays = totalDays.ceil();
      return chargeableDays;
    }

    return Column(
      children: [
        rentalScheduleCard(
          title: loc.pickupDate,
          details: DateFormat(
            'dd MMM yyyy • HH:mm',
            '$locale',
          ).format(booking.pickupDate),
        ),
        SizedBox(height: 8),
        rentalScheduleCard(
          title: loc.dropoffDate,
          details: DateFormat(
            'dd MMM yyyy • HH:mm',
            '$locale',
          ).format(booking.dropoffDate),
        ),
        SizedBox(height: 8),
        rentalScheduleCard(
          title: loc.totalDuration,
          details: loc.multiRentalDay(calculateRentalDays()),
        ),
      ],
    );
  }

  Row rentalScheduleCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(details),
      ],
    );
  }
}
