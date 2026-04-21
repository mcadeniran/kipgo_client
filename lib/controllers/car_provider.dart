import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
// import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/utils/location_utils.dart';
import '../models/car_model.dart';
import '../repositories/car_repository.dart';

enum SortOption { priceLowToHigh, priceHighToLow, nearest, newest }

class CarProvider extends ChangeNotifier {
  final CarRepository _repository = CarRepository();

  StreamSubscription? _carsSubscription;

  RentalShopProvider? shopProvider;

  List<CarModel> _allCars = []; //  master list (cached)
  List<CarWithShop> cars = [];
  List<CarWithShop> shopCars = [];

  bool loading = false;

  bool _isListening = false;

  CarProvider();

  // =========================
  // ACTIVE FILTER STATE
  // =========================
  SortOption? sortOption;
  String? selectedCategory;
  // double? minPrice;
  // double? maxPrice;
  int? seats;
  String? fuel;
  String? transmission;
  double? userLat;
  double? userLng;
  double? radiusKm;
  String? searchQuery;

  void setShopProvider(RentalShopProvider provider) {
    shopProvider = provider;
  }

  @override
  void dispose() {
    _carsSubscription?.cancel();
    super.dispose();
  }

  // =========================
  // FETCH ALL (ONLY ONCE)
  // =========================
  void listenToCars() {
    if (_isListening) return; // 🔥 prevents duplicate listeners
    _isListening = true;
    loading = true;
    notifyListeners();

    _carsSubscription?.cancel();

    _carsSubscription = _repository.streamCars().listen((carsList) {
      _allCars = carsList;

      applyFilters(); // 🔥 VERY IMPORTANT

      loading = false;
      notifyListeners();
    });
  }

  // =========================
  // FILTER BY CATEGORY
  // =========================
  void filterByCategory(String category) {
    selectedCategory = category == "All" ? null : category;
    applyFilters();
  }

  // =========================
  // FILTER BY CITY
  // =========================
  Future<void> fetchCarsByCity(String city) async {
    loading = true;
    notifyListeners();

    applyFilters(city: city);

    loading = false;
    notifyListeners();
  }

  List<CarWithShop> get featuredCars {
    final now = DateTime.now();

    if (shopProvider == null) return [];

    final shopMap = {for (var s in shopProvider!.rentalShops) s.id: s};

    return _allCars
        .where((car) {
          final shop = shopMap[car.shopId];

          if (shop == null || !shop.isActive) return false;

          if (!car.isFeatured || car.featured == null) return false;

          final start = car.featured!.startAt;
          final end = car.featured!.endAt;

          if (start == null || end == null) return false;

          return now.isAfter(start) && now.isBefore(end);
        })
        .map((car) {
          final shop = shopMap[car.shopId]!;
          return CarWithShop(car: car, shop: shop);
        })
        .toList();
  }

  // =========================
  // FILTER BY SHOP
  // =========================
  Future<void> fetchCarsByShop(String rentalId) async {
    loading = true;
    notifyListeners();

    shopCars = [];
    List<CarModel> filtered = _allCars;
    final shopMap = {for (var s in shopProvider?.rentalShops ?? []) s.id: s};

    filtered = filtered.where((c) => c.shopId == rentalId).toList();

    shopCars = filtered.map((car) {
      final shop = shopMap[car.shopId]!;
      return CarWithShop(car: car, shop: shop);
    }).toList();

    // applyFilters(shopId: rentalId);

    loading = false;
    notifyListeners();
  }

  // =========================
  // COMBINED FILTER (OPTIONAL 🔥)
  // =========================
  void applyFilters({
    String? category,
    String? city,
    String? shopId,
    double? minPrice,
    double? maxPrice,
    int? seats,
    String? fuel,
    String? transmission,
  }) {
    selectedCategory = category ?? selectedCategory;
    // this.minPrice = minPrice ?? this.minPrice;
    // this.maxPrice = maxPrice ?? this.maxPrice;
    this.seats = seats ?? this.seats;
    this.fuel = fuel ?? this.fuel;
    this.transmission = transmission ?? this.transmission;

    List<CarModel> filtered = _allCars;

    final shopMap = {for (var s in shopProvider?.rentalShops ?? []) s.id: s};

    if (category != null && category != "All") {
      filtered = filtered.where((c) => c.carType == category).toList();
    }

    if (city != null) {
      filtered = filtered
          .where((c) => c.city.toLowerCase() == city.toLowerCase())
          .toList();
    }

    if (shopId != null) {
      filtered = filtered.where((c) => c.shopId == shopId).toList();
    }

    if (minPrice != null) {
      filtered = filtered.where((c) => c.pricePerDay >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((c) => c.pricePerDay <= maxPrice).toList();
    }

    if (seats != null) {
      filtered = filtered.where((c) => c.seats >= seats).toList();
    }

    if (fuel != null) {
      filtered = filtered.where((c) => c.fuel == fuel).toList();
    }

    if (transmission != null) {
      filtered = filtered.where((c) => c.transmission == transmission).toList();
    }

    if (userLat != null && userLng != null && radiusKm != null) {
      filtered = filtered.where((car) {
        final distance = calculateDistance(
          userLat!,
          userLng!,
          car.location.lat,
          car.location.lng,
        );

        return distance <= radiusKm!;
      }).toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase().trim();

      filtered = filtered.where((car) {
        final brand = car.brand.toLowerCase();
        final model = car.model.toLowerCase();

        return "$brand $model".contains(query);
      }).toList();
    }

    if (sortOption != null) {
      switch (sortOption!) {
        case SortOption.priceLowToHigh:
          filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
          break;

        case SortOption.priceHighToLow:
          filtered.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
          break;

        case SortOption.nearest:
          if (userLat != null && userLng != null) {
            filtered.sort((a, b) {
              final d1 = calculateDistance(
                userLat!,
                userLng!,
                a.location.lat,
                a.location.lng,
              );

              final d2 = calculateDistance(
                userLat!,
                userLng!,
                b.location.lat,
                b.location.lng,
              );

              return d1.compareTo(d2);
            });
          }
          break;

        case SortOption.newest:
          filtered.sort((a, b) => b.year.compareTo(a.year));
          break;
      }
    }

    filtered = filtered.where((car) {
      final shop = shopMap[car.shopId];
      return shop != null && shop.isActive;
    }).toList();

    cars = filtered.map((car) {
      final shop = shopMap[car.shopId]!;
      return CarWithShop(car: car, shop: shop);
    }).toList();

    // cars = enriched;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilters();
  }

  void setSortOption(SortOption? option) {
    sortOption = option;
    applyFilters();
  }

  void clearFilters() {
    selectedCategory = null;
    // minPrice = null;
    // maxPrice = null;
    seats = null;
    fuel = null;
    transmission = null;
    radiusKm = null;

    // cars = _allCars;
    applyFilters();
    notifyListeners();
  }
}
