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

  // Future<List<RentalShop>> getRentalShops() async {
  //   final snapshot = await _firestoreService.streamRentalShops();

  //   return snapshot.docs
  //       .map((doc) => RentalShop.fromFirestore(doc.data(), doc.id))
  //       .toList();
  // }

  Future<List<RentalShop>> getRentalShopsByCity(String city) async {
    final snapshot = await _firestoreService.getRentalShopsByCity(city);

    return snapshot.docs
        .map((doc) => RentalShop.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
