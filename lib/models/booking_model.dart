import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String invoiceNumber;
  final String carId;
  final String shopId;
  final String userId;
  final String driverId;

  final DateTime pickupDate;
  final DateTime dropoffDate;

  final String deliveryType;
  final String deliveryAddress;

  final double rentalPrice;
  final double deliveryPrice;
  final double deposit;

  final double taxRate;
  final double preTax;
  final double tax;
  final double totalPrice;
  final String note;
  final String currency;

  final bool isRated;

  final BookingCar car;

  final BookingShop shop;
  final BookingDriver driver;

  final BookingRating rating;

  final String status;
  final String? rejectionReason;

  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;

  BookingModel({
    required this.id,
    required this.invoiceNumber,
    required this.carId,
    required this.shopId,
    required this.userId,
    required this.driverId,
    required this.pickupDate,
    required this.dropoffDate,
    required this.deliveryType,
    required this.deliveryAddress,
    required this.rentalPrice,
    required this.deliveryPrice,
    required this.note,
    required this.deposit,
    required this.taxRate,
    required this.preTax,
    required this.tax,
    required this.totalPrice,
    required this.currency,
    required this.car,
    required this.shop,
    required this.driver,
    required this.status,
    required this.createdAt,
    required this.isRated,
    required this.rating,
    this.rejectionReason,
    this.approvedAt,
    this.startedAt,
    this.completedAt,
    this.rejectedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'],
      carId: data['carId'],
      shopId: data['shopId'],
      userId: data['userId'],
      driverId: data['driverId'],
      note: data['note'],

      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      dropoffDate: (data['dropoffDate'] as Timestamp).toDate(),

      deliveryType: data['deliveryType'],
      deliveryAddress: data['deliveryAddress'] ?? "",

      rejectionReason: data['rejectionReason'],

      rentalPrice: (data['rentalPrice'] ?? 0).toDouble(),
      deliveryPrice: (data['deliveryPrice'] ?? 0).toDouble(),
      deposit: (data['deposit'] ?? 0).toDouble(),

      taxRate: (data['taxRate'] ?? 0).toDouble(),
      preTax: (data['preTax'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      currency: (data['currency']) ?? 'TRY',

      car: BookingCar.fromMap(data['car']),

      shop: BookingShop.fromMap(data['shop']),
      driver: BookingDriver.fromMap(data['driver']),
      rating: BookingRating.fromMap(data['rating'] ?? {}),

      status: data['status'] ?? 'pending',

      isRated: data['isRated'] ?? false,

      // createdAt: data['createdAt'] is Timestamp
      //     ? data['createdAt'].toDate()
      //     : data['createdAt'],
      createdAt: _parseTimestamp(data['createdAt']),
      approvedAt: _parseTimestamp(data['approvedAt']),
      startedAt: _parseTimestamp(data['startedAt']),
      completedAt: _parseTimestamp(data['completedAt']),
      rejectedAt: _parseTimestamp(data['rejectedAt']),
    );
  }
}

class BookingRating {
  final double carRating;
  final double companyRating;
  final String review;

  BookingRating({
    required this.carRating,
    required this.companyRating,
    required this.review,
  });

  factory BookingRating.fromMap(Map<String, dynamic> map) {
    return BookingRating(
      carRating: map['carRating'] ?? 0,
      companyRating: map['companyRating'] ?? 0,
      review: map['review'] ?? '',
    );
  }
}

class BookingShop {
  final String name;
  final String logo;
  final String address;
  final String city;
  final String district;
  final BookingLocation location;

  BookingShop({
    required this.name,
    required this.logo,
    required this.address,
    required this.city,
    required this.district,
    required this.location,
  });

  factory BookingShop.fromMap(Map<String, dynamic> map) {
    return BookingShop(
      name: map['name'],
      logo: map['logo'],
      address: map['address'],
      city: map['city'],
      district: map['district'],
      location: BookingLocation.fromMap(map['location']),
    );
  }
}

class BookingCar {
  final String brand;
  final String model;
  final int year;
  final int seats;
  final String transmission;
  final String fuel;
  final String carImage;
  final double pricePerDay;

  BookingCar({
    required this.brand,
    required this.model,
    required this.year,
    required this.seats,
    required this.transmission,
    required this.fuel,
    required this.carImage,
    required this.pricePerDay,
  });

  factory BookingCar.fromMap(Map<String, dynamic> map) {
    return BookingCar(
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 1990,
      seats: map['seats'] ?? 10,
      transmission: map['transmission'] ?? '',
      fuel: map['fuel'] ?? '',
      carImage: map['carImage'] ?? '',
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
    );
  }
}

class BookingLocation {
  final double lat;
  final double lng;

  BookingLocation({required this.lat, required this.lng});

  factory BookingLocation.fromMap(Map<String, dynamic> map) {
    return BookingLocation(
      lat: (map['lat']).toDouble(),
      lng: (map['lng']).toDouble(),
    );
  }
}

class BookingDriver {
  final String name;
  final String phone;
  final String email;
  final String dob;
  final String gender;

  final String licenseFront;
  final String licenseBack;
  final String idCard;

  BookingDriver({
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.gender,
    required this.licenseFront,
    required this.licenseBack,
    required this.idCard,
  });

  factory BookingDriver.fromMap(Map<String, dynamic> map) {
    return BookingDriver(
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      dob: map['dob'],
      gender: map['gender'],
      licenseFront: map['licenseFront'] ?? '',
      licenseBack: map['licenseBack'] ?? '',
      idCard: map['idCard'] ?? '',
    );
  }
}

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value; // fallback safety
  }

  return null;
}
