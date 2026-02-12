import 'package:kipgo/models/active_nearby_available_driver.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDriver> activeNearbyAvailableDriversList =
      [];

  static void deleteOfflineDriverFromList(String driverId) {
    int index = activeNearbyAvailableDriversList.indexWhere(
      (d) => d.driverId == driverId,
    );
    if (index != -1) {
      activeNearbyAvailableDriversList.removeAt(index);
    }
  }

  static void updateActiveNearbyAvailableDriverLocation(
    ActiveNearbyAvailableDriver driver,
  ) {
    int index = activeNearbyAvailableDriversList.indexWhere(
      (d) => d.driverId == driver.driverId,
    );
    if (index != -1) {
      activeNearbyAvailableDriversList[index].locationLatitude =
          driver.locationLatitude;
      activeNearbyAvailableDriversList[index].locationLongitude =
          driver.locationLongitude;
    } else {
      // Add driver if missing
      activeNearbyAvailableDriversList.add(driver);
    }
  }
}
