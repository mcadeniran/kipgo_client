import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation {
  LatLng? originLatLng;
  LatLng? destinationLatLng;

  String? originAddress;
  String? destinationAddress;

  String? rideRequestId;
  String? username;
  String? userPhone;
  String? userId;

  double? driverDistanceKm;
  int? driverEtaMin;

  double? tripDistanceKm;
  int? tripDurationMin;

  UserRideRequestInformation({
    this.destinationAddress,
    this.destinationLatLng,
    this.originAddress,
    this.originLatLng,
    this.rideRequestId,
    this.userPhone,
    this.username,
    this.userId,
    this.driverDistanceKm,
    this.driverEtaMin,
    this.tripDistanceKm,
    this.tripDurationMin,
  });

  factory UserRideRequestInformation.fromRealtime(
    String rideRequestId,
    Map<dynamic, dynamic> data,
    String currentDriverId,
  ) {
    // ---------------------------------------------------------
    // Safely convert RTDB nested maps
    // ---------------------------------------------------------

    Map<String, dynamic> toMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(
          value.map((key, value) => MapEntry(key.toString(), value)),
        );
      }

      return {};
    }

    // ---------------------------------------------------------
    // Safely parse numbers
    // ---------------------------------------------------------

    double? parseDouble(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      final number = parseDouble(value);

      if (number == null) {
        return null;
      }

      return number.round();
    }

    // ---------------------------------------------------------
    // Origin
    // ---------------------------------------------------------

    final origin = toMap(data['origin']);

    final originLatitude = parseDouble(origin['latitude']);

    final originLongitude = parseDouble(origin['longitude']);

    LatLng? originLatLng;

    if (originLatitude != null && originLongitude != null) {
      originLatLng = LatLng(originLatitude, originLongitude);
    }

    // ---------------------------------------------------------
    // Destination
    // ---------------------------------------------------------

    final destination = toMap(data['destination']);

    final destinationLatitude = parseDouble(destination['latitude']);

    final destinationLongitude = parseDouble(destination['longitude']);

    LatLng? destinationLatLng;

    if (destinationLatitude != null && destinationLongitude != null) {
      destinationLatLng = LatLng(destinationLatitude, destinationLongitude);
    }

    // ---------------------------------------------------------
    // Driver estimates
    // ---------------------------------------------------------

    final driverEstimates = toMap(data['driverEstimates']);

    final driverDistanceKm = parseDouble(driverEstimates['distanceKm']);

    final driverEtaMin = parseInt(driverEstimates['etaMin']);

    // ---------------------------------------------------------
    // Trip estimates
    // ---------------------------------------------------------

    final tripEstimates = toMap(data['tripEstimates']);

    // IMPORTANT:
    //
    // distanceKm = trip distance
    // durationMin = trip duration
    //
    final tripDistanceKm = parseDouble(tripEstimates['distanceKm']);

    final tripDurationMin = parseInt(tripEstimates['durationMin']);

    // ---------------------------------------------------------
    // Debugging
    // ---------------------------------------------------------

    print('🚕 Parsing ride request: $rideRequestId');

    print('📍 Origin: $originLatitude, $originLongitude');

    print(
      '📍 Destination: '
      '$destinationLatitude, $destinationLongitude',
    );

    print('📏 Driver distance: $driverDistanceKm km');

    print('⏱️ Driver ETA: $driverEtaMin min');

    print('📏 Trip distance: $tripDistanceKm km');

    print('⏱️ Trip duration: $tripDurationMin min');

    // ---------------------------------------------------------
    // Return
    // ---------------------------------------------------------

    return UserRideRequestInformation(
      rideRequestId: rideRequestId,

      originLatLng: originLatLng,

      destinationLatLng: destinationLatLng,

      originAddress: data['originAddress']?.toString(),

      destinationAddress: data['destinationAddress']?.toString(),

      username: data['username']?.toString(),

      userPhone: data['userPhone']?.toString(),

      userId: data['userId']?.toString(),

      driverDistanceKm: driverDistanceKm,

      driverEtaMin: driverEtaMin,

      tripDistanceKm: tripDistanceKm,

      tripDurationMin: tripDurationMin,
    );
  }
}

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class UserRideRequestInformation {
//   LatLng? originLatLng;
//   LatLng? destinationLatLng;
//   String? originAddress;
//   String? destinationAddress;
//   String? rideRequestId;
//   String? username;
//   String? userPhone;
//   String? userId;
//   double? driverDistanceKm;
//   int? driverEtaMin;
//   double? tripDistanceKm;
//   int? tripDurationMin;

//   UserRideRequestInformation({
//     this.destinationAddress,
//     this.destinationLatLng,
//     this.originAddress,
//     this.originLatLng,
//     this.rideRequestId,
//     this.userPhone,
//     this.username,
//     this.userId,
//     this.driverDistanceKm,
//     this.driverEtaMin,
//     this.tripDistanceKm,
//     this.tripDurationMin,
//   });

//   factory UserRideRequestInformation.fromRealtime(
//     String rideRequestId,
//     Map<dynamic, dynamic> data,
//     String currentDriverId,
//   ) {
//     return UserRideRequestInformation(
//       rideRequestId: rideRequestId,
//       originLatLng: LatLng(
//         double.parse(data['origin']['latitude'].toString()),
//         double.parse(data['origin']['longitude'].toString()),
//       ),
//       destinationLatLng: LatLng(
//         double.parse(data['destination']['latitude'].toString()),
//         double.parse(data['destination']['longitude'].toString()),
//       ),
//       originAddress: data['originAddress']?.toString(),
//       destinationAddress: data['destinationAddress']?.toString(),
//       username: data['username']?.toString(),
//       userPhone: data['userPhone']?.toString(),
//       userId: data['userId']?.toString(),

//       driverDistanceKm: (data['driverEstimates']['distanceKm'] as num)
//           .toDouble(),
//       driverEtaMin: (data['driverEstimates']['etaMin'] as num).round(),
//       tripDistanceKm: (data['tripEstimates']['durationMin'] as num).toDouble(),
//       tripDurationMin: (data['tripEstimates']['distanceKm'] as num).round(),
//     );
//   }
// }
