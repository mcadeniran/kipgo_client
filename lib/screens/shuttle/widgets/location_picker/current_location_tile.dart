import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CurrentLocationTile extends StatelessWidget {
  final VoidCallback onTap;

  const CurrentLocationTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ListTile(
      onTap: onTap,

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.lightLayer.withValues(alpha: .08)
              : AppColors.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.my_location,
          color: isDark ? AppColors.lightLayer : AppColors.primary,
        ),
      ),

      title: Text(
        loc.currentLocation,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Text(loc.useMyCurrentLocation),
    );
  }
}
