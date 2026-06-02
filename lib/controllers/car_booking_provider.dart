import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/helpers/statuses.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/models/driver_profile.dart';
import 'package:kipgo/models/wallet.dart';
import 'package:kipgo/utils/convert_to_usdt.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CarBookingProvider extends ChangeNotifier {
  bool isBooking = false;
  UploadTask? uploadTask;

  StreamSubscription? bookingsSubscription;
  StreamSubscription? unitsSubscription;

  List<DriverProfile> drivers = [];
  List<BookingModel> bookings = [];
  List<CarUnit> units = [];

  DriverProfile? selectedDriver;

  WalletModel? wallet;

  Future<void> loadDrivers(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("profiles")
        .doc(userId)
        .collection("renters")
        .get();

    drivers = snapshot.docs
        .map((doc) => DriverProfile.fromMap(doc.data(), doc.id))
        .toList();

    notifyListeners();
  }

  Future<void> loadWallet() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('misc')
        .doc('wallet')
        .get();

    wallet = WalletModel.fromSnapshot(snapshot);
  }

  Future<void> loadBookings(String carId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['approved', 'ongoing', 'reserved'])
        .get();

    bookings = snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList();

    notifyListeners();
  }

  void listenToBookings(String carId) {
    bookingsSubscription?.cancel();

    bookingsSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['approved', 'ongoing', 'reserved'])
        .snapshots()
        .listen((snapshot) {
          bookings = snapshot.docs
              .map((e) => BookingModel.fromFirestore(e))
              .toList();

          notifyListeners();
        });
  }

  void listenToUnits(String carId) async {
    unitsSubscription?.cancel();

    unitsSubscription = FirebaseFirestore.instance
        .collection('cars')
        .doc(carId)
        .collection('units')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .listen((snapshot) {
          units = snapshot.docs
              .map((e) => CarUnit.fromMap(e.data(), e.id, carId))
              .toList();
          notifyListeners();
        });
  }

  Future<void> loadUnits(String carId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cars')
        .doc(carId)
        .collection('units')
        .where('status', isEqualTo: 'available')
        .get();

    units = snapshot.docs
        .map((doc) => CarUnit.fromMap(doc.data(), doc.id, carId))
        .toList();

    notifyListeners();
  }

  void setBooking(bool value) {
    isBooking = value;
    notifyListeners();
  }

  Future<String?> uploadFile({
    required File? file,
    required String userId,
  }) async {
    if (file == null) return null;

    try {
      final extension = p.extension(file.path);
      final fileId = const Uuid().v4();

      final path = 'files/$userId/$fileId$extension';

      final ref = FirebaseStorage.instance.ref().child(path);

      uploadTask = ref.putFile(file);
      notifyListeners();

      final snapshot = await uploadTask!.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    } finally {
      uploadTask = null;
      notifyListeners();
    }
  }

  Future<String?> createBooking({
    required String invoiceNumber,
    required String userId,
    required String driverId,
    required CarWithShop car,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    required String deliveryType,
    required String deliveryAddress,
    required double rentalPrice,
    required double deliveryPrice,
    required double deposit,
    required String note,
    required double preTax,
    required double taxAmount,
    required double totalPrice,
    required String name,
    required String phone,
    required String email,
    required String dob,
    required String gender,
    required String licenseFront,
    required String licenseBack,
    required String idCard,
    required String paymentMethod,
    required String currency,
  }) async {
    try {
      setBooking(true);

      /// ---------------------------------------------------
      /// CRYPTO AMOUNT
      /// ---------------------------------------------------

      double cryptoAmount = await convertToUsdt(
        totalPrice,
        currency,
        wallet!.networkFee,
      );

      /// ---------------------------------------------------
      /// BOOKING STATUS
      /// ---------------------------------------------------

      String bookingStatus = BookingStatuses.pending;

      /// ---------------------------------------------------
      /// PAYMENT OBJECT
      /// ---------------------------------------------------

      late Map<String, dynamic> payment;

      /// ---------------------------------------------------
      /// CRYPTO PAYMENT
      /// ---------------------------------------------------

      if (paymentMethod == PaymentMethods.crypto) {
        bookingStatus = BookingStatuses.pending;

        payment = {
          "method": PaymentMethods.crypto,

          "status": PaymentStatuses.pending,

          "verified": false,

          "completed": false,

          "reference": null,

          "transactionId": null,

          "paidAt": null,

          "expiresAt": Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 30)),
          ),

          /// ---------------------------------------------
          /// CRYPTO DETAILS
          /// ---------------------------------------------
          "crypto": {
            "walletAddress": wallet!.wallet,

            "network": wallet!.network,

            "currency": wallet!.currency,

            "amount": cryptoAmount,

            "networkFee": wallet!.networkFee,

            "txidVerified": false,

            "txidRejectedReason": null,

            "txidSubmittedAt": null,

            "txid": null,
          },

          /// ---------------------------------------------
          /// VERIFICATION
          /// ---------------------------------------------
          "verification": {"verifiedBy": null, "verifiedAt": null},
        };
      }
      /// ---------------------------------------------------
      /// PAY ON PICKUP
      /// ---------------------------------------------------
      else {
        bookingStatus = BookingStatuses.pending;

        payment = {
          "method": PaymentMethods.payOnPickup,

          "status": PaymentStatuses.unpaid,

          "verified": false,

          "completed": false,

          "reference": null,

          "transactionId": null,

          "paidAt": null,

          "expiresAt": null,

          "crypto": null,

          "verification": null,
        };
      }

      /// ---------------------------------------------------
      /// CREATE BOOKING REF
      /// ---------------------------------------------------

      final bookingRef = FirebaseFirestore.instance
          .collection("bookings")
          .doc();

      /// ---------------------------------------------------
      /// SAVE BOOKING
      /// ---------------------------------------------------

      await bookingRef.set({
        "invoiceNumber": invoiceNumber,

        "carId": car.car.id,

        "shopId": car.car.shopId,

        "userId": userId,

        "driverId": driverId,

        /// Unit assigned after admin approval
        "unitId": null,

        "source": "app",

        "createdBy": "user",

        "createdById": userId,

        /// ------------------------------------------------
        /// STATUS
        /// ------------------------------------------------
        "status": bookingStatus,

        /// ------------------------------------------------
        /// PAYMENT
        /// ------------------------------------------------
        "payment": payment,

        /// ------------------------------------------------
        /// CAR
        /// ------------------------------------------------
        "car": {
          "brand": car.car.brand,

          "model": car.car.model,

          "year": car.car.year,

          "seats": car.car.seats,

          "transmission": car.car.transmission,

          "carType": car.car.carType,

          "fuel": car.car.fuel,

          "carImage": car.car.images
              .firstWhere(
                (img) => img.isCover == true,
                orElse: () => car.car.images.first,
              )
              .url,

          "pricePerDay": car.finalPrice,
        },

        /// ------------------------------------------------
        /// DATES
        /// ------------------------------------------------
        "pickupDate": Timestamp.fromDate(pickupDate),

        "dropoffDate": Timestamp.fromDate(dropoffDate),

        /// ------------------------------------------------
        /// DELIVERY
        /// ------------------------------------------------
        "deliveryType": deliveryType,

        "deliveryAddress": deliveryAddress,

        /// ------------------------------------------------
        /// PRICE
        /// ------------------------------------------------
        "rentalPrice": rentalPrice,

        "deliveryPrice": deliveryPrice,

        "deposit": deposit,

        "note": note,

        "taxRate": car.shop.taxRate,

        "preTax": preTax,

        "tax": taxAmount,

        "totalPrice": totalPrice,

        "currency": car.car.currency ?? car.shop.currency,

        /// ------------------------------------------------
        /// SHOP
        /// ------------------------------------------------
        "shop": {
          "location": {
            "lat": car.shop.location.lat,

            "lng": car.shop.location.lng,
          },

          "address": car.shop.address,

          "city": car.shop.city,

          "district": car.shop.district,

          "name": car.shop.name,

          "logo": car.shop.logo,
        },

        /// ------------------------------------------------
        /// DRIVER
        /// ------------------------------------------------
        "driver": {
          "name": name,

          "phone": phone,

          "email": email,

          "dob": dob,

          "gender": gender,

          "licenseFront": licenseFront,

          "licenseBack": licenseBack,

          "idCard": idCard,
        },

        /// ------------------------------------------------
        /// TIMESTAMPS
        /// ------------------------------------------------
        "reservedAt": null,

        "approvedAt": null,

        "startedAt": null,

        "completedAt": null,

        "cancelledAt": null,

        "expiredAt": null,

        "rejectedAt": null,

        "createdAt": FieldValue.serverTimestamp(),
      });

      return bookingRef.id;
    } catch (e) {
      debugPrint('CREATE BOOKING ERROR: $e');

      return null;
    } finally {
      setBooking(false);
    }
  }

  // Future<String?> createBooking({
  //   required String invoiceNumber,
  //   required String userId,
  //   required String driverId,
  //   required CarWithShop car,
  //   required DateTime pickupDate,
  //   required DateTime dropoffDate,
  //   required String deliveryType,
  //   required String deliveryAddress,
  //   required double rentalPrice,
  //   required double deliveryPrice,
  //   required double deposit,
  //   required String note,
  //   required double preTax,
  //   required double taxAmount,
  //   required double totalPrice,
  //   required String name,
  //   required String phone,
  //   required String email,
  //   required String dob,
  //   required String gender,
  //   required String licenseFront,
  //   required String licenseBack,
  //   required String idCard,
  //   required String paymentMethod,
  // }) async {
  //   try {
  //     setBooking(true);

  //     /// ---------------------------------------------------
  //     /// STATUS VALUES
  //     /// ---------------------------------------------------

  //     String bookingStatus;

  //     Map<String, dynamic> paymentData;

  //     /// ---------------------------------------------------
  //     /// CRYPTO PAYMENT
  //     /// ---------------------------------------------------

  //     if (paymentMethod == "crypto") {
  //       bookingStatus = "pending";

  //       paymentData = {
  //         "method": "crypto",

  //         "currency": "USDT",

  //         "network": "TRC20",

  //         "walletAddress": "T9zBvz4eRkS1Gq5c68wE3d4f8h4k9m3",

  //         "amount": totalPrice,

  //         "txid": null,

  //         "status": "pending",

  //         "submittedAt": null,

  //         "confirmedAt": null,

  //         "confirmedBy": null,
  //       };
  //     }
  //     /// ---------------------------------------------------
  //     /// PAY ON PICKUP
  //     /// ---------------------------------------------------
  //     else {
  //       bookingStatus = "pending";

  //       paymentData = {
  //         "method": "payOnPickup",

  //         "status": "unpaid",

  //         "amount": totalPrice,

  //         "paidAt": null,
  //       };
  //     }

  //     /// ---------------------------------------------------
  //     /// CREATE BOOKING
  //     /// ---------------------------------------------------

  //     final bookingRef = FirebaseFirestore.instance
  //         .collection("bookings")
  //         .doc();

  //     await bookingRef.set({
  //       "invoiceNumber": invoiceNumber,

  //       "carId": car.car.id,

  //       "shopId": car.car.shopId,

  //       "userId": userId,

  //       "driverId": driverId,

  //       "unitId": null,

  //       "source": "app",

  //       "createdBy": "user",

  //       "createdById": userId,

  //       /// ---------------------------------------------
  //       /// STATUS
  //       /// ---------------------------------------------
  //       "status": bookingStatus,

  //       /// ---------------------------------------------
  //       /// PAYMENT
  //       /// ---------------------------------------------
  //       "payment": paymentData,

  //       /// ---------------------------------------------
  //       /// EXPIRATION
  //       /// Only crypto expires
  //       /// ---------------------------------------------
  //       "paymentExpiresAt": paymentMethod == "crypto"
  //           ? Timestamp.fromDate(
  //               DateTime.now().add(const Duration(minutes: 30)),
  //             )
  //           : null,

  //       /// ---------------------------------------------
  //       /// CAR
  //       /// ---------------------------------------------
  //       "car": {
  //         "brand": car.car.brand,
  //         "model": car.car.model,
  //         "year": car.car.year,
  //         "seats": car.car.seats,
  //         "transmission": car.car.transmission,
  //         "carType": car.car.carType,
  //         "fuel": car.car.fuel,

  //         "carImage": car.car.images
  //             .firstWhere(
  //               (img) => img.isCover == true,
  //               orElse: () => car.car.images.first,
  //             )
  //             .url,

  //         "pricePerDay": car.finalPrice,
  //       },

  //       /// ---------------------------------------------
  //       /// DATES
  //       /// ---------------------------------------------
  //       "pickupDate": Timestamp.fromDate(pickupDate),

  //       "dropoffDate": Timestamp.fromDate(dropoffDate),

  //       /// ---------------------------------------------
  //       /// DELIVERY
  //       /// ---------------------------------------------
  //       "deliveryType": deliveryType,

  //       "deliveryAddress": deliveryAddress,

  //       /// ---------------------------------------------
  //       /// PRICE
  //       /// ---------------------------------------------
  //       "rentalPrice": rentalPrice,

  //       "deliveryPrice": deliveryPrice,

  //       "deposit": deposit,

  //       "note": note,

  //       "taxRate": car.shop.taxRate,

  //       "preTax": preTax,

  //       "tax": taxAmount,

  //       "totalPrice": totalPrice,

  //       "currency": car.car.currency ?? car.shop.currency,

  //       /// ---------------------------------------------
  //       /// SHOP
  //       /// ---------------------------------------------
  //       "shop": {
  //         "location": {
  //           "lat": car.shop.location.lat,
  //           "lng": car.shop.location.lng,
  //         },

  //         "address": car.shop.address,

  //         "city": car.shop.city,

  //         "district": car.shop.district,

  //         "name": car.shop.name,

  //         "logo": car.shop.logo,
  //       },

  //       /// ---------------------------------------------
  //       /// DRIVER
  //       /// ---------------------------------------------
  //       "driver": {
  //         "name": name,

  //         "phone": phone,

  //         "email": email,

  //         "dob": dob,

  //         "gender": gender,

  //         "licenseFront": licenseFront,

  //         "licenseBack": licenseBack,

  //         "idCard": idCard,
  //       },

  //       "createdAt": FieldValue.serverTimestamp(),
  //     });

  //     return bookingRef.id;
  //   } catch (e) {
  //     debugPrint(e.toString());

  //     return null;
  //   } finally {
  //     setBooking(false);
  //   }
  // }

  // Future<bool> createBooking({
  //   required String invoiceNumber,
  //   required String userId,
  //   required String driverId,
  //   required CarWithShop car,
  //   required DateTime pickupDate,
  //   required DateTime dropoffDate,
  //   required String deliveryType,
  //   required String deliveryAddress,
  //   required double rentalPrice,
  //   required double deliveryPrice,
  //   required double deposit,
  //   required String note,
  //   required double preTax,
  //   required double taxAmount,
  //   required double totalPrice,
  //   required String name,
  //   required String phone,
  //   required String email,
  //   required String dob,
  //   required String gender,
  //   required String licenseFront,
  //   required String licenseBack,
  //   required String idCard,
  //   required String paymentMethod,
  // }) async {
  //   try {
  //     if (paymentMethod == 'payOnPickup') {
  //       await FirebaseFirestore.instance.collection("bookings").add({
  //         "invoiceNumber": invoiceNumber,
  //         "carId": car.car.id,
  //         "shopId": car.car.shopId,
  //         "userId": userId,
  //         "driverId": driverId,

  //         "source": "app",
  //         "createdBy": "user",
  //         "createdById": userId,

  //         "car": {
  //           "brand": car.car.brand,
  //           "model": car.car.model,
  //           "year": car.car.year,
  //           "seats": car.car.seats,
  //           "transmission": car.car.transmission,
  //           "carType": car.car.carType,
  //           "fuel": car.car.fuel,
  //           "carImage": car.car.images
  //               .firstWhere(
  //                 (img) => img.isCover == true,
  //                 orElse: () => car.car.images.first,
  //               )
  //               .url,
  //           "pricePerDay": car.finalPrice,
  //         },

  //         "pickupDate": Timestamp.fromDate(pickupDate),
  //         "dropoffDate": Timestamp.fromDate(dropoffDate),

  //         "deliveryType": deliveryType,
  //         "deliveryAddress": deliveryAddress,

  //         "rentalPrice": rentalPrice,
  //         "deliveryPrice": deliveryPrice,
  //         "deposit": deposit,

  //         "note": note,

  //         "taxRate": car.shop.taxRate,
  //         "preTax": preTax,
  //         "tax": taxAmount,
  //         "totalPrice": totalPrice,

  //         "currency": car.car.currency ?? car.shop.currency,

  //         "shop": {
  //           "location": {
  //             "lat": car.shop.location.lat,
  //             "lng": car.shop.location.lng,
  //           },
  //           "address": car.shop.address,
  //           "city": car.shop.city,
  //           "district": car.shop.district,
  //           "name": car.shop.name,
  //           "logo": car.shop.logo,
  //         },

  //         "driver": {
  //           "name": name,
  //           "phone": phone,
  //           "email": email,
  //           "dob": dob,
  //           "gender": gender,
  //           "licenseFront": licenseFront,
  //           "licenseBack": licenseBack,
  //           "idCard": idCard,
  //         },

  //         "status": "pending",

  //         "createdAt": FieldValue.serverTimestamp(),
  //       });
  //     }
  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }

  // Future<bool> createBooking({
  //   required String invoiceNumber,
  //   required String userId,
  //   required String driverId,
  //   required CarWithShop car,
  //   required DateTime pickupDate,
  //   required DateTime dropoffDate,
  //   required String deliveryType,
  //   required String deliveryAddress,
  //   required double rentalPrice,
  //   required double deliveryPrice,
  //   required double deposit,
  //   required String note,
  //   required double preTax,
  //   required double taxAmount,
  //   required double totalPrice,
  //   required String name,
  //   required String phone,
  //   required String email,
  //   required String dob,
  //   required String gender,
  //   required String licenseFront,
  //   required String licenseBack,
  //   required String idCard,
  //   required String paymentMethod,
  // }) async {
  //   try {
  //     setBooking(true);

  //     /// ---------------------------------------------------
  //     /// PAYMENT VALUES
  //     /// ---------------------------------------------------

  //     String bookingStatus = "pending";

  //     String paymentStatus = "unpaid";

  //     bool paymentVerified = false;

  //     String? paymentReference;
  //     String? transactionId;

  //     DateTime? paidAt;

  //     String? assignedUnitId;

  //     /// ---------------------------------------------------
  //     /// ONLINE PAYMENT FLOW
  //     /// ---------------------------------------------------

  //     if (paymentMethod == 'card') {
  //       /// Assign temporary available unit
  //       assignedUnitId = await assignAvailableUnit(
  //         carId: car.car.id,
  //         pickupDate: pickupDate,
  //         dropoffDate: dropoffDate,
  //       );

  //       /// No available unit
  //       if (assignedUnitId == null) {
  //         debugPrint("No available units");
  //         return false;
  //       }

  //       /// Process payment
  //       final paymentSuccess = await processOnlinePayment(
  //         amount: totalPrice,
  //         currency: car.car.currency ?? car.shop.currency,
  //       );

  //       /// Payment failed
  //       if (!paymentSuccess) {
  //         debugPrint("Payment failed");
  //         return false;
  //       }

  //       /// Payment successful
  //       bookingStatus = "reserved";

  //       paymentStatus = "paid";

  //       paymentVerified = true;

  //       paidAt = DateTime.now();

  //       /// Replace later with real gateway refs
  //       paymentReference = const Uuid().v4();

  //       transactionId = const Uuid().v4();
  //     }

  //     /// ---------------------------------------------------
  //     /// SAVE BOOKING
  //     /// ---------------------------------------------------

  //     await FirebaseFirestore.instance.collection("bookings").add({
  //       "invoiceNumber": invoiceNumber,

  //       "carId": car.car.id,
  //       "shopId": car.car.shopId,

  //       "userId": userId,
  //       "driverId": driverId,

  //       "unitId": assignedUnitId,

  //       "source": "app",

  //       "createdBy": "user",
  //       "createdById": userId,

  //       /// ---------------------------------------------------
  //       /// PAYMENT
  //       /// ---------------------------------------------------
  //       "paymentMethod": paymentMethod,

  //       "paymentStatus": paymentStatus,

  //       "paymentReference": paymentReference,

  //       "transactionId": transactionId,

  //       "paymentVerified": paymentVerified,

  //       "paidAt": paidAt != null ? Timestamp.fromDate(paidAt) : null,

  //       /// ---------------------------------------------------
  //       /// BOOKING STATUS
  //       /// ---------------------------------------------------
  //       "status": bookingStatus,

  //       "reservedAt": bookingStatus == "reserved"
  //           ? FieldValue.serverTimestamp()
  //           : null,

  //       /// ---------------------------------------------------
  //       /// CAR
  //       /// ---------------------------------------------------
  //       "car": {
  //         "brand": car.car.brand,
  //         "model": car.car.model,
  //         "year": car.car.year,
  //         "seats": car.car.seats,
  //         "transmission": car.car.transmission,
  //         "carType": car.car.carType,
  //         "fuel": car.car.fuel,

  //         "carImage": car.car.images
  //             .firstWhere(
  //               (img) => img.isCover == true,
  //               orElse: () => car.car.images.first,
  //             )
  //             .url,

  //         "pricePerDay": car.finalPrice,
  //       },

  //       /// ---------------------------------------------------
  //       /// DATES
  //       /// ---------------------------------------------------
  //       "pickupDate": Timestamp.fromDate(pickupDate),

  //       "dropoffDate": Timestamp.fromDate(dropoffDate),

  //       /// ---------------------------------------------------
  //       /// DELIVERY
  //       /// ---------------------------------------------------
  //       "deliveryType": deliveryType,

  //       "deliveryAddress": deliveryAddress,

  //       /// ---------------------------------------------------
  //       /// PRICE
  //       /// ---------------------------------------------------
  //       "rentalPrice": rentalPrice,

  //       "deliveryPrice": deliveryPrice,

  //       "deposit": deposit,

  //       "note": note,

  //       "taxRate": car.shop.taxRate,

  //       "preTax": preTax,

  //       "tax": taxAmount,

  //       "totalPrice": totalPrice,

  //       "currency": car.car.currency ?? car.shop.currency,

  //       /// ---------------------------------------------------
  //       /// SHOP
  //       /// ---------------------------------------------------
  //       "shop": {
  //         "location": {
  //           "lat": car.shop.location.lat,
  //           "lng": car.shop.location.lng,
  //         },

  //         "address": car.shop.address,

  //         "city": car.shop.city,

  //         "district": car.shop.district,

  //         "name": car.shop.name,

  //         "logo": car.shop.logo,
  //       },

  //       /// ---------------------------------------------------
  //       /// DRIVER
  //       /// ---------------------------------------------------
  //       "driver": {
  //         "name": name,
  //         "phone": phone,
  //         "email": email,
  //         "dob": dob,
  //         "gender": gender,

  //         "licenseFront": licenseFront,

  //         "licenseBack": licenseBack,

  //         "idCard": idCard,
  //       },

  //       /// ---------------------------------------------------
  //       /// TIMESTAMPS
  //       /// ---------------------------------------------------
  //       "createdAt": FieldValue.serverTimestamp(),
  //     });

  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());

  //     return false;
  //   } finally {
  //     setBooking(false);
  //   }
  // }

  Future<bool> processOnlinePayment({
    required double amount,
    required String currency,
  }) async {
    /// ---------------------------------------------------
    /// PAYMENT GATEWAY PLACEHOLDER
    /// ---------------------------------------------------
    ///
    /// Replace this with:
    /// - Stripe
    /// - PayTR
    /// - Iyzico
    /// - PayPal
    /// - Flutterwave
    /// etc
    ///
    /// Return true if payment succeeds.
    /// Return false if payment fails.
    /// ---------------------------------------------------

    await Future.delayed(const Duration(seconds: 2));

    return true;
  }

  Future<String?> assignAvailableUnit({
    required String carId,
    required DateTime pickupDate,
    required DateTime dropoffDate,
  }) async {
    final unitsSnapshot = await FirebaseFirestore.instance
        .collection("cars")
        .doc(carId)
        .collection("units")
        .where("status", isEqualTo: "available")
        .get();

    final units = unitsSnapshot.docs;

    for (final unit in units) {
      final unitId = unit.id;

      final bookingSnapshot = await FirebaseFirestore.instance
          .collection("bookings")
          .where("unitId", isEqualTo: unitId)
          .where(
            "status",
            whereIn: ["pending", "approved", "ongoing", "reserved"],
          )
          .get();

      bool isConflicting = false;

      for (final booking in bookingSnapshot.docs) {
        final data = booking.data();

        final existingPickup = (data["pickupDate"] as Timestamp).toDate();

        final existingDropoff = (data["dropoffDate"] as Timestamp).toDate();

        final overlaps =
            pickupDate.isBefore(existingDropoff) &&
            dropoffDate.isAfter(existingPickup);

        if (overlaps) {
          isConflicting = true;
          break;
        }
      }

      if (!isConflicting) {
        return unitId;
      }
    }

    return null;
  }
}
