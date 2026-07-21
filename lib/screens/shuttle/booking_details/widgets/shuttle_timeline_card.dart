import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_event.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_item.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleTimelineCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleTimelineCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  loc.timeline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (booking.timeline.isEmpty)
              const _EmptyTimeline()
            else
              ...List.generate(booking.timeline.length, (index) {
                return _TimelineTile(
                  item: booking.timeline[index],
                  isLast: index == booking.timeline.length - 1,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final ShuttleBookingTimelineItem item;
  final bool isLast;

  const _TimelineTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = item.event.color;
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.event.icon, color: color, size: 18),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: isDark ? Colors.white70 : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    formatDate(context, item.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),

                  if ((item.note ?? "").isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lightLayer.withValues(alpha: 0.2)
                            : AppColors.lightAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(item.note!),
                    ),
                  ],

                  if (item.performedBy != null &&
                      item.performedBy!.isNotEmpty) ...[
                    const SizedBox(height: 8),

                    Text(
                      loc.byUser(item.performedBy!),

                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      width: double.infinity,
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
            Icons.history_toggle_off,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),

          SizedBox(width: 12),

          Expanded(child: Text(loc.bookingUpdatesWillAppearHere)),
        ],
      ),
    );
  }
}
