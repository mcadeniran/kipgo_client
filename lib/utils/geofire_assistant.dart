import 'package:kipgo/models/active_nearby_available_driver.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDriver> activeNearbyAvailableDriversList =
      [];

  // static void deleteOfflineDriverFromList(String driverId) {
  //   int indexNumber = activeNearbyAvailableDriversList.indexWhere(
  //     (element) => element.driverId == driverId,
  //   );

  //   activeNearbyAvailableDriversList.removeAt(indexNumber);
  // }

  static void deleteOfflineDriverFromList(String driverId) {
    int index = activeNearbyAvailableDriversList.indexWhere(
      (d) => d.driverId == driverId,
    );
    if (index != -1) {
      activeNearbyAvailableDriversList.removeAt(index);
    }
  }

  // static void updateActiveNearbyAvailableDriverLocation(
  //   ActiveNearbyAvailableDriver driverWhoMoves,
  // ) {
  //   int indexNumber = activeNearbyAvailableDriversList.indexWhere(
  //     (element) => element.driverId == driverWhoMoves.driverId,
  //   );

  //   activeNearbyAvailableDriversList[indexNumber].locationLatitude =
  //       driverWhoMoves.locationLatitude;

  //   activeNearbyAvailableDriversList[indexNumber].locationLongitude =
  //       driverWhoMoves.locationLongitude;
  // }

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

// import 'package:flutter/foundation.dart';
// import 'package:kipgo/models/active_nearby_available_driver.dart';

// class GeofireAssistant {
//   static List<ActiveNearbyAvailableDriver> activeNearbyAvailableDriversList =
//       [];

//   /// Safely delete driver from local list
//   static void deleteOfflineDriverFromList(String driverId) {
//     int indexNumber = activeNearbyAvailableDriversList.indexWhere(
//       (element) => element.driverId == driverId,
//     );

//     if (indexNumber != -1) {
//       activeNearbyAvailableDriversList.removeAt(indexNumber);
//     }
//   }

//   /// Safely update driver's location in local list
//   static void updateActiveNearbyAvailableDriverLocation(
//     ActiveNearbyAvailableDriver driverWhoMoves,
//   ) {
//     int indexNumber = activeNearbyAvailableDriversList.indexWhere(
//       (element) => element.driverId == driverWhoMoves.driverId,
//     );

//     if (indexNumber != -1) {
//       activeNearbyAvailableDriversList[indexNumber].locationLatitude =
//           driverWhoMoves.locationLatitude;
//       activeNearbyAvailableDriversList[indexNumber].locationLongitude =
//           driverWhoMoves.locationLongitude;
//     } else {
//       // Driver not found in list, ignore safely
//       if (kDebugMode) {
//         print("Driver ${driverWhoMoves.driverId} not found in nearby list.");
//         // activeNearbyAvailableDriversList.add(driverWhoMoves);
//         addDriverToNearbyList(driverWhoMoves);
//       }
//     }
//   }

//   /// Safely add a new driver if not already in list
//   static void addDriverToNearbyList(ActiveNearbyAvailableDriver driver) {
//     final exists = activeNearbyAvailableDriversList.any(
//       (element) => element.driverId == driver.driverId,
//     );
//     if (!exists) {
//       activeNearbyAvailableDriversList.add(driver);
//     }
//   }
// }
