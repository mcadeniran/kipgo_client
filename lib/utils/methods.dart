import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/models/direction_details_info.dart';
import 'package:kipgo/utils/request_assistant.dart';

class AppMethods {
  static Future<String> searchAddressFromGeographicalCoordinates(
    Position position,
    context,
  ) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress = '';

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != 'Error fetching data. No Response' &&
        requestResponse != 'Error fetchin data.') {
      humanReadableAddress = requestResponse['results'][0]['formatted_address'];

      Direction userPickupAddress = Direction();

      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?>
  obtainOriginToDestinationDirectionDetails(
    LatLng originPosition,
    LatLng destinationPosition,
  ) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    String originToDestinationDetailsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$apiKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
      originToDestinationDetailsUrl,
    );

    // print("🛣️ Direction API URL: $originToDestinationDetailsUrl");
    // print("🛣️ Raw Response: $responseDirectionApi");

    if (responseDirectionApi == 'Error fetching data. No Response' ||
        responseDirectionApi == 'Error fetchin data.') {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.ePoints =
        responseDirectionApi['routes'][0]['overview_polyline']['points'];

    directionDetailsInfo.distanceText =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['text'];
    directionDetailsInfo.distanceValue =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['value'];

    directionDetailsInfo.durationText =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['text'];
    directionDetailsInfo.durationValue =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['value'];

    return directionDetailsInfo;
  }

  // static void pauseLiveLocationUpdates({required String userId}) {
  //   streamSubscriptionPosition!.pause();
  //   Geofire.removeLocation(userId);
  // }

  static Future<void> sendNotificationToDriverNow(
    String deviceRegistrationToken,
    String userRideRequestId,
    context,
  ) async {
    String destinationAddress = userDropOffAddress;
    String username = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.username;
    String pickupAddress = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation!.locationName!;

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendNotificationToDriver',
    );

    final response = await callable.call({
      "token": deviceRegistrationToken,
      "rideRequestId": userRideRequestId,
      "username": username,
      "pickupAddress": pickupAddress,
      "dropoffAddress": destinationAddress,
    });

    // print("Response from notification:  $response");

    if (response.data["success"] == true) {
      // print("Notification sent successfully");
    } else {
      // print("Failed to send notification");
    }
  }

  static Future<void> sendDriverArrivalNotification(
    String userId,
    String pickupAddress,
    context,
  ) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendDriverArrivalNotification',
    );

    final response = await callable.call({
      "userId": userId,
      "pickupAddress": pickupAddress,
    });

    debugPrint("Response from notification:  $response");

    if (response.data["success"] == true) {
      debugPrint("Notification sent successfully");
    } else {
      debugPrint("Failed to send notification");
    }
  }
}
