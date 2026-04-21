import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

String getBookingTitle(BuildContext context, String status) {
  AppLocalizations loc = AppLocalizations.of(context)!;
  switch (status) {
    case 'approved':
      return loc.bookingApprovedTitle;
    case 'ongoing':
      return loc.bookingStartedTitle;
    case 'completed':
      return loc.bookingCompletedTitle;
    case 'rejected':
      return loc.bookingRejectedTitle;
    case 'cancelled':
      return loc.bookingCancelledTitle;
    default:
      return loc.bookingUnknownTitle;
  }
}

String getBookingMessage(
  BuildContext context,
  String status,
  String? shopName,
  String? carName,
) {
  AppLocalizations loc = AppLocalizations.of(context)!;
  switch (status) {
    case 'approved':
      return loc.bookingApprovedMessage(shopName ?? 'Rental', carName ?? 'Car');
    case 'ongoing':
      return loc.bookingOngoingMessage;
    case 'completed':
      return loc.bookingCompletedMessage;
    case 'rejected':
      return loc.bookingRejectedMessage;
    case 'cancelled':
      return loc.bookingCancelledMessage;
    default:
      return loc.bookingUnknownMessage;
  }
}
