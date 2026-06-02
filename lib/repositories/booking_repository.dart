import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/helpers/booking_action_result_code.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/repositories/action_result.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _firestore
        .collection("bookings")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<BookingModel>> streamShopBookings(String shopId) {
    return _firestore
        .collection("bookings")
        .where("shopId", isEqualTo: shopId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),

      if (status == 'accepted') 'approvedAt': FieldValue.serverTimestamp(),

      if (status == 'rejected') 'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<CarUnit>> streamCarUnits(String carId) {
    return FirebaseFirestore.instance
        .collection('cars')
        .doc(carId)
        .collection('units')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CarUnit.fromMap(doc.data(), doc.id, carId))
              .toList();
        });
  }

  Stream<BookingModel> streamBookingById(String bookingId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .map((doc) {
          return BookingModel.fromFirestore(doc);
        });
  }

  Future<CarUnit?> fetchCarUnitByCarId({
    required String carId,
    required String unitId,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection('cars')
        .doc(carId)
        .collection('units')
        .doc(unitId)
        .get();

    if (!doc.exists) return null;

    return CarUnit.fromMap(doc.data()!, doc.id, carId);
  }

  Stream<List<BookingModel>> streamApprovedCarBookings(String carId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['approved', 'ongoing'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> approveBooking({
    required String bookingId,
    required String unitId,
  }) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
          'status': 'approved',
          'unitId': unitId,
          'approvedAt': FieldValue.serverTimestamp(),
        });
  }

  // Future<({bool success, String message})> approveBookingWithoutUnit({
  //   required String bookingId,
  // }) async {
  //   //  const bookingRef = doc(db, 'bookings', bookingId);
  //   bool suc = false;
  //   String mes = '';

  //   final db = FirebaseFirestore.instance;
  //   final docRef = db.collection('bookings').doc(bookingId);

  //   await db
  //       .runTransaction((transaction) {
  //         return transaction.get(docRef).then((doc) {
  //           {
  //             final success = true;
  //             return success;
  //           }
  //         });
  //       })
  //       .then(
  //         (success) {
  //           suc = true;
  //           mes = 'Booking approved successfully';
  //         },
  //         onError: (e) {
  //           suc = false;
  //           mes = "Error updating document $e";
  //         },
  //       );
  //   return (success: suc, message: mes);
  // }

  // Future<void> rejectBooking({
  //   required String bookingId,
  //   required String reason,
  // }) async {
  //   await FirebaseFirestore.instance
  //       .collection('bookings')
  //       .doc(bookingId)
  //       .update({
  //         'status': 'rejected',
  //         'rejectionReason': reason,
  //         'rejectedAt': FieldValue.serverTimestamp(),
  //       });
  // }

  // Future<void> startBooking(String bookingId) async {
  //   await FirebaseFirestore.instance
  //       .collection('bookings')
  //       .doc(bookingId)
  //       .update({
  //         'status': 'ongoing',
  //         'startedAt': FieldValue.serverTimestamp(),
  //       });
  // }

  // Future<void> completeBooking(String bookingId) async {
  //   await FirebaseFirestore.instance
  //       .collection('bookings')
  //       .doc(bookingId)
  //       .update({
  //         'status': 'completed',
  //         'completedAt': FieldValue.serverTimestamp(),
  //       });
  // }

  Future<List<BookingModel>> fetchUnitBookings(String unitId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('unitId', isEqualTo: unitId)
        .where('status', whereIn: ['approved', 'ongoing'])
        .get();

    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  Future<ActionResult> approveBookingWithoutUnit({
    required String bookingId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final bookingRef = db.collection('bookings').doc(bookingId);

      await db.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);

        if (!bookingSnap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final booking = bookingSnap.data() as Map<String, dynamic>;

        if (booking['status'] != 'pending') {
          throw Exception(BookingActionResultCode.alreadyProcessed);
        }

        transaction.update(bookingRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.bookingApprovedSuccessfully,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }

  Future<ActionResult> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final bookingRef = db.collection('bookings').doc(bookingId);

      await db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);

        if (!snap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final booking = snap.data() as Map<String, dynamic>;

        final status = booking['status'];

        if (['completed', 'cancelled', 'rejected'].contains(status)) {
          throw Exception(BookingActionResultCode.bookingCanNoLongerBeRejected);
        }

        transaction.update(bookingRef, {
          'status': 'rejected',
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
        });
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.bookingRejected,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }

  Future<ActionResult> startBooking({
    required BookingModel booking,
    String? unitId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final bookingRef = db.collection('bookings').doc(booking.id);

      await db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);

        if (!snap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final data = snap.data() as Map<String, dynamic>;

        final status = data['status'];

        if (!['approved', 'reserved'].contains(status)) {
          throw Exception(BookingActionResultCode.bookingCannotBeStarted);
        }

        if (status == 'approved' && unitId == null) {
          throw Exception(
            BookingActionResultCode.aVehicleUnitMustBeAssigned.name,
          );
        }

        final updates = {
          'status': 'ongoing',
          'startedAt': FieldValue.serverTimestamp(),
        };

        if (unitId != null) {
          updates['unitId'] = unitId;
        }

        if (status == 'approved') {
          updates.addAll({
            'payment.status': 'paid',
            'payment.completed': true,
            'payment.paidAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.update(bookingRef, updates);
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.bookingStartedSuccessfully,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }

  Future<ActionResult> completeBooking({required String bookingId}) async {
    try {
      final db = FirebaseFirestore.instance;

      final bookingRef = db.collection('bookings').doc(bookingId);

      await db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);

        if (!snap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final booking = snap.data() as Map<String, dynamic>;

        if (booking['status'] != 'ongoing') {
          throw Exception(
            BookingActionResultCode.onlyOngoingBookingsCanBeCompleted,
          );
        }

        transaction.update(bookingRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.bookingCompletedSuccessfully,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }

  BookingActionResultCode getErrorMessage(Object e) {
    final msg = e.toString();

    if (msg.contains('bookingNotFound')) {
      return BookingActionResultCode.bookingNotFound;
    }

    if (msg.contains('aVehicleUnitMustBeAssigned')) {
      return BookingActionResultCode.aVehicleUnitMustBeAssigned;
    }

    if (msg.contains('alreadyProcessed')) {
      return BookingActionResultCode.alreadyProcessed;
    }

    if (msg.contains('bookingCannotBeStarted')) {
      return BookingActionResultCode.bookingCannotBeStarted;
    }

    return BookingActionResultCode.unknownError;
  }
}
