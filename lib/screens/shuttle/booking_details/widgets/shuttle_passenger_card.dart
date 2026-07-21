import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttlePassengerCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttlePassengerCard({super.key, required this.booking});

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
                  Icons.person_outline,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  loc.passenger,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _DetailTile(
              icon: Icons.badge_outlined,
              title: loc.contactName,
              value: booking.passenger.fullName,
            ),

            const SizedBox(height: 18),

            _DetailTile(
              icon: Icons.phone_outlined,
              title: loc.contactPhone,
              value: booking.passenger.phoneNumber,
            ),

            const SizedBox(height: 18),

            _DetailTile(
              icon: Icons.email_outlined,
              title: loc.contactEmail,
              value: booking.passenger.email,
            ),

            const SizedBox(height: 18),

            _DetailTile(
              icon: Icons.people_outline,
              title: loc.passengers,
              value: loc.passengersCount(booking.passengers),
            ),

            if (booking.specialRequest.trim().isNotEmpty) ...[
              Divider(
                height: 30,
                color: isDark
                    ? AppColors.border.withValues(alpha: 0.4)
                    : AppColors.border,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkLayer.withValues(alpha: 0.2)
                      : AppColors.lightAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_outlined,
                          color: isDark
                              ? AppColors.lightLayer
                              : AppColors.primary,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          loc.specialRequest,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      booking.specialRequest,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkLayer.withValues(alpha: 0.08)
                : AppColors.lightAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.darkLayer : AppColors.primary,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              SelectableText(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
