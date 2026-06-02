import 'package:cloud_firestore/cloud_firestore.dart';

class CarUnit {
  final String id;
  final String carId;
  final String numberPlate;
  final String colour;
  final String status; // 'available' | 'maintenance'
  final DateTime createdAt;

  CarUnit({
    required this.id,
    required this.carId,
    required this.numberPlate,
    required this.colour,
    required this.status,
    required this.createdAt,
  });

  factory CarUnit.fromMap(Map<String, dynamic> data, String id, String carId) {
    return CarUnit(
      id: id,
      carId: carId,
      numberPlate: data['numberPlate'] ?? '',
      colour: data['colour'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
