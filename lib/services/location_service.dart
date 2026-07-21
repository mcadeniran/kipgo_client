import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kipgo/models/place_prediction.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/services/service_area_resolver.dart';

class LocationService {
  LocationService._();

  static final instance = LocationService._();

  final Dio _dio = Dio();

  static const _base = "https://places.googleapis.com/v1";

  final _apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<List<PlacePrediction>> autocomplete(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _dio.post(
      "$_base/places:autocomplete",
      options: Options(
        headers: {
          "X-Goog-Api-Key": _apiKey,

          "X-Goog-FieldMask":
              "suggestions.placePrediction.placeId,"
              "suggestions.placePrediction.text,"
              "suggestions.placePrediction.structuredFormat",
        },
      ),
      data: jsonEncode({
        "input": query,
        "includedRegionCodes": ["cy"],
      }),
    );

    final suggestions = response.data["suggestions"] as List;

    return suggestions.map((e) => PlacePrediction.fromJson(e)).toList();
  }

  Future<ShuttleLocation> getDetails(String placeId) async {
    final response = await _dio.get(
      "$_base/places/$placeId",
      options: Options(
        headers: {
          "X-Goog-Api-Key": _apiKey,
          "X-Goog-FieldMask":
              "id,displayName,"
              "formattedAddress,"
              "location,"
              "addressComponents",
        },
      ),
    );

    final place = response.data;

    debugPrint("FROM SEARCH");
    debugPrint(place["displayName"]?["text"]);

    return _parsePlace(place);
  }

  String? _component(List<Map<String, dynamic>> components, String type) {
    for (final component in components) {
      final types = List<String>.from(component["types"] ?? const []);

      if (types.contains(type)) {
        return component["longText"] as String?;
      }
    }

    return null;
  }

  // String _countryFromAddress(String address) {
  //   final parts = address.split(',');

  //   if (parts.isEmpty) return "";

  //   return parts.last.trim();
  // }

  // Future<ShuttleLocation?> getCurrentLocation() async {
  //   var permission = await Geolocator.checkPermission();

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }

  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     return null;
  //   }

  //   final position = await Geolocator.getCurrentPosition();

  //   final placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );

  //   final place = placemarks.first;

  //   return ShuttleLocation(
  //     placeId: "current",
  //     displayName: "${place.street}, ${place.locality}",
  //     address: "${place.street}, ${place.locality}",
  //     city: place.locality ?? "",
  //     serviceArea: ServiceAreaResolver.resolve(
  //       city: place.locality ?? "",
  //       district: place.subAdministrativeArea,
  //     ),
  //     district: place.subAdministrativeArea,
  //     country: place.country ?? "",
  //     latitude: position.latitude,
  //     longitude: position.longitude,
  //   );
  // }

  Future<ShuttleLocation?> getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();

    return reverseGeocode(position.latitude, position.longitude);
  }

  Future<ShuttleLocation?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        return _parsePlacemark(placemarks.first, latitude, longitude);
      }
    } catch (e) {
      debugPrint("Placemark failed: $e");
    }

    // Fallback to Google Places
    try {
      final response = await _dio.post(
        "$_base/places:searchNearby",
        options: Options(
          headers: {
            "X-Goog-Api-Key": _apiKey,
            "X-Goog-FieldMask":
                "places.id,"
                "places.displayName,"
                "places.formattedAddress,"
                "places.location,"
                "places.addressComponents",
          },
        ),
        data: {
          "maxResultCount": 1,
          "locationRestriction": {
            "circle": {
              "center": {"latitude": latitude, "longitude": longitude},
              "radius": 50,
            },
          },
        },
      );

      final places = response.data["places"];

      if (places != null && places is List && places.isNotEmpty) {
        return _parsePlace(Map<String, dynamic>.from(places.first));
      }
    } catch (e) {
      debugPrint("Nearby Search failed: $e");
    }

    return ShuttleLocation(
      placeId: "$latitude,$longitude",
      displayName: "Pinned Location",
      address:
          "${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}",
      city: "",
      district: null,
      country: "",
      serviceArea: "",
      latitude: latitude,
      longitude: longitude,
    );
  }

  ShuttleLocation _parsePlacemark(
    Placemark place,
    double latitude,
    double longitude,
  ) {
    final city = place.locality ?? place.subAdministrativeArea ?? "";

    final district = place.subLocality ?? place.subAdministrativeArea;

    final serviceArea = ServiceAreaResolver.resolve(
      city: city,
      district: district,
    );

    final address = [
      place.street,
      place.subLocality,
      place.locality,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return ShuttleLocation(
      placeId: "$latitude,$longitude",

      displayName: place.name ?? city,

      address: address,

      city: city,

      district: district,

      country: place.country ?? "Northern Cyprus",

      serviceArea: serviceArea,

      latitude: latitude,

      longitude: longitude,
    );
  }

  // Future<ShuttleLocation?> reverseGeocode(
  //   double latitude,
  //   double longitude,
  // ) async {
  //   final response = await _dio.post(
  //     "$_base/places:searchNearby",
  //     options: Options(
  //       headers: {
  //         "X-Goog-Api-Key": _apiKey,
  //         "X-Goog-FieldMask":
  //             "places.id,"
  //             "places.displayName,"
  //             "places.formattedAddress,"
  //             "places.location,"
  //             "places.addressComponents",
  //       },
  //     ),
  //     data: {
  //       "maxResultCount": 1,
  //       "locationRestriction": {
  //         "circle": {
  //           "center": {"latitude": latitude, "longitude": longitude},
  //           "radius": 30.0,
  //         },
  //       },
  //     },
  //   );

  //   debugPrint("Nearby Search Response:");
  //   debugPrint(response.data.toString());

  //   final places = response.data["places"];

  //   if (places == null || places is! List || places.isEmpty) {
  //     return null;
  //   }

  //   return _parsePlace(Map<String, dynamic>.from(places.first));

  //   // if (places.isEmpty) {
  //   //   return null;
  //   // }

  //   // return _parsePlace(places.first);
  // }

  ShuttleLocation _parsePlace(Map<String, dynamic> place) {
    final components = List<Map<String, dynamic>>.from(
      place["addressComponents"] as List,
    );

    final city =
        _component(components, "locality") ??
        _component(components, "postal_town") ??
        _component(components, "administrative_area_level_2") ??
        _component(components, "administrative_area_level_1") ??
        "";

    final district =
        _component(components, "sublocality_level_1") ??
        _component(components, "sublocality") ??
        _component(components, "administrative_area_level_2");

    final serviceArea = ServiceAreaResolver.resolve(
      city: city,
      district: district,
    );

    // final address = _buildAddress(components);
    // final country =
    //     _component(components, "country") ??
    //     _countryFromAddress(place["formattedAddress"]);

    final location = ShuttleLocation(
      placeId: place["id"] ?? "",
      displayName: place["displayName"]?["text"] ?? "",
      // address: address,
      address: place["formattedAddress"] ?? "",
      city: city,
      district: district,
      country: _normalizeCountry(_component(components, "country")),
      serviceArea: serviceArea,
      latitude: (place["location"]["latitude"] as num).toDouble(),
      longitude: (place["location"]["longitude"] as num).toDouble(),
    );

    debugPrint("IN _PARSEPLACE");

    debugPrint("CITY = ${location.city}");
    debugPrint("DISTRICT = ${location.district}");
    debugPrint("COUNTRY = ${location.country}");
    debugPrint("Address = ${location.country}");

    return location;
  }

  String _normalizeCountry(String? country) {
    if (country == null || country.isEmpty) {
      return "Northern Cyprus";
    }

    if (country == "Cyprus") {
      return "Northern Cyprus";
    }

    return country;
  }

  // String _buildAddress(List<Map<String, dynamic>> components) {
  //   final street = _component(components, "route");

  //   final number = _component(components, "street_number");

  //   final locality = _component(components, "locality");

  //   return [
  //     number,
  //     street,
  //     locality,
  //   ].where((e) => e != null && e.isNotEmpty).join(", ");
  // }
}
