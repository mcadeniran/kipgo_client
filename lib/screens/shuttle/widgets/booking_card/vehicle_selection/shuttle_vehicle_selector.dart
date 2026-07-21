import 'package:flutter/material.dart';
import 'package:kipgo/controllers/shuttle_fleet_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_fleet_vehicle.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleVehicleSelector extends StatelessWidget {
  final ShuttleDraft draft;
  final ValueChanged<ShuttleFleetVehicle> onSelected;

  const ShuttleVehicleSelector({
    super.key,
    required this.draft,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final provider = context.watch<ShuttleFleetProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final vehicles = provider.vehiclesForPassengers(draft.passengers);

    if (vehicles.isEmpty) {
      return Center(child: Text(loc.noSuitableVehicle));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        return _VehicleCard(
          draft: draft,
          vehicle: vehicles[index],
          onTap: () => onSelected(vehicles[index]),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final ShuttleFleetVehicle vehicle;
  final ShuttleDraft draft;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = draft.distanceKm * vehicle.pricePerKm;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    final selected = draft.selectedVehicle?.id == vehicle.id;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (isDark ? AppColors.lightLayer : AppColors.primary)
                : AppColors.border.withValues(alpha: 0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.airport_shuttle,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    vehicle.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (selected)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),

            const SizedBox(height: 18),

            _InfoRow(loc.capacity, loc.seatsCount(vehicle.capacity)),

            _InfoRow(
              loc.distance,
              loc.distanceKm(draft.distanceKm.toStringAsFixed(1)),
            ),

            // _InfoRow("Estimated Time", "${draft.durationMinutes} mins"),
            _InfoRow(
              loc.rate,
              loc.pricePerKm(
                formatCurrency(
                  amount: vehicle.pricePerKm,
                  currencyCode: vehicle.currency,
                  context: context,
                  decimalDigits: 0,
                ),
              ),
            ),

            const Divider(height: 20),

            _InfoRow(
              loc.total,
              formatCurrency(
                amount: total,
                currencyCode: vehicle.currency,
                context: context,
              ),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
