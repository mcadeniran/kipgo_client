import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String email;
  final String username;
  final String role;
  final String token;
  final String newRideStatus;
  final Personal personal;
  final Vehicle vehicle;
  final Account account;
  final List rides;
  final List drives;

  Profile({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.token,
    required this.personal,
    required this.vehicle,
    required this.account,
    required this.rides,
    required this.drives,
    required this.newRideStatus,
  });

  factory Profile.fromMap(Map<String, dynamic> map, {required String id}) {
    return Profile(
      id: id,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      newRideStatus: map['newRideStatus'] ?? 'idle',
      personal: Personal.fromMap(map['personal'] ?? {}),
      vehicle: Vehicle.fromMap(map['vehicle'] ?? {}),
      account: Account.fromMap(map['account'] ?? {}),
      rides: map['rides'] ?? [],
      drives: map['drives'] ?? [],
    );
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'token': token,
      'newRideStatus': newRideStatus,
      'personal': personal.toMap(),
      'vehicle': vehicle.toMap(),
      'account': account.toMap(),
      'drives': drives,
      'rides': rides,
    };
  }

  /// ✅ copyWith
  Profile copyWith({
    String? id,
    String? email,
    String? username,
    String? role,
    String? token,
    String? newRideStatus,
    Personal? personal,
    Vehicle? vehicle,
    Account? account,
    List? rides,
    List? drives,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      newRideStatus: newRideStatus ?? this.newRideStatus,
      personal: personal ?? this.personal,
      vehicle: vehicle ?? this.vehicle,
      account: account ?? this.account,
      rides: rides ?? this.rides,
      drives: drives ?? this.drives,
    );
  }
}

class Personal {
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String phone;
  final List<Review> reviews;

  Personal({
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.phone,
    required this.reviews,
  });

  /// ✅ Calculate average rating
  double get rating {
    final validRatings = reviews
        .map((r) => r.rating)
        .where((r) => r > 0 && r <= 5)
        .toList();

    if (validRatings.isEmpty) return 0.0;

    final sum = validRatings.reduce((a, b) => a + b);
    return sum / validRatings.length;
  }

  factory Personal.fromMap(Map<String, dynamic> map) {
    final reviewsList = (map['reviews'] as List? ?? [])
        .map((e) => Review.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return Personal(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      phone: map['phone'] ?? '',
      reviews: reviewsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      // 'rating': rating,
      'phone': phone,
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }

  Personal copyWith({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    List<Review>? reviews,
  }) {
    return Personal(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      reviews: reviews ?? this.reviews,
    );
  }
}

class Vehicle {
  final String numberPlate;
  final String colour;
  final String licence;
  final String model;
  final String registrationUrl;
  final String licenceUrl;
  final String selfieUrl;
  final String registrationStatus;
  final String registrationText;
  final String selfieStatus;
  final String selfieText;
  final String licenceStatus;
  final String licenceText;

  Vehicle({
    required this.numberPlate,
    required this.colour,
    required this.licence,
    required this.model,
    required this.registrationUrl,
    required this.licenceUrl,
    required this.selfieUrl,
    required this.licenceStatus,
    required this.licenceText,
    required this.registrationStatus,
    required this.registrationText,
    required this.selfieStatus,
    required this.selfieText,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      numberPlate: map['numberPlate'] ?? '',
      colour: map['colour'] ?? '',
      licence: map['licence'] ?? '',
      model: map['model'] ?? '',
      registrationUrl: map['registrationUrl'] ?? '',
      licenceUrl: map['licenceUrl'] ?? '',
      selfieUrl: map['selfieUrl'] ?? '',
      registrationStatus: map['registrationStatus'] ?? '',
      registrationText: map['registrationText'] ?? '',
      licenceStatus: map['licenceStatus'] ?? '',
      licenceText: map['licenceText'] ?? '',
      selfieStatus: map['selfieStatus'] ?? '',
      selfieText: map['selfieText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberPlate': numberPlate,
      'colour': colour,
      'licence': licence,
      'model': model,
      'registrationUrl': registrationUrl,
      'licenceUrl': licenceUrl,
      'selfieUrl': selfieUrl,
      'registrationStatus': registrationStatus,
      'registrationText': registrationText,
      'selfieStatus': selfieStatus,
      'selfieText': selfieText,
      'licenceStatus': licenceStatus,
      'licenceText': licenceText,
    };
  }

  Vehicle copyWith({
    String? numberPlate,
    String? colour,
    String? licence,
    String? model,
    String? registrationUrl,
    String? licenceUrl,
    String? selfieUrl,
    String? registrationStatus,
    String? registrationText,
    String? licenceStatus,
    String? licenceText,
    String? selfieStatus,
    String? selfieText,
  }) {
    return Vehicle(
      numberPlate: numberPlate ?? this.numberPlate,
      colour: colour ?? this.colour,
      licence: licence ?? this.licence,
      model: model ?? this.model,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      licenceUrl: licenceUrl ?? this.registrationUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registrationText: registrationText ?? this.registrationText,
      selfieStatus: selfieStatus ?? this.selfieStatus,
      selfieText: selfieText ?? this.selfieText,
      licenceStatus: licenceStatus ?? this.licenceStatus,
      licenceText: licenceText ?? this.licenceText,
    );
  }
}

class Account {
  final bool isOnline;
  final bool isProfileCompleted;
  final bool isApproved;
  final DateTime createdAt;

  Account({
    required this.isOnline,
    required this.isProfileCompleted,
    required this.isApproved,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      isOnline: map['isOnline'] ?? false,
      isProfileCompleted: map['isProfileCompleted'] ?? false,
      isApproved: map['isApproved'] ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is String)
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'isProfileCompleted': isProfileCompleted,
      'isApproved': isApproved,
      'createdAt': createdAt,
    };
  }

  Account copyWith({
    bool? isOnline,
    bool? isProfileCompleted,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return Account(
      isOnline: isOnline ?? this.isOnline,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Review {
  final double rating;
  final String? details;
  final String rideId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerPhotoUrl;
  final DateTime createdAt;

  Review({
    required this.rating,
    this.details,
    required this.reviewerId,
    required this.rideId,
    required this.reviewerName,
    required this.reviewerPhotoUrl,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      rating: (map['rating'] ?? 0).toDouble(),
      details: map['details'],
      rideId: map['rideId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      reviewerPhotoUrl: map['reviewerPhotoUrl'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      if (details != null) 'details': details,
      'rideId': rideId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerPhotoUrl': reviewerPhotoUrl,
      'createdAt': createdAt,
    };
  }
}
