import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/complete_booking_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingReviewScreen extends StatelessWidget {
  const BookingReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Consumer<ShuttleBookingProvider>(
      builder: (_, booking, _) {
        final draft = booking.draft;

        return Scaffold(
          appBar: AppBarWidget(title: loc.reviewBooking),
          backgroundColor: AppColors.primary,

          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Text(
                          loc.reviewYourBooking,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          loc.pleaseVerifyYourJourney,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _ReviewSection(
                          title: loc.journey,
                          icon: Icons.route,
                          onEdit: () {
                            Navigator.pop(context);
                            // Or navigate directly to booking screen if preferred.
                          },
                          child: _JourneyReview(draft: draft),
                        ),

                        const SizedBox(height: 18),

                        _ReviewSection(
                          title: loc.vehicle,
                          icon: Icons.airport_shuttle,
                          onEdit: () {
                            Navigator.pop(context);
                          },
                          child: _VehicleReview(draft: draft),
                        ),

                        const SizedBox(height: 18),

                        _ReviewSection(
                          title: loc.passenger,
                          icon: Icons.person_outline,
                          onEdit: () {
                            Navigator.pop(context);
                          },
                          child: _PassengerReview(draft: draft),
                        ),

                        if ((draft.specialRequest ?? "").trim().isNotEmpty) ...[
                          const SizedBox(height: 18),

                          _ReviewSection(
                            title: loc.specialRequest,
                            icon: Icons.chat_bubble_outline,
                            child: _SpecialRequestReview(
                              request: draft.specialRequest!,
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        _PriceSummaryCard(draft: draft),
                      ],
                    ),
                  ),

                  _ContinueToPaymentButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompleteBookingScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.child,
    this.onEdit,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _JourneyReview extends StatelessWidget {
  const _JourneyReview({required this.draft});

  final ShuttleDraft draft;

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

    return Column(
      children: [
        _ReviewRow(loc.pickup, draft.pickup?.address ?? "-"),

        _ReviewRow(loc.destination, draft.destination?.address ?? "-"),

        _ReviewRow(
          loc.departure,
          draft.departureDate != null
              ? formatDate(context, draft.departureDate!)
              : "-",
        ),

        if (draft.roundTrip)
          _ReviewRow(loc.returnString, draft.returnDate?.toString() ?? "-"),

        _ReviewRow(loc.passengers, draft.passengers.toString()),

        _ReviewRow(loc.distance, "${draft.distanceKm.toStringAsFixed(1)} km"),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleReview extends StatelessWidget {
  const _VehicleReview({required this.draft});

  final ShuttleDraft draft;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final vehicle = draft.selectedVehicle;
    AppLocalizations loc = AppLocalizations.of(context)!;

    if (vehicle == null) {
      return Text(loc.noVehicleSelected);
    }

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.airport_shuttle,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            size: 34,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TripChip(
                    icon: Icons.attach_money_rounded,
                    label:
                        "${formatCurrency(amount: draft.selectedVehicle!.pricePerKm, currencyCode: draft.selectedVehicle!.currency, context: context, decimalDigits: 0)} /km",
                  ),
                  _TripChip(
                    icon: Icons.event_seat_outlined,
                    label: loc.seatsCount(draft.selectedVehicle!.capacity),
                  ),
                ],
              ),

              // const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _PassengerReview extends StatelessWidget {
  const _PassengerReview({required this.draft});
  final ShuttleDraft draft;

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final passenger = draft.passenger;

    if (passenger == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _ReviewRow(loc.name, passenger.fullName),

        _ReviewRow(loc.phone, passenger.phoneNumber),

        if (passenger.email.trim().isNotEmpty)
          _ReviewRow(loc.email, passenger.email),
      ],
    );
  }
}

class _SpecialRequestReview extends StatelessWidget {
  const _SpecialRequestReview({required this.request});

  final String request;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: 0.06)
            : Colors.orange.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(request, style: const TextStyle(height: 1.5, fontSize: 15)),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({required this.draft});

  final ShuttleDraft draft;

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.estimatedTotal,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),

                SizedBox(height: 8),

                Text(
                  loc.includesYourSelectedVehicle,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            formatCurrency(
              amount: draft.totalPrice,
              currencyCode: draft.selectedVehicle?.currency ?? 'TRY',
              context: context,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueToPaymentButton extends StatelessWidget {
  const _ContinueToPaymentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.border.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          icon: const Icon(Icons.payments_outlined),
          label: Text(
            "${loc.continueToPayment} (4/5)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
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
