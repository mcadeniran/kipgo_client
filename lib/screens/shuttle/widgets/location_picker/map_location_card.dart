import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/service_area_chip.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class MapLocationCard extends StatelessWidget {
  final ShuttleLocation? location;
  final VoidCallback onConfirm;
  final bool loading;
  final bool isPickup;

  const MapLocationCard({
    super.key,
    required this.location,
    required this.onConfirm,
    required this.loading,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(24),
      color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPickup ? loc.pickupLocation : loc.destination,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 18),

            _LocationInfo(loading: loading, location: location),

            const SizedBox(height: 20),

            ServiceAreaChip(
              loading: loading,
              serviceArea: location?.serviceArea,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading || location == null ? null : onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isPickup ? loc.useThisPickupLocation : loc.useThisDestination,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final ShuttleLocation? location;
  final bool loading;

  const _LocationInfo({required this.location, required this.loading});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    if (loading) {
      return const _LoadingLocation();
    }

    if (location == null) {
      return Text(loc.moveTheMap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            location!.displayName.isNotEmpty
                ? location!.displayName
                : location!.address,
            key: ValueKey(location!.placeId),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 6),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            location!.district == null
                ? location!.serviceArea
                : "${location!.district} • ${location!.serviceArea}",
            key: ValueKey("${location!.district}${location!.serviceArea}"),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _LoadingLocation extends StatelessWidget {
  const _LoadingLocation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 220,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 120,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
