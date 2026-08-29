import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import '../models/car_model.dart';
import '../repositories/car_repository.dart';

enum SortOption { priceLowToHigh, priceHighToLow, newest }

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
  // double? userLat;
  // double? userLng;
  // double? radiusKm;
  String? searchQuery;
  String? currentShopId;

  List<CarWithShop> _popularCars = [];
  bool _loadingPopularCars = false;

  List<CarWithShop> get popularCars => _popularCars;

  bool get loadingPopularCars => _loadingPopularCars;

  bool _popularCarsLoaded = false;

  void setShopProvider(RentalShopProvider provider) {
    shopProvider = provider;

    if (_allCars.isNotEmpty && !_popularCarsLoaded) {
      _popularCarsLoaded = true;
      loadPopularCars();
    }
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

      if (shopProvider != null && !_popularCarsLoaded) {
        _popularCarsLoaded = true;
        loadPopularCars();
      }
    });
  }

  // =========================
  // FILTER BY CATEGORY
  // =========================
  void filterByCategory(String category) {
    selectedCategory = category == "All" ? null : category;
    applyFilters(category: category == "All" ? null : category);
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

  void setCurrentShop(String shopId) {
    currentShopId = shopId;
    notifyListeners();
  }

  List<CarModel> get myCars {
    if (currentShopId == null) return [];

    return _allCars.where((c) => c.shopId == currentShopId).toList();
  }

  int get totalCars => myCars.length;

  int get totalUnits => myCars.fold(0, (sum, car) => sum + car.totalUnits);

  int get availableUnits =>
      myCars.fold(0, (sum, car) => sum + car.availableUnits);

  double get averageRating {
    if (myCars.isEmpty) return 0;

    final total = myCars.fold(0.0, (sum, c) => sum + c.review.average);
    return total / myCars.length;
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

  Future<Map<String, int>> _getCompletedBookingCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'completed')
        .get();

    final counts = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final carId = data['carId'] as String?;

      if (carId == null || carId.isEmpty) {
        continue;
      }

      counts[carId] = (counts[carId] ?? 0) + 1;
    }

    return counts;
  }

  Future<void> loadPopularCars() async {
    if (shopProvider == null) {
      _popularCars = [];
      return;
    }

    if (_allCars.isEmpty) {
      _popularCars = [];
      return;
    }

    _loadingPopularCars = true;
    notifyListeners();

    try {
      final bookingCounts = await _getCompletedBookingCounts();

      _popularCars = _buildPopularCars(bookingCounts);
    } catch (e) {
      debugPrint('Error loading popular cars: $e');

      // If Firestore fails, don't break the home page.
      // Fall back to the original first 5 cars.
      _popularCars = _getFallbackPopularCars();
    } finally {
      _loadingPopularCars = false;
      notifyListeners();
    }
  }

  List<CarWithShop> _getFallbackPopularCars() {
    if (shopProvider == null) {
      return [];
    }

    final shopMap = {
      for (final shop in shopProvider!.rentalShops) shop.id: shop,
    };

    return _allCars
        .map((car) {
          final shop = shopMap[car.shopId];

          if (shop == null || !shop.isActive) {
            return null;
          }

          return CarWithShop(car: car, shop: shop);
        })
        .whereType<CarWithShop>()
        .take(5)
        .toList();
  }

  double _calculatePopularityScore({
    required CarModel car,
    required int completedBookings,
    required int maxCompletedBookings,
  }) {
    // ------------------------------------------------------------
    // 1. COMPLETED BOOKINGS — 65%
    // ------------------------------------------------------------

    double bookingScore = 0;

    if (maxCompletedBookings > 0 && completedBookings > 0) {
      bookingScore =
          math.log(completedBookings + 1) / math.log(maxCompletedBookings + 1);
    }

    // ------------------------------------------------------------
    // 2. REVIEW QUALITY — 20%
    // ------------------------------------------------------------

    double reviewScore = 0;

    if (car.review.totalReviews > 0) {
      final ratingScore = (car.review.average / 5).clamp(0.0, 1.0);

      final reviewConfidence = 1 - math.exp(-car.review.totalReviews / 10);

      reviewScore = ratingScore * reviewConfidence;
    }

    // ------------------------------------------------------------
    // 3. RECOMMENDATION RATE — 15%
    // ------------------------------------------------------------

    double recommendationScore = 0;

    if (car.review.totalReviews > 0) {
      recommendationScore = (car.review.recommendationRate / 100).clamp(
        0.0,
        1.0,
      );
    }

    // ------------------------------------------------------------
    // FINAL SCORE
    // ------------------------------------------------------------

    return (bookingScore * 0.65) +
        (reviewScore * 0.20) +
        (recommendationScore * 0.15);
  }

  List<CarWithShop> _buildPopularCars(Map<String, int> bookingCounts) {
    if (shopProvider == null) {
      return [];
    }

    final shopMap = {
      for (final shop in shopProvider!.rentalShops) shop.id: shop,
    };

    final availableCars = _allCars
        .map((car) {
          final shop = shopMap[car.shopId];

          if (shop == null || !shop.isActive) {
            return null;
          }

          return CarWithShop(car: car, shop: shop);
        })
        .whereType<CarWithShop>()
        .toList();

    if (availableCars.isEmpty) {
      return [];
    }

    // ------------------------------------------------------------
    // No completed bookings yet.
    //
    // The rental module is still new, so use the original
    // ordering as the fallback.
    // ------------------------------------------------------------

    final hasAnyCompletedBookings = availableCars.any(
      (item) => (bookingCounts[item.car.id] ?? 0) > 0,
    );

    if (!hasAnyCompletedBookings) {
      return availableCars.take(5).toList();
    }

    // ------------------------------------------------------------
    // Find the highest booking count.
    // ------------------------------------------------------------

    final maxCompletedBookings = availableCars.fold<int>(0, (max, item) {
      final count = bookingCounts[item.car.id] ?? 0;

      return math.max(max, count);
    });

    // ------------------------------------------------------------
    // Attach score + original index.
    //
    // Original index gives us a deterministic tie breaker.
    // ------------------------------------------------------------

    final indexedCars = availableCars.asMap().entries.map((entry) {
      final car = entry.value.car;

      final completedBookings = bookingCounts[car.id] ?? 0;

      return (
        index: entry.key,
        item: entry.value,
        score: _calculatePopularityScore(
          car: car,
          completedBookings: completedBookings,
          maxCompletedBookings: maxCompletedBookings,
        ),
      );
    }).toList();

    // ------------------------------------------------------------
    // Highest popularity first.
    // ------------------------------------------------------------

    indexedCars.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);

      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return a.index.compareTo(b.index);
    });

    return indexedCars.take(5).map((entry) => entry.item).toList();
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
    // double? minPrice,
    // double? maxPrice,
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

    // if (category != null && category != "All") {
    //   filtered = filtered.where((c) => c.carType == category).toList();
    // }

    if (selectedCategory != null) {
      filtered = filtered.where((c) => c.carType == selectedCategory).toList();
    }

    if (city != null) {
      filtered = filtered
          .where((c) => c.city.toLowerCase() == city.toLowerCase())
          .toList();
    }

    if (shopId != null) {
      filtered = filtered.where((c) => c.shopId == shopId).toList();
    }

    // if (minPrice != null) {
    //   filtered = filtered.where((c) => c.pricePerDay >= minPrice).toList();
    // }

    // if (maxPrice != null) {
    //   filtered = filtered.where((c) => c.pricePerDay <= maxPrice).toList();
    // }

    if (seats != null) {
      filtered = filtered.where((c) => c.seats >= seats).toList();
    }

    if (fuel != null) {
      filtered = filtered.where((c) => c.fuel == fuel).toList();
    }

    if (transmission != null) {
      filtered = filtered.where((c) => c.transmission == transmission).toList();
    }

    // if (userLat != null && userLng != null && radiusKm != null) {
    //   filtered = filtered.where((car) {
    //     final distance = calculateDistance(
    //       userLat!,
    //       userLng!,
    //       car.location.lat,
    //       car.location.lng,
    //     );

    //     return distance <= radiusKm!;
    //   }).toList();
    // }

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

        // case SortOption.nearest:
        //   if (userLat != null && userLng != null) {
        //     filtered.sort((a, b) {
        //       final d1 = calculateDistance(
        //         userLat!,
        //         userLng!,
        //         a.location.lat,
        //         a.location.lng,
        //       );

        //       final d2 = calculateDistance(
        //         userLat!,
        //         userLng!,
        //         b.location.lat,
        //         b.location.lng,
        //       );

        //       return d1.compareTo(d2);
        //     });
        //   }
        //   break;

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
    // radiusKm = null;

    // cars = _allCars;
    applyFilters();
    notifyListeners();
  }
}
