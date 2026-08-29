import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_rating_model.dart';

class CarRatingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CarRatingRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ratingsRef =>
      _firestore.collection('carRatings');

  CollectionReference<Map<String, dynamic>> get _carsRef =>
      _firestore.collection('cars');

  CollectionReference<Map<String, dynamic>> get _shopsRef =>
      _firestore.collection('rentalShops');

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection('bookings');

  /// Checks whether a booking is eligible for a review.
  Future<bool> canReview(BookingModel booking) async {
    final user = _auth.currentUser;

    if (user == null) return false;

    if (booking.userId != user.uid) return false;

    if (booking.status != 'completed') return false;

    if (booking.isRated) return false;

    // The booking ID is also the review ID, which gives us
    // an additional duplicate-review safeguard.
    final existing = await _ratingsRef.doc(booking.id).get();

    return !existing.exists;
  }

  /// Uploads review photos to Firebase Storage.
  ///
  /// The booking ID is used as the parent path so the files remain
  /// associated with the review.
  Future<List<RatingPhoto>> uploadPhotos({
    required String bookingId,
    required List<File> files,
  }) async {
    if (files.isEmpty) return [];

    final List<RatingPhoto> photos = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final extension = file.path.contains('.')
          ? file.path.split('.').last.toLowerCase()
          : 'jpg';

      final path = 'ratings/$bookingId/${timestamp}_$i.$extension';

      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(contentType: _contentType(extension));

      await ref.putFile(file, metadata);

      final url = await ref.getDownloadURL();

      photos.add(
        RatingPhoto(
          id: '${timestamp}_$i',
          path: path,
          uploadedAt: DateTime.now(),
          url: url,
        ),
      );
    }

    return photos;
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Submits the review and updates:
  ///
  /// 1. carRatings/{bookingId}
  /// 2. cars/{carId}.review
  /// 3. rentalShops/{shopId}.review
  /// 4. rentalBookings/{bookingId}.isRated
  ///
  /// The booking ID is intentionally used as the review ID.
  Future<void> submitReview({
    required BookingModel booking,
    required RatingDetails details,
    required RatingRental rental,
    required RatingVehicle vehicle,
    required List<File> photoFiles,
    required String userId,
    required String photoUrl,
    required String userName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in to submit a review.');
    }

    if (booking.userId != user.uid) {
      throw Exception('You are not allowed to review this booking.');
    }

    if (booking.status != 'completed') {
      throw Exception('Only completed rentals can be reviewed.');
    }

    if (booking.isRated) {
      throw Exception('This rental has already been reviewed.');
    }

    final ratingRef = _ratingsRef.doc(booking.id);
    final bookingRef = _bookingsRef.doc(booking.id);
    final carRef = _carsRef.doc(booking.carId);
    final shopRef = _shopsRef.doc(booking.shopId);

    final existingReview = await ratingRef.get();

    if (existingReview.exists) {
      throw Exception('This rental has already been reviewed.');
    }

    // Upload photos before the transaction because Storage isn't
    // part of Firestore transactions.
    final uploadedPhotos = await uploadPhotos(
      bookingId: booking.id,
      files: photoFiles,
    );

    // final userName = user.displayName ?? '';
    // final userPhoto = user.photoURL ?? '';

    final createdBy = CreatedBy(
      id: user.uid,
      name: details.isAnonymous ? '' : userName,
      photoUrl: details.isAnonymous ? '' : photoUrl,
    );

    final rating = CarRatingModel(
      id: booking.id,
      bookingId: booking.id,
      carId: booking.carId,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      details: RatingDetails(
        cons: details.cons,
        isAnonymous: details.isAnonymous,
        ratingPhoto: uploadedPhotos,
        pros: details.pros,
        review: details.review,
        title: details.title,
        wouldRecommend: details.wouldRecommend,
        wouldRentAgain: details.wouldRentAgain,
      ),
      driverId: booking.driverId,
      rental: rental,
      shopId: booking.shopId,
      unitId: booking.unitId ?? '',
      userId: booking.userId,
      vehicle: vehicle,
      version: 1,
    );

    await _firestore.runTransaction((transaction) async {
      final carSnapshot = await transaction.get(carRef);
      final shopSnapshot = await transaction.get(shopRef);
      final bookingSnapshot = await transaction.get(bookingRef);
      final ratingSnapshot = await transaction.get(ratingRef);

      if (!bookingSnapshot.exists) {
        throw Exception('Booking could not be found.');
      }

      if (ratingSnapshot.exists) {
        throw Exception('This rental has already been reviewed.');
      }

      final bookingData = bookingSnapshot.data() ?? {};

      final currentIsRated = bookingData['isRated'] ?? false;

      if (currentIsRated == true) {
        throw Exception('This rental has already been reviewed.');
      }

      if (!carSnapshot.exists) {
        throw Exception('The rented car could not be found.');
      }

      if (!shopSnapshot.exists) {
        throw Exception('The rental company could not be found.');
      }

      final carData = carSnapshot.data() ?? {};
      final shopData = shopSnapshot.data() ?? {};

      final currentCarReview = Map<String, dynamic>.from(
        carData['review'] ?? {},
      );

      final currentShopReview = Map<String, dynamic>.from(
        shopData['review'] ?? {},
      );

      final updatedCarReview = _buildCarReviewAggregate(
        current: currentCarReview,
        vehicle: vehicle,
        wouldRecommend: details.wouldRecommend,
      );

      final updatedShopReview = _buildShopReviewAggregate(
        current: currentShopReview,
        rental: rental,
        wouldRecommend: details.wouldRecommend,
      );

      transaction.set(ratingRef, {
        'bookingId': rating.bookingId,
        'carId': rating.carId,
        'createdAt': Timestamp.fromDate(rating.createdAt),
        'createdBy': {
          'id': rating.createdBy.id,
          'name': rating.createdBy.name,
          'photoUrl': rating.createdBy.photoUrl,
        },
        'details': {
          'cons': rating.details.cons,
          'isAnonymous': rating.details.isAnonymous,
          'photos': rating.details.ratingPhoto.map((photo) {
            return {
              'id': photo.id,
              'path': photo.path,
              'uploadedAt': Timestamp.fromDate(photo.uploadedAt),
              'url': photo.url,
            };
          }).toList(),
          'pros': rating.details.pros,
          'review': rating.details.review,
          'title': rating.details.title,
          'wouldRecommend': rating.details.wouldRecommend,
          'wouldRentAgain': rating.details.wouldRentAgain,
        },
        'driverId': rating.driverId,
        'rental': {
          'communication': rating.rental.communication,
          'overall': rating.rental.overall,
          'pickupExperience': rating.rental.pickupExperience,
          'professionalism': rating.rental.professionalism,
          'returnExperience': rating.rental.returnExperience,
        },
        'shopId': rating.shopId,
        'unitId': rating.unitId,
        'userId': rating.userId,
        'vehicle': {
          'cleanliness': rating.vehicle.cleanliness,
          'comfort': rating.vehicle.comfort,
          'condition': rating.vehicle.condition,
          'overall': rating.vehicle.overall,
          'valueForMoney': rating.vehicle.valueForMoney,
        },
        'version': rating.version,
      });

      transaction.update(carRef, {'review': updatedCarReview});

      transaction.update(shopRef, {'review': updatedShopReview});

      transaction.update(bookingRef, {
        'isRated': true,
        'rating': {
          'carRating': vehicle.overall.toDouble(),
          'companyRating': rental.overall.toDouble(),
          'review': details.review,
        },
      });
    });
  }

  Map<String, dynamic> _buildCarReviewAggregate({
    required Map<String, dynamic> current,
    required RatingVehicle vehicle,
    required bool wouldRecommend,
  }) {
    final oldTotal = _intValue(current['totalReviews']);

    final newTotal = oldTotal + 1;

    final cleanlinessTotal =
        _doubleValue(current['cleanlinessTotal']) + vehicle.cleanliness;

    final comfortTotal =
        _doubleValue(current['comfortTotal']) + vehicle.comfort;

    final conditionTotal =
        _doubleValue(current['conditionTotal']) + vehicle.condition;

    final overallTotal =
        _doubleValue(current['overallTotal']) + vehicle.overall;

    final valueForMoneyTotal =
        _doubleValue(current['valueForMoneyTotal']) + vehicle.valueForMoney;

    final oldRecommendationCount = _intValue(current['recommendationCount']);

    final recommendationCount =
        oldRecommendationCount + (wouldRecommend ? 1 : 0);

    final distribution = _incrementDistribution(
      current['distribution'],
      vehicle.overall,
    );

    return {
      'average': overallTotal / newTotal,
      'cleanliness': cleanlinessTotal / newTotal,
      'cleanlinessTotal': cleanlinessTotal,
      'comfort': comfortTotal / newTotal,
      'comfortTotal': comfortTotal,
      'condition': conditionTotal / newTotal,
      'conditionTotal': conditionTotal,
      'distribution': distribution,
      'overall': overallTotal / newTotal,
      'overallTotal': overallTotal,
      'recommendationCount': recommendationCount,
      'recommendationRate': (recommendationCount / newTotal) * 100,
      'totalReviews': newTotal,
      'valueForMoney': valueForMoneyTotal / newTotal,
      'valueForMoneyTotal': valueForMoneyTotal,
    };
  }

  Map<String, dynamic> _buildShopReviewAggregate({
    required Map<String, dynamic> current,
    required RatingRental rental,
    required bool wouldRecommend,
  }) {
    final oldTotal = _intValue(current['totalReviews']);

    final newTotal = oldTotal + 1;

    final communicationTotal =
        _doubleValue(current['communicationTotal']) + rental.communication;

    final overallTotal = _doubleValue(current['overallTotal']) + rental.overall;

    final pickupExperienceTotal =
        _doubleValue(current['pickupExperienceTotal']) +
        rental.pickupExperience;

    final professionalismTotal =
        _doubleValue(current['professionalismTotal']) + rental.professionalism;

    final returnExperienceTotal =
        _doubleValue(current['returnExperienceTotal']) +
        rental.returnExperience;

    final oldRecommendationCount = _intValue(current['recommendationCount']);

    final recommendationCount =
        oldRecommendationCount + (wouldRecommend ? 1 : 0);

    final distribution = _incrementDistribution(
      current['distribution'],
      rental.overall,
    );

    return {
      'average': overallTotal / newTotal,
      'communication': communicationTotal / newTotal,
      'communicationTotal': communicationTotal,
      'distribution': distribution,
      'overall': overallTotal / newTotal,
      'overallTotal': overallTotal,
      'pickupExperience': pickupExperienceTotal / newTotal,
      'pickupExperienceTotal': pickupExperienceTotal,
      'professionalism': professionalismTotal / newTotal,
      'professionalismTotal': professionalismTotal,
      'recommendationCount': recommendationCount,
      'recommendationRate': (recommendationCount / newTotal) * 100,
      'returnExperience': returnExperienceTotal / newTotal,
      'returnExperienceTotal': returnExperienceTotal,
      'totalReviews': newTotal,
    };
  }

  Map<String, dynamic> _incrementDistribution(
    dynamic rawDistribution,
    int rating,
  ) {
    final current = Map<String, dynamic>.from(rawDistribution ?? {});

    final distribution = {
      'one': _intValue(current['one']),
      'two': _intValue(current['two']),
      'three': _intValue(current['three']),
      'four': _intValue(current['four']),
      'five': _intValue(current['five']),
    };

    switch (rating) {
      case 1:
        distribution['one'] = distribution['one']! + 1;
        break;
      case 2:
        distribution['two'] = distribution['two']! + 1;
        break;
      case 3:
        distribution['three'] = distribution['three']! + 1;
        break;
      case 4:
        distribution['four'] = distribution['four']! + 1;
        break;
      case 5:
        distribution['five'] = distribution['five']! + 1;
        break;
    }

    return distribution;
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
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

  Future<List<CarRatingModel>> getShopRatingsById(String shopId) async {
    final snapshot = await _firestore
        .collection('carRatings')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CarRatingModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
