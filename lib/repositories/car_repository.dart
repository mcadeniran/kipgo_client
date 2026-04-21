import '../models/car_model.dart';
import '../services/firestore_service.dart';

class CarRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // 🔹 Single car stream
  Stream<CarModel?> streamCar(String id) {
    return _firestoreService.streamCar(id).map((doc) {
      if (!doc.exists) return null;
      return CarModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  // 🔹 All cars stream
  Stream<List<CarModel>> streamCars() {
    return _firestoreService.streamCars().map((snapshot) {
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 🔹 Cars by city
  Stream<List<CarModel>> streamCarsByCity(String city) {
    return _firestoreService.streamCarsByCity(city).map((snapshot) {
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 🔹 Cars by shop
  Stream<List<CarModel>> streamCarsByShop(String rentalId) {
    return _firestoreService.streamCarsByShop(rentalId).map((snapshot) {
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
