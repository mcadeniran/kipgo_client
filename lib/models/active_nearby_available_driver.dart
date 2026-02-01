class ActiveNearbyAvailableDriver {
  String? driverId;
  double? locationLatitude;
  double? locationLongitude;

  double? distanceToPickupKm;
  double? roadDistanceKm;
  double? etaMinutes;

  ActiveNearbyAvailableDriver({
    this.driverId,
    this.locationLatitude,
    this.locationLongitude,
    this.distanceToPickupKm,
    this.roadDistanceKm,
    this.etaMinutes,
  });
}
