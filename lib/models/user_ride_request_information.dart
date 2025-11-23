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

  UserRideRequestInformation({
    this.destinationAddress,
    this.destinationLatLng,
    this.originAddress,
    this.originLatLng,
    this.rideRequestId,
    this.userPhone,
    this.username,
    this.userId,
  });

  factory UserRideRequestInformation.fromRealtime(
    String rideRequestId,
    Map<dynamic, dynamic> data,
  ) {
    return UserRideRequestInformation(
      rideRequestId: rideRequestId,
      originLatLng: LatLng(
        double.parse(data['origin']['latitude'].toString()),
        double.parse(data['origin']['longitude'].toString()),
      ),
      destinationLatLng: LatLng(
        double.parse(data['destination']['latitude'].toString()),
        double.parse(data['destination']['longitude'].toString()),
      ),
      originAddress: data['originAddress']?.toString(),
      destinationAddress: data['destinationAddress']?.toString(),
      username: data['username']?.toString(),
      userPhone: data['userPhone']?.toString(),
      userId: data['userId']?.toString(),
    );
  }
}
