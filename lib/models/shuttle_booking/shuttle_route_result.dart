import 'package:flutter/foundation.dart';

@immutable
class ShuttleRouteResult {
  final double distanceKm;

  final int durationMinutes;

  const ShuttleRouteResult({
    required this.distanceKm,
    required this.durationMinutes,
  });
}
