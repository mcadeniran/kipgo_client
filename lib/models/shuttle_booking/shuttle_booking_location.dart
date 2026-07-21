import 'package:cloud_firestore/cloud_firestore.dart';

class ShuttleBookingLocation {
  final double latitude;
  final double longitude;
  final String? placeId;

  const ShuttleBookingLocation({
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  factory ShuttleBookingLocation.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ShuttleBookingLocation(latitude: 0, longitude: 0);
    }

    return ShuttleBookingLocation(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      placeId: map['placeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'placeId': placeId};
  }

  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);

  factory ShuttleBookingLocation.fromGeoPoint(
    GeoPoint point, {
    String? placeId,
  }) {
    return ShuttleBookingLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      placeId: placeId,
    );
  }

  ShuttleBookingLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    return ShuttleBookingLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
    );
  }
}
