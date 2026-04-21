import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  late String id;
  late String shopId;
  late String brand;
  late String model;
  late int year;
  late String transmission;
  late String fuel;
  late int seats;
  late String carType;
  late List<String> features;
  late double pricePerDay;
  late String city;
  late String district;
  late String address;
  late List<CarImages> images;
  late CarLocation location;
  late bool offersDelivery;
  late double deliveryPrice;
  late double deposit;
  late String? currency;

  late bool isFeatured;
  late Featured? featured;

  late int totalUnits;
  late int availableUnits;

  late Shop shop;

  late int totalRatings;
  late double rating;

  CarModel({
    required this.id,
    required this.brand,
    required this.pricePerDay,
    required this.address,
    required this.availableUnits,
    required this.carType,
    required this.city,
    required this.deliveryPrice,
    required this.district,
    required this.features,
    required this.fuel,
    required this.images,
    required this.location,
    required this.model,
    required this.offersDelivery,
    required this.seats,
    required this.shopId,
    required this.totalUnits,
    required this.transmission,
    required this.year,
    required this.deposit,
    required this.shop,
    this.featured,
    this.currency,
    required this.isFeatured,
    required this.rating,
    required this.totalRatings,
  });

  factory CarModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CarModel(
      id: id,
      shopId: data['shopId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      transmission: data['transmission'] ?? '',
      fuel: data['fuel'] ?? '',
      seats: data['seats'] ?? 0,
      carType: data['carType'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      address: data['address'] ?? '',
      images: (data['images'] as List<dynamic>? ?? [])
          .map((img) => CarImages.fromMap(img))
          .toList(),
      location: CarLocation.fromFirestore(data['location']),
      offersDelivery: data['offersDelivery'] ?? false,
      deliveryPrice: (data['deliveryPrice'] ?? 0).toDouble(),
      totalUnits: data['totalUnits'] ?? 0,
      currency: data['currency'],
      availableUnits: data['availableUnits'] ?? 0,
      deposit: (data['deposit'] ?? 0).toDouble(),
      shop: Shop.fromMap(data['shop'] ?? {}),
      rating: (data['rating'] ?? 0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      featured: data['featured'] != null
          ? Featured.fromFirestore(data['featured'])
          : null,
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

class CarLocation {
  late double lat;
  late double lng;

  CarLocation({required this.lat, required this.lng});

  factory CarLocation.fromFirestore(dynamic data) {
    if (data is GeoPoint) {
      return CarLocation(lat: data.latitude, lng: data.longitude);
    }

    if (data is Map<String, dynamic>) {
      return CarLocation(
        lat: (data['lat'] ?? 0).toDouble(),
        lng: (data['lng'] ?? 0).toDouble(),
      );
    }

    return CarLocation(lat: 0, lng: 0);
  }
}

class CarImages {
  late String url;
  late bool isCover;

  CarImages({required this.url, required this.isCover});

  factory CarImages.fromMap(Map<String, dynamic> data) {
    return CarImages(url: data['url'] ?? '', isCover: data['isCover'] ?? false);
  }
}

class Shop {
  late String name;
  late String logo;
  late double rating;
  late String email;
  late String phone;
  late Rules rules;

  Shop({
    required this.name,
    required this.logo,
    required this.rating,
    required this.email,
    required this.phone,
    required this.rules,
  });

  factory Shop.fromMap(Map<String, dynamic> data) {
    return Shop(
      name: data['name'] ?? '',
      logo: data['logo'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      rules: Rules.fromMap(data['rules'] ?? {}),
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
