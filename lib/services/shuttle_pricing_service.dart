import 'package:kipgo/models/pricing_model.dart';
import 'package:kipgo/models/shuttle_location.dart';

class ShuttlePricingService {
  ShuttlePricingService._();

  static final instance = ShuttlePricingService._();

  final List<ShuttlePrice> _prices = const [
    ShuttlePrice(fromCity: "Girne", toCity: "Lefkoşa", amount: 1800),
    ShuttlePrice(fromCity: "Girne", toCity: "Gazimağusa", amount: 2300),
    ShuttlePrice(fromCity: "Lefkoşa", toCity: "Girne", amount: 1800),
    ShuttlePrice(fromCity: "Ercan", toCity: "Girne", amount: 1500),
    ShuttlePrice(fromCity: "Ercan", toCity: "Gazimağusa", amount: 1700),
  ];

  double? estimatePrice(ShuttleLocation? pickup, ShuttleLocation? destination) {
    if (pickup == null || destination == null) {
      return null;
    }

    final match = _prices.where(
      (price) =>
          price.fromCity.toLowerCase() == pickup.city.toLowerCase() &&
          price.toCity.toLowerCase() == destination.city.toLowerCase(),
    );

    if (match.isEmpty) {
      return null;
    }

    return match.first.amount;
  }
}
