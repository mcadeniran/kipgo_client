import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/repositories/booking_repository.dart';

class RentalAssignedUnit extends StatefulWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalAssignedUnit({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  State<RentalAssignedUnit> createState() => _RentalAssignedUnitState();
}

class _RentalAssignedUnitState extends State<RentalAssignedUnit> {
  CarUnit? unit;
  bool unitLoaded = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final u = await BookingRepository().fetchCarUnitByCarId(
      carId: widget.booking.carId,
      unitId: widget.booking.unitId!,
    );

    setState(() {
      unit = u;
      unitLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    if (unit == null && unitLoaded == false) {
      return const Center(child: CircularProgressIndicator());
    }

    if (unit == null && unitLoaded == true) {
      return Center(child: Text(loc.unitNotFound));
    }
    return Column(
      children: [
        assignedUnitCard(title: loc.numberPlate, details: unit!.numberPlate),
        assignedUnitCard(title: loc.colour, details: unit!.colour),
        assignedUnitCard(
          title: loc.status,
          details: unit!.status == 'available'
              ? loc.available
              : loc.maintenance,
        ),
      ],
    );
  }

  Row assignedUnitCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(details),
      ],
    );
  }
}
