import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class ShuttleServiceItem {
  final IconData icon;
  final String title;

  const ShuttleServiceItem({required this.icon, required this.title});
}

List<ShuttleServiceItem> shuttleServices(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
    ShuttleServiceItem(icon: Icons.flight_takeoff, title: l10n.airportTransfer),
    ShuttleServiceItem(icon: Icons.business, title: l10n.corporate),
    ShuttleServiceItem(icon: Icons.school, title: l10n.schoolTrips),
    ShuttleServiceItem(icon: Icons.celebration, title: l10n.events),
    ShuttleServiceItem(icon: Icons.favorite, title: l10n.wedding),
  ];
}
// const shuttleServices = [
//   ShuttleServiceItem(icon: Icons.flight_takeoff, title: "Airport\nTransfer"),

//   ShuttleServiceItem(icon: Icons.business, title: "Corporate"),

//   ShuttleServiceItem(icon: Icons.school, title: "School\nTrips"),

//   ShuttleServiceItem(icon: Icons.celebration, title: "Events"),

//   ShuttleServiceItem(icon: Icons.favorite, title: "Wedding"),
// ];
