enum ShuttleDriverStatus { assigned, arriving, arrived, tripStarted, completed }

class ShuttleBookingDriver {
  final String id;

  final String fullName;

  final String phoneNumber;

  final String email;

  final String photo;

  final double rating;

  const ShuttleBookingDriver({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.photo,
    required this.rating,
  });

  factory ShuttleBookingDriver.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingDriver.empty();
    }

    return ShuttleBookingDriver(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  factory ShuttleBookingDriver.empty() {
    return const ShuttleBookingDriver(
      id: '',
      fullName: '',
      phoneNumber: '',
      email: '',
      photo: '',
      rating: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'photo': photo,
      'rating': rating,
    };
  }

  ShuttleBookingDriver copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? photo,
    double? rating,
  }) {
    return ShuttleBookingDriver(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      rating: rating ?? this.rating,
    );
  }
}
