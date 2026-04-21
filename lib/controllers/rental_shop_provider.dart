import 'dart:async';

import 'package:flutter/material.dart';
import '../models/rental_shop.dart';
import '../repositories/rental_shop_repository.dart';

class RentalShopProvider extends ChangeNotifier {
  final RentalShopRepository _repository = RentalShopRepository();

  StreamSubscription? _shopsSub;

  List<RentalShop> rentalShops = [];
  bool loading = false;

  bool _isListening = false;

  void listenToRentalShops() {
    if (_isListening) return; // 🔥 prevents duplicate listeners
    _isListening = true;

    loading = true;
    notifyListeners();
    _shopsSub?.cancel();

    _shopsSub = _repository.streamRentalShops().listen((shopList) {
      rentalShops = shopList;

      loading = false;
      notifyListeners();
    });
  }

  RentalShop getShopById(String shopId) {
    RentalShop rental = rentalShops.singleWhere((r) => r.id == shopId);

    return rental;
  }

  List<RentalShop> get featuredShops {
    final now = DateTime.now();

    return rentalShops.where((shop) {
      if (!shop.isFeatured || shop.featured == null) return false;

      final start = shop.featured!.startAt;
      final end = shop.featured!.endAt;

      if (start == null || end == null) return false;

      return now.isAfter(start) && now.isBefore(end);
    }).toList();
  }

  Future<void> fetchRentalShopsByCity(String city) async {
    loading = true;
    notifyListeners();

    rentalShops = await _repository.getRentalShopsByCity(city);

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _shopsSub?.cancel();
    super.dispose();
  }
}
