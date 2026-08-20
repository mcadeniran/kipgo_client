import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleBookingHeader extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleBookingHeader({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLocalizations loc = AppLocalizations.of(context)!;

    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat("EEE, d MMM yyyy", '$locale').format(date);
    }

    String formatTime(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('hh:mm a', '$locale').format(date);
    }

    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
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
                BookingStatusBadge(status: booking.status.name),

                const Spacer(),

                if (booking.roundTrip)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      loc.roundTrip,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              booking.bookingNumber,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              loc.bookedShuttleService,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: loc.departure,
                    value: formatDate(context, booking.departureDate),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _InfoTile(
                    icon: Icons.schedule,
                    title: loc.time,
                    value: formatTime(context, booking.departureDate),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.payments_outlined,
                    title: loc.total,
                    value: formatCurrency(
                      amount: booking.total,
                      currencyCode: booking.currency,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.people_alt_outlined,
                    title: loc.passengers,
                    value: booking.passengers.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: const EdgeInsets.all(14),
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

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
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
