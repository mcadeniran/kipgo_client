import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class BookingDateFormatter {
  static String format(BuildContext context, DateTime date) {
    final loc = AppLocalizations.of(context)!;

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return loc.today;
    }

    if (difference == 1) {
      return loc.tomorrow;
    }

    return DateFormat.yMMMEd(
      Localizations.localeOf(context).languageCode,
    ).format(date);
  }
}
