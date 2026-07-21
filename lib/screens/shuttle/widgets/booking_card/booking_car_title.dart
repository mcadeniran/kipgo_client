import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class BookingCardTitle extends StatelessWidget {
  const BookingCardTitle({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          loc.charterRequest,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          loc.planYourGroupsJourney,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
