class ShuttleLocation {
  final String placeId;

  /// Google display name
  final String displayName;

  /// Full address
  final String address;

  /// Locality from Google
  final String city;

  /// Village / suburb
  final String? district;

  /// Always "Northern Cyprus" for this module
  final String country;

  /// Business area used by pricing
  final String serviceArea;

  final double latitude;
  final double longitude;

  const ShuttleLocation({
    required this.placeId,
    required this.displayName,
    required this.address,
    required this.city,
    this.district,
    required this.country,
    required this.serviceArea,
    required this.latitude,
    required this.longitude,
  });

  ShuttleLocation copyWith({
    String? placeId,
    String? displayName,
    String? address,
    String? city,
    String? district,
    String? country,
    String? serviceArea,
    double? latitude,
    double? longitude,
  }) {
    return ShuttleLocation(
      placeId: placeId ?? this.placeId,
      displayName: displayName ?? this.displayName,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      country: country ?? this.country,
      serviceArea: serviceArea ?? this.serviceArea,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "placeId": placeId,
      "displayName": displayName,
      "address": address,
      "city": city,
      "district": district,
      "country": country,
      "serviceArea": serviceArea,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  factory ShuttleLocation.fromMap(Map<String, dynamic> map) {
    return ShuttleLocation(
      placeId: map["placeId"] ?? "",
      displayName: map["displayName"] ?? "Unknown",
      address: map["address"] ?? "",
      city: map["city"] ?? "",
      district: map["district"],
      country: map["country"] ?? "Northern Cyprus",
      serviceArea: map["serviceArea"] ?? "",
      latitude: (map["latitude"] as num).toDouble(),
      longitude: (map["longitude"] as num).toDouble(),
    );
  }
}
