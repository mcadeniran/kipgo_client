import 'package:kipgo/models/car_model.dart';
import 'package:kipgo/models/rental_shop.dart';

class CarWithShop {
  final CarModel car;
  final RentalShop shop;

  CarWithShop({required this.car, required this.shop});

  // =========================
  // BASE PRICE
  // =========================
  double get basePrice => car.pricePerDay;

  // =========================
  // CHECK IF DISCOUNT ACTIVE
  // =========================
  bool get hasDiscount {
    final d = shop.discount;

    if (d == null) return false;
    if (!d.isActive) return false;

    final now = DateTime.now();

    if (d.startAt != null && now.isBefore(d.startAt!)) return false;
    if (d.endAt != null && now.isAfter(d.endAt!)) return false;

    return true;
  }

  // =========================
  // CALCULATE FINAL PRICE
  // =========================
  double get finalPrice {
    if (!hasDiscount) return basePrice;

    final d = shop.discount!;

    if (d.type == "percentage") {
      final discountAmount = basePrice * (d.value / 100);
      return (basePrice - discountAmount).clamp(0, double.infinity);
    }

    if (d.type == "fixed") {
      return (basePrice - d.value).clamp(0, double.infinity);
    }

    return basePrice;
  }

  // =========================
  // DISCOUNT AMOUNT
  // =========================
  double get discountAmount {
    if (!hasDiscount) return 0;

    return basePrice - finalPrice;
  }

  // =========================
  // DISCOUNT PERCENT (FOR UI)
  // =========================
  double get discountPercent {
    if (!hasDiscount) return 0;

    return ((discountAmount / basePrice) * 100);
  }

  // =========================
  // DISPLAY LABEL
  // =========================
  String get discountLabel {
    if (!hasDiscount) return "";

    final d = shop.discount!;

    if (d.type == "percentage") {
      return "-${d.value.toStringAsFixed(0)}%";
    }

    return "-${d.value.toStringAsFixed(0)}";
  }
}
