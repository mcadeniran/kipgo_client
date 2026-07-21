import 'package:flutter/material.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/passenger_details/passenger_details_screen.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/vehicle_selection/shuttle_vehicle_selector.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarWidget(title: loc.selectVehicle),
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          child: Consumer<ShuttleBookingProvider>(
            builder: (context, booking, _) {
              final currentDraft = booking.draft;

              if (currentDraft.pickup == null ||
                  currentDraft.destination == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
                children: [
                  _TripSummaryHeader(draft: currentDraft),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ShuttleVehicleSelector(
                        draft: currentDraft,
                        onSelected: booking.selectVehicle,
                      ),
                    ),
                  ),

                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: currentDraft.selectedVehicle == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PassengerDetailsScreen(),
                                  ),
                                );
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentDraft.selectedVehicle == null
                                  ? loc.selectAVehicle
                                  : loc.continueAction,
                            ),
                            SizedBox(width: 5),
                            Text("(2/5)"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TripSummaryHeader extends StatelessWidget {
  const _TripSummaryHeader({required this.draft});

  final ShuttleDraft draft;

  @override
  Widget build(BuildContext context) {
    if (draft.pickup == null || draft.destination == null) {
      return const SizedBox.shrink();
    }
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        // border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.yourJourney,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 18),

          _JourneyRow(
            icon: Icons.my_location,
            color: Colors.green,
            text: draft.pickup!.address,
          ),

          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: SizedBox(height: 16, child: VerticalDivider()),
          ),

          _JourneyRow(
            icon: Icons.location_on,
            color: Colors.red,
            text: draft.destination!.address,
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TripChip(
                icon: Icons.route,
                label: loc.distanceKM(draft.distanceKm.toStringAsFixed(1)),
              ),
              _TripChip(
                icon: Icons.people,
                label: loc.passengersCount(draft.passengers),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }
}

class _TripChip extends StatelessWidget {
  const _TripChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: .08)
            : AppColors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
