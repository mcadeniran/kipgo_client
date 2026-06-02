import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/repositories/rental_shop_repository.dart';

class RentalShopProvider extends ChangeNotifier {
  final RentalShopRepository _repository = RentalShopRepository();

  StreamSubscription? _shopsSub;
  StreamSubscription? _myShopSub;

  List<RentalShop> rentalShops = [];

  RentalShop? currentShop; // 👈 NEW (logged-in admin shop)

  bool loading = false;
  bool loadingMyShop = false; // 👈 separate loading

  bool _isListening = false;

  /// ===============================
  /// 🌍 PUBLIC LIST (MARKETPLACE)
  /// ===============================
  void listenToRentalShops() {
    if (_isListening) return;
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

  /// ===============================
  /// 🧍 GET SINGLE SHOP (SAFE)
  /// ===============================
  RentalShop? getShopById(String shopId) {
    try {
      return rentalShops.firstWhere((r) => r.id == shopId);
    } catch (_) {
      return null; // 👈 prevents crash
    }
  }

  /// ===============================
  /// ⭐ FEATURED SHOPS
  /// ===============================
  List<RentalShop> get featuredShops {
    final now = DateTime.now();

    return rentalShops.where((shop) {
      if (!shop.isFeatured || shop.featured == null) return false;

      final start = shop.featured!.startAt;
      final end = shop.featured!.endAt;

      return now.isAfter(start!) && now.isBefore(end!);
    }).toList();
  }

  /// ===============================
  /// 📍 FETCH BY CITY
  /// ===============================
  Future<void> fetchRentalShopsByCity(String city) async {
    loading = true;
    notifyListeners();

    rentalShops = await _repository.getRentalShopsByCity(city);

    loading = false;
    notifyListeners();
  }

  /// ===============================
  /// 🏢 LOAD CURRENT ADMIN SHOP
  /// ===============================
  Future<void> loadMyShop(String uid) async {
    loadingMyShop = true;
    notifyListeners();

    try {
      final shop = await _repository.getShopByOwnerId(uid);
      currentShop = shop;
    } catch (e) {
      currentShop = null;
    }

    loadingMyShop = false;
    notifyListeners();
  }

  /// ===============================
  /// 🔄 REALTIME CURRENT SHOP (OPTIONAL)
  /// ===============================
  void listenToMyShop(String uid) {
    _myShopSub?.cancel();

    loadingMyShop = true;
    notifyListeners();

    _myShopSub = _repository
        .streamShopByOwnerId(uid)
        .listen(
          (shop) {
            currentShop = shop;
            loadingMyShop = false;
            notifyListeners();
          },
          onError: (error) {
            loadingMyShop = false;
            currentShop = null;
            notifyListeners();
          },
        );
  }

  /// ===============================
  /// ✅ HELPER FLAGS
  /// ===============================
  bool get hasCurrentShop => currentShop != null;

  bool get isRentalAdminReady => !loadingMyShop && currentShop != null;

  /// ===============================
  /// 🧹 CLEANUP
  /// ===============================
  void clear() {
    currentShop = null;
    loadingMyShop = false;
  }

  @override
  void dispose() {
    _shopsSub?.cancel();
    _myShopSub?.cancel();
    super.dispose();
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import '../models/rental_shop.dart';
// import '../repositories/rental_shop_repository.dart';

// class RentalShopProvider extends ChangeNotifier {
//   final RentalShopRepository _repository = RentalShopRepository();

//   StreamSubscription? _shopsSub;

//   List<RentalShop> rentalShops = [];
//   bool loading = false;

//   bool _isListening = false;

//   void listenToRentalShops() {
//     if (_isListening) return; // 🔥 prevents duplicate listeners
//     _isListening = true;

//     loading = true;
//     notifyListeners();
//     _shopsSub?.cancel();

//     _shopsSub = _repository.streamRentalShops().listen((shopList) {
//       rentalShops = shopList;

//       loading = false;
//       notifyListeners();
//     });
//   }

//   RentalShop getShopById(String shopId) {
//     RentalShop rental = rentalShops.singleWhere((r) => r.id == shopId);

//     return rental;
//   }

//   List<RentalShop> get featuredShops {
//     final now = DateTime.now();

//     return rentalShops.where((shop) {
//       if (!shop.isFeatured || shop.featured == null) return false;

//       final start = shop.featured!.startAt;
//       final end = shop.featured!.endAt;

//       if (start == null || end == null) return false;

//       return now.isAfter(start) && now.isBefore(end);
//     }).toList();
//   }

//   Future<void> fetchRentalShopsByCity(String city) async {
//     loading = true;
//     notifyListeners();

//     rentalShops = await _repository.getRentalShopsByCity(city);

//     loading = false;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _shopsSub?.cancel();
//     super.dispose();
//   }
// }
