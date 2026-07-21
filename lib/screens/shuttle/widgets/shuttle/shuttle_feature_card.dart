import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  const ShuttleFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

List<ShuttleFeature> shuttleFeatures(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
    ShuttleFeature(
      icon: Icons.verified_user_rounded,
      title: l10n.professionalDrivers,
      subtitle: l10n.professionalDriversSubtitle,
    ),
    ShuttleFeature(
      icon: Icons.airport_shuttle_rounded,
      title: l10n.modernFleet,
      subtitle: l10n.modernFleetSubtitle,
    ),
    ShuttleFeature(
      icon: Icons.schedule_rounded,
      title: l10n.alwaysOnTime,
      subtitle: l10n.alwaysOnTimeSubtitle,
    ),
    ShuttleFeature(
      icon: Icons.savings_rounded,
      title: l10n.competitivePricing,
      subtitle: l10n.competitivePricingSubtitle,
    ),
  ];
}

class ShuttleFeatureCard extends StatelessWidget {
  final ShuttleFeature feature;

  const ShuttleFeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.08),
            child: Icon(
              feature.icon,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            feature.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(feature.subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
