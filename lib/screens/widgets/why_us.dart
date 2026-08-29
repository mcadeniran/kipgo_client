import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class WhyUs extends StatelessWidget {
  const WhyUs({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _whyUsTile(
            loc.safeAndSecure,
            loc.yourSafety,
            Ph.shield_check,
            isDark,
          ),
          Divider(
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            thickness: 0.2,
          ),
          _whyUsTile(
            loc.bestPriceGuarantee,
            loc.getTheBestValue,
            Ph.tag,
            isDark,
          ),
          Divider(
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            thickness: 0.2,
          ),
          _whyUsTile(
            loc.flexibleBooking,
            loc.freeCancellation,
            Ph.calendar_check,
            isDark,
          ),
          Divider(
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            thickness: 0.2,
          ),
          _whyUsTile(
            loc.trustedByThousands,
            loc.joinThousands,
            Ph.users,
            isDark,
          ),
        ],
      ),
    );
  }
}

Widget _whyUsTile(String title, String details, String icon, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: isDark
              ? AppColors.lightLayer.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: .08),
          child: Iconify(
            icon,
            size: 26,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
