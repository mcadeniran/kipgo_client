import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_fleet_vehicle.dart';

class ShuttleFleetRepository {
  ShuttleFleetRepository._();

  static final instance = ShuttleFleetRepository._();

  final _fleet = FirebaseFirestore.instance.collection("shuttleFleet");

  Future<List<ShuttleFleetVehicle>> getFleet() async {
    final snapshot = await _fleet
        .where("active", isEqualTo: true)
        .orderBy("displayOrder")
        .get();

    return snapshot.docs
        .map((doc) => ShuttleFleetVehicle.fromFirestore(doc))
        .toList();
  }
}
