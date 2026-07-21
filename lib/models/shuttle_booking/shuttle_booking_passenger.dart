class ShuttleBookingPassenger {
  final String id;

  final String fullName;

  final String phoneNumber;

  final String email;

  const ShuttleBookingPassenger({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  factory ShuttleBookingPassenger.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingPassenger.empty();
    }

    return ShuttleBookingPassenger(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
    );
  }

  factory ShuttleBookingPassenger.empty() {
    return const ShuttleBookingPassenger(
      id: '',
      fullName: '',
      phoneNumber: '',
      email: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  ShuttleBookingPassenger copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
  }) {
    return ShuttleBookingPassenger(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}
