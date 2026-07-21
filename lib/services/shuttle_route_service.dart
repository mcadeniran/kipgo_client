import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kipgo/models/shuttle_booking/shuttle_route_result.dart';

import '../models/shuttle_location.dart';

class ShuttleRouteService {
  ShuttleRouteService._();

  static final instance = ShuttleRouteService._();

  final _apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<ShuttleRouteResult> calculateRoute({
    required ShuttleLocation origin,
    required ShuttleLocation destination,
  }) async {
    final url = Uri.parse(
      "https://routes.googleapis.com/directions/v2:computeRoutes",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": _apiKey!,
        "X-Goog-FieldMask": "routes.distanceMeters,routes.duration",
      },
      body: jsonEncode({
        "origin": {
          "location": {
            "latLng": {
              "latitude": origin.latitude,
              "longitude": origin.longitude,
            },
          },
        },
        "destination": {
          "location": {
            "latLng": {
              "latitude": destination.latitude,
              "longitude": destination.longitude,
            },
          },
        },
        "travelMode": "DRIVE",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Unable to calculate route.");
    }

    final json = jsonDecode(response.body);

    final route = json["routes"][0];

    final distanceMeters = (route["distanceMeters"] as num).toDouble();

    final duration = route["duration"] as String;

    final durationMinutes = int.parse(duration.replaceAll("s", "")) ~/ 60;

    return ShuttleRouteResult(
      distanceKm: distanceMeters / 1000,
      durationMinutes: durationMinutes,
    );
  }
}
