import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleRouteCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleRouteCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  loc.journey,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _LocationTile(
              title: loc.pickup,
              icon: Icons.radio_button_checked,
              location: booking.pickup.displayName,
              address: booking.pickup.address,
              color: Colors.green,
            ),

            SizedBox(height: 12),

            _LocationTile(
              title: loc.destination,
              icon: Icons.location_on,
              location: booking.destination.displayName,
              address: booking.destination.address,
              color: Colors.red,
            ),

            const Divider(height: 30),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_month,
                    title: loc.departure,
                    value: formatDate(context, booking.departureDate),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _InfoChip(
                    icon: booking.roundTrip
                        ? Icons.sync_alt
                        : Icons.arrow_forward,
                    title: loc.trip,
                    value: booking.roundTrip ? loc.roundTrip : loc.oneWay,
                  ),
                ),
              ],
            ),

            if (booking.roundTrip && booking.returnDate != null) ...[
              const SizedBox(height: 16),

              _InfoChip(
                icon: Icons.event_repeat,
                title: loc.returnString,
                value: formatDate(context, booking.returnDate!),
              ),
            ],

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkLayer.withValues(alpha: 0.2)
                    : AppColors.lightAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.serviceArea, style: theme.textTheme.bodySmall),

                        const SizedBox(height: 4),

                        Text(
                          "${booking.pickup.serviceArea} → ${booking.destination.serviceArea}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

class _LocationTile extends StatelessWidget {
  final String title;
  final String location;
  final String address;
  final IconData icon;
  final Color color;

  const _LocationTile({
    required this.title,
    required this.location,
    required this.address,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall),

              const SizedBox(height: 4),

              Text(
                location,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkLayer.withValues(alpha: 0.2)
            : AppColors.lightAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? AppColors.lightLayer : AppColors.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
