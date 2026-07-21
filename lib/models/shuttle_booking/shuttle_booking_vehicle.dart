class ShuttleBookingVehicle {
  final String id;

  final String plateNumber;

  final String brand;

  final String model;

  final int year;

  final String color;

  final String image;

  final int seats;

  final int capacity;

  const ShuttleBookingVehicle({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.image,
    required this.seats,
    required this.capacity,
  });

  String get fullName => "$brand $model";

  factory ShuttleBookingVehicle.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShuttleBookingVehicle.empty();
    }

    return ShuttleBookingVehicle(
      id: map['id'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      color: map['color'] ?? '',
      image: map['image'] ?? '',
      seats: map['seats'] ?? 0,
      capacity: map['capacity'] ?? 0,
    );
  }

  factory ShuttleBookingVehicle.empty() {
    return const ShuttleBookingVehicle(
      id: '',
      plateNumber: '',
      brand: '',
      model: '',
      year: 0,
      color: '',
      image: '',
      seats: 0,
      capacity: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'image': image,
      'seats': seats,
      'capacity': capacity,
    };
  }

  ShuttleBookingVehicle copyWith({
    String? id,
    String? plateNumber,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? image,
    int? seats,
    int? capacity,
  }) {
    return ShuttleBookingVehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      image: image ?? this.image,
      seats: seats ?? this.seats,
      capacity: capacity ?? this.capacity,
    );
  }
}
