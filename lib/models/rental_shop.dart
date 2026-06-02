import 'package:cloud_firestore/cloud_firestore.dart';

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
  // late ShopRules rules;
  late int totalRatings;
  late double rating;
  late bool isActive;
  late double taxRate;

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
    required this.rating,
    required this.totalRatings,
    required this.isActive,
    required this.taxRate,
    required this.commissionPercentage,
    // required this.rules,
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
      rating: (data['rating'] ?? 0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      taxRate: (data['taxRate'] ?? 0).toDouble(),
      commissionPercentage: (data['commissionPercentage'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      isFeatured: data['isFeatured'] ?? false,
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

class ShopRules {
  late String cancellation;
  late String fuelPolicy;
  late String insurance;
  late String lateReturn;
  late String mileageLimit;
  late String securityDeposit;

  ShopRules({
    required this.cancellation,
    required this.fuelPolicy,
    required this.insurance,
    required this.lateReturn,
    required this.mileageLimit,
    required this.securityDeposit,
  });

  factory ShopRules.fromMap(Map<String, dynamic> data) {
    return ShopRules(
      cancellation: data['cancellation'] ?? '',
      fuelPolicy: data['fuelPolicy'] ?? '',
      insurance: data['insurance'] ?? '',
      lateReturn: data['lateReturn'] ?? '',
      mileageLimit: data['mileageLimit'] ?? '',
      securityDeposit: data['securityDeposit'] ?? '',
    );
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
