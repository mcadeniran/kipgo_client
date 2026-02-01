import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  static Future<DirectionsResult?> getRouteInfo({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=${dotenv.env['GOOGLE_API_KEY']}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['routes'].isEmpty) return null;

    final leg = data['routes'][0]['legs'][0];

    return DirectionsResult(
      distanceKm: leg['distance']['value'] / 1000.0,
      durationMin: leg['duration']['value'] / 60.0,
    );
  }
}

class DirectionsResult {
  final double distanceKm;
  final double durationMin;

  DirectionsResult({required this.distanceKm, required this.durationMin});
}
