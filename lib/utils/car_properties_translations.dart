import 'package:flutter/widgets.dart';
import 'package:kipgo/l10n/app_localizations.dart';

String carPropertiesTranslations(BuildContext context, String value) {
  AppLocalizations loc = AppLocalizations.of(context)!;
  switch (value) {
    case "All":
      return loc.all;
    case "Economy":
      return loc.economy;
    case "Sedan":
      return loc.sedan;
    case "SUV":
      return loc.suv;
    case "Luxury":
      return loc.luxury;
    case "Sports":
      return loc.sports;
    case "Pickup":
      return loc.pickup;
    case "Van":
      return loc.van;
    case 'Petrol':
      return loc.petrol;
    case 'Diesel':
      return loc.diesel;
    case 'Electric':
      return loc.electric;
    case 'Hybrid':
      return loc.hybrid;
    case 'Manual':
      return loc.manual;
    case 'Automatic':
      return loc.automatic;
    case 'pickup':
      return loc.pickUp;
    case 'delivery':
      return loc.delivery;
    case 'pending':
      return loc.pending;
    case 'approved':
      return loc.approved;
    case 'ongoing':
      return loc.ongoing;
    case 'completed':
      return loc.completed;
    case 'cancelled':
      return loc.cancelled;
    case 'rejected':
      return loc.rejected;
    default:
      return loc.unknown;
  }
}
