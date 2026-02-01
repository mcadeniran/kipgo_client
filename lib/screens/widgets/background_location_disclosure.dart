import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';

Future<bool> showBackgroundLocationDisclosure(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context)!.backgroundLocationUsage,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.kipgoCollectsLocationData),
                SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.thisAllows),
                SizedBox(height: 6),
                Text(AppLocalizations.of(context)!.driversToNavigate),
                Text(AppLocalizations.of(context)!.ridersToseeLiveDriver),
                Text(AppLocalizations.of(context)!.tripsToContinue),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.locationDataIsCollectedOnly,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.pleaseGoToSettings,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.notNow),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.openSettings),
            ),
          ],
        ),
      ) ??
      false;
}
