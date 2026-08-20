import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

class ShuttleDriverCard extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleDriverCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.driver == null) {
      return const _WaitingDriverCard();
    }

    final driver = booking.driver!;
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark
                      ? AppColors.lightLayer.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.08),
                  child: Text(
                    driver.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(driver.phoneNumber),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _makePhoneCall(context, driver.phoneNumber),
                    icon: const Icon(Icons.call),
                    label: Text(loc.call),
                  ),
                ),

                // const SizedBox(width: 12),

                // Expanded(
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       // Phase 10
                //     },
                //     icon: const Icon(Icons.chat_bubble_outline),
                //     label: Text(loc.message),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingDriverCard extends StatelessWidget {
  const _WaitingDriverCard();

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.person_search,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),

            SizedBox(width: 12),

            Expanded(child: Text(loc.yourDriverWillAppearHere)),
          ],
        ),
      ),
    );
  }
}
