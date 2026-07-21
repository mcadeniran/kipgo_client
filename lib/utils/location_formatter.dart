import 'package:kipgo/models/shuttle_location.dart';

class LocationFormatter {
  static String title(ShuttleLocation location) {
    if (location.displayName.isNotEmpty) {
      return location.displayName;
    }

    return location.address;
  }

  static String subtitle(ShuttleLocation location) {
    if (location.district != null) {
      return "${location.district} • ${location.serviceArea}";
    }

    return location.serviceArea;
  }
}
