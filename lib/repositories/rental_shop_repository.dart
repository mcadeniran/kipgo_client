import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rental_shop.dart';
import '../services/firestore_service.dart';

class RentalShopRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<RentalShop?> getRentalShop(String id) async {
    final doc = await _firestoreService.getRentalShop(id);

    if (!doc.exists) return null;

    return RentalShop.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<RentalShop>> streamRentalShops() {
    return _firestoreService.streamRentalShops().map((snapshot) {
      return snapshot.docs
          .map((doc) => RentalShop.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<RentalShop?> getShopByOwnerId(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('rentalShops')
        .doc(uid) // 👈 if UID == shopId
        .get();

    if (!doc.exists) return null;

    return RentalShop.fromFirestore(doc.data()!, doc.id);
  }

  Future<List<RentalShop>> getRentalShopsByCity(String city) async {
    final snapshot = await _firestoreService.getRentalShopsByCity(city);

    return snapshot.docs
        .map((doc) => RentalShop.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<RentalShop?> streamShopByOwnerId(String uid) {
    return FirebaseFirestore.instance
        .collection('rentalShops')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return RentalShop.fromFirestore(doc.data()!, uid);
        });
  }
}
