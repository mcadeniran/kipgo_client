import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AppSelectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final bool isAdmin;

  const AppSelectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final Color cardColor = isAdmin
        ? (isDark
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.06))
        : (isDark ? AppColors.darkAccent : Theme.of(context).cardColor);

    final Color iconBackgroundColor = isAdmin
        ? AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.10)
        : (isDark
              ? AppColors.lightLayer.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.08));

    final Color iconColor = isAdmin
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? AppColors.lightLayer : AppColors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isAdmin
              ? Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.35 : 0.12,
                  ),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isAdmin ? 0.07 : 0.04),
              blurRadius: isAdmin ? 16 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isAdmin ? 26 : 26,
              backgroundColor: iconBackgroundColor,
              child: Iconify(icon, size: isAdmin ? 26 : 26, color: iconColor),
            ),

            SizedBox(height: isAdmin ? 8 : 14),

            if (!isAdmin)
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isAdmin ? FontWeight.w700 : FontWeight.w600,
                ),
              ),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.28 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.adminBadge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
