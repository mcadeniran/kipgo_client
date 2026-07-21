import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_vehicle.dart';

@immutable
class ShuttleFleetVehicle {
  final String id;

  final String name;

  final int capacity;

  final double pricePerKm;

  final String currency;

  final bool active;

  final int displayOrder;

  final String? image;

  final String? description;

  const ShuttleFleetVehicle({
    required this.id,
    required this.name,
    required this.capacity,
    required this.pricePerKm,
    required this.currency,
    required this.active,
    required this.displayOrder,
    this.image,
    this.description,
  });

  factory ShuttleFleetVehicle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ShuttleFleetVehicle(
      id: doc.id,
      name: data["name"] ?? "",
      capacity: data["capacity"] ?? 0,
      pricePerKm: (data["pricePerKm"] ?? 0).toDouble(),
      currency: data["currency"] ?? "TRY",
      active: data["active"] ?? true,
      displayOrder: data["displayOrder"] ?? 0,
      image: data["image"],
      description: data["description"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "capacity": capacity,
      "pricePerKm": pricePerKm,
      "currency": currency,
      "active": active,
      "displayOrder": displayOrder,
      "image": image,
      "description": description,
    };
  }

  ShuttleBookingVehicle toBookingVehicle() {
    return ShuttleBookingVehicle(
      id: id,
      plateNumber: '',
      brand: name,
      model: name,
      year: 2020,
      color: '',
      image: '',
      seats: capacity,
      capacity: capacity,
    );
  }
}
