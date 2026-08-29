import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/models/rating_distribution.dart';

class RentalShop {
  late String id;
  late String address;
  late String bannerUrl;
  late String city;
  late String district;
  late String description;
  late String email;
  late String logo;
  late String phone;
  late String name;
  late ShopLocation location;
  late bool isFeatured;
  late Featured? featured;
  late Discount? discount;
  late String currency;
  late bool isActive;
  late double taxRate;
  late RentalReview review;
  late Rules rules;

  late String language;

  late double commissionPercentage;

  RentalShop({
    required this.address,
    required this.bannerUrl,
    required this.city,
    required this.description,
    required this.district,
    required this.email,
    required this.id,
    required this.location,
    required this.logo,
    required this.phone,
    required this.name,
    required this.currency,
    this.featured,
    this.discount,
    required this.isFeatured,
    required this.isActive,
    required this.taxRate,
    required this.review,
    required this.rules,
    required this.commissionPercentage,
    required this.language,
  });

  factory RentalShop.fromFirestore(Map<String, dynamic> data, String id) {
    return RentalShop(
      id: id,
      address: data['address'] ?? '',
      bannerUrl: sanitizeImage(data['bannerUrl']),
      city: data['city'] ?? '',
      description: data['description'] ?? '',
      email: data['email'] ?? '',
      logo: sanitizeImage(data['logoUrl']),
      phone: data['phone'] ?? '',
      district: data['district'] ?? '',
      name: data['name'] ?? '',
      location: ShopLocation.fromFirestore(data['location']),
      taxRate: (data['taxRate'] ?? 0).toDouble(),
      review: RentalReview.fromFirestore(data['review'] ?? {}),
      rules: Rules.fromMap(data['rules'] ?? {}),
      commissionPercentage: (data['commissionPercentage'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      isFeatured: data['isFeatured'] ?? false,
      language: data['language'] ?? 'en',
      featured: data['featured'] != null
          ? Featured.fromFirestore(data['featured'])
          : null,
      discount: data['discount'] != null
          ? Discount.fromFirestore(data['discount'])
          : null,
      isActive: data['isActive'] ?? false,
      // rules: ShopRules.fromMap(data['rules']),
    );
  }
}

class Rules {
  late String cancellation;
  late String fuelPolicy;
  late String insurance;
  late String lateReturn;
  late String mileageLimit;
  late String securityDeposit;

  Rules({
    required this.cancellation,
    required this.fuelPolicy,
    required this.insurance,
    required this.lateReturn,
    required this.mileageLimit,
    required this.securityDeposit,
  });

  factory Rules.fromMap(Map<String, dynamic> data) {
    return Rules(
      cancellation: data['cancellation'] ?? '',
      fuelPolicy: data['fuelPolicy'] ?? '',
      insurance: data['insurance'] ?? '',
      lateReturn: data['lateReturn'] ?? '',
      mileageLimit: data['mileageLimit'] ?? '',
      securityDeposit: data['securityDeposit'] ?? '',
    );
  }
}

class Featured {
  late DateTime? startAt;
  late DateTime? endAt;

  Featured({required this.endAt, required this.startAt});

  factory Featured.fromFirestore(dynamic data) {
    return Featured(
      startAt: _parseTimestamp(data['startAt']),
      endAt: _parseTimestamp(data['endAt']),
    );
  }
}

class Discount {
  late DateTime? startAt;
  late DateTime? endAt;
  late bool isActive;
  late String type;
  late double value;

  Discount({
    required this.endAt,
    required this.isActive,
    required this.value,
    required this.startAt,
    required this.type,
  });

  factory Discount.fromFirestore(dynamic data) {
    return Discount(
      startAt: _parseTimestamp(data['startAt']),
      endAt: _parseTimestamp(data['endAt']),
      isActive: data['isActive'] ?? false,
      value: (data['value'] ?? 0).toDouble(),
      type: data['type'] ?? '',
    );
  }
}

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return null;
}

class ShopLocation {
  late double lat;
  late double lng;

  ShopLocation({required this.lat, required this.lng});

  factory ShopLocation.fromFirestore(dynamic data) {
    if (data is GeoPoint) {
      return ShopLocation(lat: data.latitude, lng: data.longitude);
    }

    if (data is Map<String, dynamic>) {
      return ShopLocation(
        lat: (data['lat'] ?? 0).toDouble(),
        lng: (data['lng'] ?? 0).toDouble(),
      );
    }

    return ShopLocation(lat: 0, lng: 0);
  }
}

String sanitizeImage(dynamic value) {
  if (value == null) return '';

  final str = value.toString().trim();

  if (str.isEmpty) return '';

  if (str.startsWith('http://') || str.startsWith('https://')) {
    return str;
  }

  return '';
}

class RentalReview {
  late double average;
  late double communication;
  late double communicationTotal;
  late RatingDistribution distribution;
  late double overall;
  late double overallTotal;
  late double pickupExperience;
  late double pickupExperienceTotal;
  late double professionalism;
  late double professionalismTotal;
  late int recommendationCount;
  late double recommendationRate;
  late double returnExperience;
  late double returnExperienceTotal;
  late int totalReviews;

  RentalReview({
    required this.average,
    required this.communication,
    required this.communicationTotal,
    required this.distribution,
    required this.overall,
    required this.overallTotal,
    required this.pickupExperience,
    required this.pickupExperienceTotal,
    required this.professionalism,
    required this.professionalismTotal,
    required this.recommendationCount,
    required this.recommendationRate,
    required this.returnExperience,
    required this.returnExperienceTotal,
    required this.totalReviews,
  });

  factory RentalReview.fromFirestore(Map<String, dynamic> data) {
    return RentalReview(
      average: (data['average'] ?? 0).toDouble(),
      communication: (data['communication'] ?? 0).toDouble(),
      communicationTotal: (data['communicationTotal'] ?? 0).toDouble(),
      distribution: RatingDistribution.fromFirestore(
        data['distribution'] ?? {},
      ),
      overall: (data['overall'] ?? 0).toDouble(),
      overallTotal: (data['overallTotal'] ?? 0).toDouble(),
      pickupExperience: (data['pickupExperience'] ?? 0).toDouble(),
      pickupExperienceTotal: (data['pickupExperienceTotal'] ?? 0).toDouble(),
      professionalism: (data['professionalism'] ?? 0).toDouble(),
      professionalismTotal: (data['professionalismTotal'] ?? 0).toDouble(),
      recommendationCount: data['recommendationCount'] ?? 0,
      recommendationRate: (data['recommendationRate'] ?? 0).toDouble(),
      returnExperience: (data['returnExperience'] ?? 0).toDouble(),
      returnExperienceTotal: (data['returnExperienceTotal'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
    );
  }
}
