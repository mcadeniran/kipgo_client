import 'package:flutter/material.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/repositories/car_rating_repository.dart';

class CarRatingProvider extends ChangeNotifier {
  final CarRatingRepository _repo = CarRatingRepository();

  bool loading = false;

  List<CarRatingModel> ratings = [];

  Future<void> fetchCarRatings(String carId) async {
    loading = true;
    notifyListeners();

    try {
      ratings = await _repo.getCarRatingsById(carId);
    } catch (e) {
      debugPrint("Error fetching ratings: $e");
    }

    loading = false;
    notifyListeners();
  }

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
    loading = true;
    notifyListeners();

    await _repo.submitRating(
      bookingId: bookingId,
      carId: carId,
      shopId: shopId,
      userId: userId,
      userName: userName,
      userImage: userImage,
      carRating: carRating,
      companyRating: companyRating,
      review: review,
    );

    /// 🔥 REFRESH AFTER SUBMIT
    await fetchCarRatings(carId);

    loading = false;
    notifyListeners();
  }
}
