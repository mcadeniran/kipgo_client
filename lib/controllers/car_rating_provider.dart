import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/repositories/car_rating_repository.dart';

class CarRatingProvider extends ChangeNotifier {
  final CarRatingRepository _repository;

  CarRatingProvider({CarRatingRepository? repository})
    : _repository = repository ?? CarRatingRepository();

  bool loading = false;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  bool _success = false;
  bool get success => _success;

  List<CarRatingModel> ratings = [];

  Future<void> fetchCarRatings(String carId) async {
    loading = true;
    notifyListeners();

    try {
      ratings = await _repository.getCarRatingsById(carId);
    } catch (e, stackTrace) {
      debugPrint('Error fetching car ratings: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShopRatings(String shopId) async {
    loading = true;
    notifyListeners();

    try {
      ratings = await _repository.getShopRatingsById(shopId);
    } catch (e, stackTrace) {
      debugPrint('Error fetching shop ratings: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required BookingModel booking,
    required RatingDetails details,
    required RatingRental rental,
    required RatingVehicle vehicle,
    required List<File> photos,
    required String userId,
    required String photoUrl,
    required String userName,
  }) async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    _error = null;
    _success = false;

    notifyListeners();

    try {
      await _repository.submitReview(
        booking: booking,
        details: details,
        rental: rental,
        vehicle: vehicle,
        photoFiles: photos,
        userId: userId,
        userName: userName,
        photoUrl: photoUrl,
      );

      _success = true;
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isSubmitting = false;
    _error = null;
    _success = false;
    notifyListeners();
  }

  void clearSuccess() {
    _success = false;
    notifyListeners();
  }

  // Future<void> submitRating({
  //   required String bookingId,
  //   required String carId,
  //   required String shopId,
  //   required String userId,
  //   required String userName,
  //   required String userImage,
  //   required double carRating,
  //   required double companyRating,
  //   required String review,
  // }) async {
  //   loading = true;
  //   notifyListeners();

  //   await _repository.submitRating(
  //     bookingId: bookingId,
  //     carId: carId,
  //     shopId: shopId,
  //     userId: userId,
  //     userName: userName,
  //     userImage: userImage,
  //     carRating: carRating,
  //     companyRating: companyRating,
  //     review: review,
  //   );

  //   /// 🔥 REFRESH AFTER SUBMIT
  //   await fetchCarRatings(carId);

  //   loading = false;
  //   notifyListeners();
  // }
}
