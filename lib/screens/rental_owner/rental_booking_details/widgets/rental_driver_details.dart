import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

class RentalDriverDetails extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalDriverDetails({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    int calculateAge(String dob) {
      final parts = dob.split('/');

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;

      // Adjust if birthday hasn't happened yet this year
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    }

    return Column(
      children: [
        driverDetailsCard(title: loc.name, details: booking.driver.name),
        SizedBox(height: 8),
        driverDetailsCard(title: loc.email, details: booking.driver.email),
        SizedBox(height: 8),
        driverDetailsCard(title: loc.phone, details: booking.driver.phone),
        SizedBox(height: 8),
        driverDetailsCard(
          title: loc.gender,
          details: booking.driver.gender == 'Male'
              ? loc.male
              : booking.driver.gender == 'Female'
              ? loc.female
              : loc.others,
        ),
        SizedBox(height: 8),
        driverDetailsCard(
          title: loc.age,
          details: calculateAge(booking.driver.dob).toString(),
        ),
      ],
    );
  }

  Row driverDetailsCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(details),
      ],
    );
  }
}
