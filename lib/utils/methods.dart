import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/models/direction_details_info.dart';
import 'package:kipgo/utils/request_assistant.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

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

  static void pauseLiveLocationUpdates({required String userId}) {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(userId);
  }

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

    print("Response from notification:  $response");

    if (response.data["success"] == true) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
    }
  }

  // static void sendNotificationToDriverNow(
  //   String deviceRegistrationToken,
  //   String userRideRequestId,
  //   context,
  // ) async {
  //   String destinationAddress = userDropOffAddress;

  //   String serverAccessTokenKey = await getAccessToken();

  //   String endPointFirebasecloudMessaging =
  //       'https://fcm.googleapis.com/v1/projects/kipgo-taxi/messages:send';

  //   // Map<String, String> headerNotification = {
  //   //   'Content-Type': 'Application/json',
  //   //   'Authorization': 'Bearer $serverAccessTokenKey',
  //   // };

  //   // Map bodyNotification = {
  //   //   "body": "Destination Address: \n$destinationAddress",
  //   //   "title": "New Trip Request",
  //   // };

  //   // Map dataMap = {
  //   //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //   //   "id": "1",
  //   //   "status": "done",
  //   //   "rideRequestId": userRideRequestId,
  //   // };

  //   // Map officialNotificationFormat = {
  //   //   "notification": bodyNotification,
  //   //   "data": dataMap,
  //   //   "priority": 'high',
  //   //   "to": deviceRegistrationToken,
  //   // };

  //   // var responseNotification = await http.post(
  //   //   Uri.parse(endPointFirebasecloudMessaging),
  //   //   headers: headerNotification,
  //   //   body: jsonEncode(officialNotificationFormat),
  //   // );

  //   // print("Notification Response: ${responseNotification.body}");

  //   String username = Provider.of<ProfileProvider>(
  //     context,
  //     listen: false,
  //   ).profile!.username;
  //   String pickupAddress = Provider.of<AppInfo>(
  //     context,
  //     listen: false,
  //   ).userPickUpLocation!.locationName!;
  //   final Map<String, dynamic> message = {
  //     'message': {
  //       'token': deviceRegistrationToken,
  //       'notification': {
  //         'title': "NEW TRIP REQUEST FROM $username",
  //         'body':
  //             "Pickup Location: $pickupAddress \nDropoff Location: $userDropOffAddress",
  //       },
  //       'data': {"rideRequestId": userRideRequestId},
  //     },
  //   };

  //   final http.Response response = await http.post(
  //     Uri.parse(endPointFirebasecloudMessaging),
  //     headers: <String, String>{
  //       'Content-type': 'application/json',
  //       'Authorization': 'Bearer $serverAccessTokenKey',
  //     },
  //     body: jsonEncode(message),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Notification sent successfully');
  //   } else {
  //     print('Failed to send FCM Message: ${response.statusCode}');
  //     print("FAILED DETAILS: ${response.body}");
  //   }
  // }

  // static Future<String> getAccessToken() async {
  //   final serviceAccountJson = {
  //     "type": "service_account",
  //     "project_id": "kipgo-taxi",
  //     "private_key_id": "7b793634c6ee2e14e553698d13d8cdf70edbaf1e",
  //     "private_key":
  //         "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDN8N4DARUPtlju\n6qCpaYQWhRjkkfZLxeZCg+SpUf1PTXE2qZMiVoHABEtBduR01IXTN+xwrD1YTcRa\nTxahrMl35u4T/qSzy/74p46aNzSQ+knQ8vVuKGNSS3amYGT+K0iJof0YKP83uG4C\nd2ysIzxluK4Yr0Fw5eEeH+WkB5Zze5kLYgfh4NNw5tzK3yqs3YqDGWeO4ad9oMp0\nEB6vvW6hFc4xKCix3EquWRRobdoEKhuzeG8iWENMnaGn7csJ/Ghj83EbFzq7lJmx\npWpSDPEeiBIHwFYBdyzlMJzFktDSyqOleoumlRGHT96JBLV/4iMEChFXGUZJZ3bL\njUK7uQMxAgMBAAECggEAA4uMGYDObtekk/GjCWI2crgg070gKxwW2M9Hbj4Uk7sR\nYgUCR5A1/0BeVpv9gSCwGxDhN5andFqGW52f60bmWEjikU02uEegiyxAkVlg73FM\n4wAZByftKcYAdAsVwfsBw9NvisJt6PTPo/2P99igGgosqQ0fSG+/SShNvjNJPOdR\nsJDe9Cyp8JC1/Ciypem3Wkp5bBquu8Pr8uMhRnBGJ8daw7X6te6iPG4+RCE3YsJd\nQ2XnELGGGzJDFhejOTADrFWVglILRr9cyETvg58XA62YwvYD8jY2WhGbLoGDSO3k\nLSPzk513tUyo6Ex7DS7Tdgp1aBOoDCf/mhZ98Ag3XwKBgQD1uzvmt7IGc6V5tVeJ\niY13lcV24oimaE667zSHjc9ea+cu9UP/jA944tIT45n1uBZxTImKR/W0hvqKepkq\nWjS0BWCaNDXbU50nZmYs12KdmZb6moLnbIiUkR6gbv+rnBwItekesev5hB5GofbI\n8Hi+TMmbs7ye89LwIeKRtNEpewKBgQDWi/cw7NnLYv5SXA833HhKmIAQnOS/BkVh\nXaivsxuTnlFn9wEl8/1EEiQY50aYP20ag92BXbY41YNoyWYHVJ55od8oKOau6YEt\nnygkztPvRlNI1/qzoFr4oO3Pr47EmRYOKh8V/l6+NM4UyrcWMzxRWDrMbQBFMoyG\nfe0YwqT4QwKBgQCIJAyi3YEHLAkwrfRqoce7ykGVhRo6P63myWIr+7g40sVJcd8T\ndLCZw+ip1j5VMYFVkhbdgtKxCttB33x+R23NkvEbXfO8qM13p7bR/x6GvDI2c2Y0\n+x+MV/5E2lpR5HJvrQET3XUkTztK3K7SUtBCdl54IhNNaT6jhdJ18Vy0gwKBgGoB\nPACLdkz8u4X8AHTsVO8ejGAo9QjBU3R5L0ioqV51oelJbOLQu/lvMTCwzPuakxC/\nyKkLoWZRcJ1MrUG/+JFGfpk8JEaWDwJ4mgAdxS97QtlCBZfNCkXAVeAA8PyIWxJi\nk3ttdGhsdMpnIrEwXYQfoOWykaifAjnNbGGIgrQ7AoGBALuSmxqie1JkMLEEX5kp\nm0YQtBjhA5/DMl9J8j+J0H0j52DtAQ6/DJfZdNlPsk6ZhPQGl1q4UFuFNPCqtRzv\nrdqJMRzT/NOooD19yNFNX+IdmQTVvkSIRQNK/mIAhheQg+QuWGb6SgcSqxpyBoXw\nDlAmni6uSyXLxtSlTUpxtbhJ\n-----END PRIVATE KEY-----\n",
  //     "client_email":
  //         "firebase-adminsdk-fbsvc@kipgo-taxi.iam.gserviceaccount.com",
  //     "client_id": "112451206743846977314",
  //     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //     "token_uri": "https://oauth2.googleapis.com/token",
  //     "auth_provider_x509_cert_url":
  //         "https://www.googleapis.com/oauth2/v1/certs",
  //     "client_x509_cert_url":
  //         "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40kipgo-taxi.iam.gserviceaccount.com",
  //     "universe_domain": "googleapis.com",
  //   };

  //   List<String> scopes = [
  //     'https://www.googleapis.com/auth/userinfo.email',
  //     'https://www.googleapis.com/auth/firebase.database',
  //     'https://www.googleapis.com/auth/firebase.messaging',
  //   ];

  //   http.Client client = await auth.clientViaServiceAccount(
  //     auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
  //     scopes,
  //   );

  //   // get the access token
  //   auth.AccessCredentials credentials = await auth
  //       .obtainAccessCredentialsViaServiceAccount(
  //         auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
  //         scopes,
  //         client,
  //       );

  //   client.close();

  //   return credentials.accessToken.data;
  // }
}
