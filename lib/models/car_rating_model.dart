import 'package:cloud_firestore/cloud_firestore.dart';

class CarRatingModel {
  final String id;
  final String bookingId;
  final String carId;
  final String shopId;
  final String userId;
  final double carRating;
  final double companyRating;
  final String review;
  final String userName;
  final String userImage;
  final DateTime createdAt;

  CarRatingModel({
    required this.id,
    required this.bookingId,
    required this.carId,
    required this.shopId,
    required this.userId,
    required this.carRating,
    required this.companyRating,
    required this.review,
    required this.userName,
    required this.userImage,
    required this.createdAt,
  });

  factory CarRatingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CarRatingModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      carId: data['carId'] ?? '',
      shopId: data['shopId'] ?? '',
      userId: data['userId'] ?? '',
      carRating: (data['carRating'] ?? 0).toDouble(),
      companyRating: (data['companyRating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // fallback
    );
  }
}
