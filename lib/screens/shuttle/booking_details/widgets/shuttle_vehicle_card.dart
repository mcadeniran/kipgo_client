import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleVehicleCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleVehicleCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.vehicle == null) {
      return const _WaitingVehicleCard();
    }

    final vehicle = booking.vehicle!;
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkAccent : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.airport_shuttle,
                size: 34,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.assignedVehicle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _VehicleInfoRow(label: loc.vehicle, value: vehicle.fullName),

                  _VehicleInfoRow(
                    label: loc.numberPlate,
                    value: vehicle.plateNumber,
                  ),

                  _VehicleInfoRow(
                    label: loc.seatsLabel,
                    value: vehicle.capacity.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingVehicleCard extends StatelessWidget {
  const _WaitingVehicleCard();

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.airport_shuttle_outlined, color: AppColors.primary),

            SizedBox(width: 16),

            Expanded(child: Text(loc.aVehicleWillBeAssigned)),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _VehicleInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
