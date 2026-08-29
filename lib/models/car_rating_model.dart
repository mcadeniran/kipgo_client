import 'package:cloud_firestore/cloud_firestore.dart';

class CarRatingModel {
  final String id;
  final String bookingId;
  final String carId;
  final DateTime createdAt;
  final CreatedBy createdBy;
  final RatingDetails details;
  final String driverId;
  final RatingRental rental;
  final String shopId;
  final String unitId;
  final String userId;
  final RatingVehicle vehicle;
  final int version;

  CarRatingModel({
    required this.id,
    required this.bookingId,
    required this.carId,
    required this.createdAt,
    required this.createdBy,
    required this.details,
    required this.driverId,
    required this.rental,
    required this.shopId,
    required this.unitId,
    required this.userId,
    required this.vehicle,
    required this.version,
  });

  factory CarRatingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CarRatingModel(
      id: id,

      bookingId: data['bookingId'] ?? '',
      carId: data['carId'] ?? '',

      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      createdBy: CreatedBy.fromFirestore(
        Map<String, dynamic>.from(data['createdBy'] ?? {}),
      ),

      details: RatingDetails.fromFirestore(
        Map<String, dynamic>.from(data['details'] ?? {}),
      ),

      driverId: data['driverId'] ?? '',

      rental: RatingRental.fromFirestore(
        Map<String, dynamic>.from(data['rental'] ?? {}),
      ),

      shopId: data['shopId'] ?? '',
      unitId: data['unitId'] ?? '',
      userId: data['userId'] ?? '',

      vehicle: RatingVehicle.fromFirestore(
        Map<String, dynamic>.from(data['vehicle'] ?? {}),
      ),

      version: data['version'] ?? 1,
    );
  }
}

class CreatedBy {
  final String id;
  final String name;
  final String photoUrl;

  CreatedBy({required this.id, required this.name, required this.photoUrl});

  factory CreatedBy.fromFirestore(Map<String, dynamic> data) {
    return CreatedBy(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}

class RatingDetails {
  final List<String> cons;
  final bool isAnonymous;
  final List<RatingPhoto> ratingPhoto;
  final List<String> pros;
  final String review;
  final String title;
  final bool wouldRecommend;
  final bool wouldRentAgain;

  RatingDetails({
    required this.cons,
    required this.isAnonymous,
    required this.ratingPhoto,
    required this.pros,
    required this.review,
    required this.title,
    required this.wouldRecommend,
    required this.wouldRentAgain,
  });

  factory RatingDetails.fromFirestore(Map<String, dynamic> data) {
    return RatingDetails(
      cons: List<String>.from(data['cons'] ?? const []),

      isAnonymous: data['isAnonymous'] ?? false,

      ratingPhoto: (data['photos'] as List<dynamic>? ?? const [])
          .map((e) => RatingPhoto.fromFirestore(Map<String, dynamic>.from(e)))
          .toList(),

      pros: List<String>.from(data['pros'] ?? const []),

      review: data['review'] ?? '',
      title: data['title'] ?? '',

      wouldRecommend: data['wouldRecommend'] ?? false,
      wouldRentAgain: data['wouldRentAgain'] ?? false,
    );
  }
}

class RatingPhoto {
  final String id;
  final String path;
  final DateTime uploadedAt;
  final String url;

  RatingPhoto({
    required this.id,
    required this.path,
    required this.uploadedAt,
    required this.url,
  });

  factory RatingPhoto.fromFirestore(Map<String, dynamic> data) {
    return RatingPhoto(
      id: data['id'] ?? '',
      path: data['path'] ?? '',

      uploadedAt: data['uploadedAt'] != null
          ? (data['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),

      url: data['url'] ?? '',
    );
  }
}

class RatingRental {
  final int communication;
  final int overall;
  final int pickupExperience;
  final int professionalism;
  final int returnExperience;

  RatingRental({
    required this.communication,
    required this.overall,
    required this.pickupExperience,
    required this.professionalism,
    required this.returnExperience,
  });

  factory RatingRental.fromFirestore(Map<String, dynamic> data) {
    return RatingRental(
      communication: data['communication'] ?? 0,
      overall: data['overall'] ?? 0,
      pickupExperience: data['pickupExperience'] ?? 0,
      professionalism: data['professionalism'] ?? 0,
      returnExperience: data['returnExperience'] ?? 0,
    );
  }
}

class RatingVehicle {
  final int cleanliness;
  final int comfort;
  final int condition;
  final int overall;
  final int valueForMoney;

  RatingVehicle({
    required this.cleanliness,
    required this.comfort,
    required this.condition,
    required this.overall,
    required this.valueForMoney,
  });

  factory RatingVehicle.fromFirestore(Map<String, dynamic> data) {
    return RatingVehicle(
      cleanliness: data['cleanliness'] ?? 0,
      comfort: data['comfort'] ?? 0,
      condition: data['condition'] ?? 0,
      overall: data['overall'] ?? 0,
      valueForMoney: data['valueForMoney'] ?? 0,
    );
  }
}
