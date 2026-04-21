import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get carsCollection =>
      _db.collection('cars');

  // 🔹 Single car
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamCar(String id) {
    return FirebaseFirestore.instance.collection('cars').doc(id).snapshots();
  }

  // 🔹 All cars
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCars() {
    return FirebaseFirestore.instance
        .collection('cars')
        .where('isVisible', isEqualTo: true)
        .snapshots();
  }

  // 🔹 By city
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCarsByCity(String city) {
    return FirebaseFirestore.instance
        .collection('cars')
        .where('city', isEqualTo: city)
        .snapshots();
  }

  // 🔹 By shop
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCarsByShop(
    String rentalId,
  ) {
    return FirebaseFirestore.instance
        .collection('cars')
        .where('shopId', isEqualTo: rentalId)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCar(String id) {
    return carsCollection.doc(id).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCars() {
    return carsCollection.where('isVisible', isEqualTo: true).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCarsByCity(String city) {
    return carsCollection
        .where('isVisible', isEqualTo: true)
        .where('city', isEqualTo: city)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCarsByShop(String rentalId) {
    return carsCollection
        .where('isVisible', isEqualTo: true)
        .where('shopId', isEqualTo: rentalId)
        .get();
  }

  CollectionReference<Map<String, dynamic>> get rentalsCollection =>
      _db.collection('rentalShops');

  Future<DocumentSnapshot<Map<String, dynamic>>> getRentalShop(String id) {
    return rentalsCollection.doc(id).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamRentalShops() {
    return rentalsCollection.where('isActive', isEqualTo: true).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRentalShopsByCity(
    String city,
  ) {
    return rentalsCollection.where('city', isEqualTo: city).get();
  }
}
