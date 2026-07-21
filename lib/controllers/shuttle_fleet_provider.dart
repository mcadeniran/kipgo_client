import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_fleet_vehicle.dart';

import '../repositories/shuttle_fleet_repository.dart';

class ShuttleFleetProvider extends ChangeNotifier {
  final _repository = ShuttleFleetRepository.instance;

  bool _loading = false;

  bool get loading => _loading;

  List<ShuttleFleetVehicle> _vehicles = [];

  List<ShuttleFleetVehicle> get vehicles => _vehicles;

  List<ShuttleFleetVehicle> vehiclesForPassengers(int passengers) {
    return _vehicles
        .where((vehicle) => vehicle.capacity >= passengers)
        .toList();
  }

  Future<void> loadFleet() async {
    if (_vehicles.isNotEmpty) return;

    _loading = true;
    notifyListeners();

    try {
      _vehicles = await _repository.getFleet();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
