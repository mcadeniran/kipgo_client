import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/shuttle_fleet_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_car_title.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_group_counter.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_selection_tile.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_submit_button.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/vehicle_selection/vehicle_selection_screen.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/interactive_location_picker.dart';
import 'package:kipgo/screens/shuttle/widgets/pickers/booking_date_picker.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/location_formatter.dart';
import 'package:provider/provider.dart';

class ShuttleBookingCard extends StatelessWidget {
  const ShuttleBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final booking = context.watch<ShuttleBookingProvider>();
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: isDark ? AppColors.darkAccent : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const BookingCardTitle(),

            const SizedBox(height: 28),

            BookingSelectionTile(
              title: loc.pickupLocation,
              value: booking.draft.pickup == null
                  ? null
                  : LocationFormatter.title(booking.draft.pickup!),
              subtitle: booking.draft.pickup == null
                  ? null
                  : LocationFormatter.subtitle(booking.draft.pickup!),
              placeholder: loc.selectPickupLocation,
              icon: Icons.location_on_rounded,
              onTap: () async {
                final result = await Navigator.push<ShuttleLocation>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InteractiveLocationPicker(
                      isPickup: true,
                      initialLocation: booking.draft.pickup,
                    ),
                  ),
                );

                if (result != null) {
                  if (context.mounted) {
                    context.read<ShuttleBookingProvider>().setPickup(result);
                  }
                }
              },
            ),

            const SizedBox(height: 16),

            BookingSelectionTile(
              title: loc.dropoffLocation,
              value: booking.draft.destination == null
                  ? null
                  : LocationFormatter.title(booking.draft.destination!),
              subtitle: booking.draft.destination == null
                  ? null
                  : LocationFormatter.subtitle(booking.draft.destination!),
              placeholder: loc.selectDestination,
              icon: Icons.flag_circle_rounded,
              onTap: () async {
                final result = await Navigator.push<ShuttleLocation>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InteractiveLocationPicker(
                      isPickup: false,
                      initialLocation: booking.draft.destination,
                    ),
                  ),
                );

                if (result != null) {
                  if (context.mounted) {
                    context.read<ShuttleBookingProvider>().setDestination(
                      result,
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 16),

            BookingSelectionTile(
              title: loc.departure,
              value: booking.draft.departureDate != null
                  ? DateFormat(
                      "EEE, MMM d • h:mm a",
                    ).format(booking.draft.departureDate!)
                  : null,
              placeholder: loc.selectDepartureDate,
              icon: Icons.calendar_month_rounded,
              onTap: () async {
                final result = await BookingDatePicker.show(
                  context,
                  selectedDate: context
                      .read<ShuttleBookingProvider>()
                      .draft
                      .departureDate,
                );

                if (result == null) return;

                if (context.mounted) {
                  context.read<ShuttleBookingProvider>().setDepartureDate(
                    result,
                  );
                }
              },
            ),

            // ROUND TRIP SELECTION IF NEEDED LATER (JUST UNCOMMENT)
            // const SizedBox(height: 16),

            // BookingTripSelector(
            //   roundTrip: booking.draft.roundTrip,
            //   onChanged: context.read<ShuttleBookingProvider>().toggleRoundTrip,
            // ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: booking.draft.roundTrip
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: BookingSelectionTile(
                        title: loc.returnDate,
                        value: booking.draft.returnDate != null
                            ? DateFormat.yMMMMd().format(
                                booking.draft.returnDate!,
                              )
                            : null,
                        placeholder: loc.selectReturnDate,
                        icon: Icons.event_repeat,
                        onTap: () async {
                          final result = await BookingDatePicker.show(
                            context,

                            title: loc.returnDate,

                            selectedDate: booking.draft.returnDate,
                          );

                          if (result == null) return;

                          if (context.mounted) {
                            context
                                .read<ShuttleBookingProvider>()
                                .setReturnDate(result);
                          }
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            BookingGroupCounter(
              passengers: booking.draft.passengers,
              increment: context
                  .read<ShuttleBookingProvider>()
                  .incrementPassengers,
              decrement: context
                  .read<ShuttleBookingProvider>()
                  .decrementPassengers,
            ),

            const SizedBox(height: 28),

            BookingSubmitButton(
              loading: booking.loadingRoute,
              onPressed: booking.loadingRoute
                  ? null
                  : booking.draft.canContinue
                  ? () async {
                      await booking.prepareVehicleSelection(
                        context.read<ShuttleFleetProvider>(),
                      );

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleSelectionScreen(),
                        ),
                      );
                    }
                  : () => ReusableToast.error(
                      context,
                      loc.error,
                      booking.validationMessage ?? loc.unknownError,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
