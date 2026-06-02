import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/is_unit_available.dart';
import 'package:kipgo/utils/colors.dart';

class StartBookingSheet extends StatefulWidget {
  final BookingModel booking;
  const StartBookingSheet({super.key, required this.booking});

  static Future<StartBookingResult?> show(
    BuildContext context,
    BookingModel booking,
  ) {
    return showModalBottomSheet<StartBookingResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StartBookingSheet(booking: booking),
    );
  }

  @override
  State<StartBookingSheet> createState() => _StartBookingSheetState();
}

class _StartBookingSheetState extends State<StartBookingSheet> {
  String? selectedUnitId;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<CarUnit>>(
          stream: BookingRepository().streamCarUnits(widget.booking.carId),
          builder: (context, unitsSnapshot) {
            if (!unitsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final units = unitsSnapshot.data!;

            return StreamBuilder<List<BookingModel>>(
              stream: BookingRepository().streamApprovedCarBookings(
                widget.booking.carId,
              ),
              builder: (context, bookingsSnapshot) {
                if (!bookingsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = bookingsSnapshot.data!;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.assignUnit,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: units.map((unit) {
                          final conflict = getConflictReason(
                            context,
                            unit.id,
                            bookings,
                            widget.booking,
                          );

                          final available =
                              conflict == null && unit.status == "available";

                          return ListTile(
                            title: Text(unit.numberPlate),
                            subtitle: Text(unit.colour),
                            trailing: available
                                ? Radio<String>(
                                    value: unit.id,
                                    groupValue: selectedUnitId,
                                    onChanged: (v) {
                                      setState(() {
                                        selectedUnitId = v;
                                      });
                                    },
                                  )
                                : Text(loc.unavailable),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: selectedUnitId == null
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  StartBookingResult(unitId: selectedUnitId!),
                                );
                              },
                        child: Text(loc.continueAction),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StartBookingResult {
  final String unitId;

  const StartBookingResult({required this.unitId});
}
