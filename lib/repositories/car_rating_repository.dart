import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/models/car_rating_model.dart';

class CarRatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating({
    required String bookingId,
    required String carId,
    required String shopId,
    required String userId,
    required String userName,
    required String userImage,
    required double carRating,
    required double companyRating,
    required String review,
  }) async {
    final ratingRef = _firestore.collection('carRatings').doc();

    await _firestore.runTransaction((transaction) async {
      // =========================
      // 🔹 1. READ EVERYTHING FIRST
      // =========================

      final carRef = _firestore.collection('cars').doc(carId);
      final shopRef = _firestore.collection('rentalShops').doc(shopId);
      final bookingRef = _firestore.collection('bookings').doc(bookingId);

      final carSnap = await transaction.get(carRef);
      final shopSnap = await transaction.get(shopRef);

      // =========================
      // 🔹 2. CALCULATIONS
      // =========================

      double currentCarRating = (carSnap.data()?['rating'] ?? 0).toDouble();
      int carTotalRatings = carSnap.data()?['totalRatings'] ?? 0;

      double newCarRating =
          ((currentCarRating * carTotalRatings) + carRating) /
          (carTotalRatings + 1);

      double currentShopRating = (shopSnap.data()?['rating'] ?? 0).toDouble();
      int shopTotalRatings = shopSnap.data()?['totalRatings'] ?? 0;

      double newShopRating =
          ((currentShopRating * shopTotalRatings) + companyRating) /
          (shopTotalRatings + 1);

      // =========================
      // 🔹 3. WRITE EVERYTHING
      // =========================

      // Save rating
      transaction.set(ratingRef, {
        "bookingId": bookingId,
        "carId": carId,
        "shopId": shopId,
        "userId": userId,
        "userName": userName,
        "userImage": userImage,
        "carRating": carRating,
        "companyRating": companyRating,
        "review": review,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Update car
      transaction.update(carRef, {
        "rating": newCarRating,
        "totalRatings": carTotalRatings + 1,
      });

      // Update shop
      transaction.update(shopRef, {
        "rating": newShopRating,
        "totalRatings": shopTotalRatings + 1,
      });

      // Update booking
      transaction.update(bookingRef, {
        "isRated": true,
        "rating": {
          "carRating": carRating,
          "companyRating": companyRating,
          "review": review,
        },
      });
    });
  }

  Future<List<CarRatingModel>> getCarRatingsById(String carId) async {
    final snapshot = await _firestore
        .collection('carRatings')
        .where('carId', isEqualTo: carId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CarRatingModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
