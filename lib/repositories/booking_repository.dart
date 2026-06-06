import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/helpers/booking_action_result_code.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/repositories/action_result.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/is_unit_available.dart';

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

  Stream<List<BookingModel>> streamAdminBookings() {
    return _firestore
        .collection("bookings")
        .where('source', isEqualTo: 'app')
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

  Future<List<CarUnit>> fetchAvailableCarUnitsByCarId({
    required String carId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cars')
        .doc(carId)
        .collection('units')
        .where('status', isEqualTo: 'available')
        .get();

    List<CarUnit> units = snapshot.docs
        .map((doc) => CarUnit.fromMap(doc.data(), doc.id, carId))
        .toList();

    return units;
  }

  Stream<List<BookingModel>> streamApprovedCarBookings(String carId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['approved', 'ongoing', 'reserved'])
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

  Future<List<BookingModel>> fetchUnitBookings(String unitId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('unitId', isEqualTo: unitId)
        .where('status', whereIn: ['reserved', 'ongoing'])
        .get();

    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  Future<List<BookingModel>> fetchCarActiveBookings(String carId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['reserved', 'ongoing'])
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
          throw Exception(BookingActionResultCode.bookingCannotBeStarted.name);
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

    if (msg.contains('paymentAlreadyProcessed')) {
      return BookingActionResultCode.paymentAlreadyProcessed;
    }

    if (msg.contains('invalidTransactionHash')) {
      return BookingActionResultCode.invalidTransactionHash;
    }

    if (msg.contains('transactionHashAlreadyUsed')) {
      return BookingActionResultCode.transactionHashAlreadyUsed;
    }

    if (msg.contains('noAvailableUnitForSelectedDates')) {
      return BookingActionResultCode.noAvailableUnitForSelectedDates;
    }

    if (msg.contains('unitNotFound')) {
      return BookingActionResultCode.unitNotFound;
    }

    if (msg.contains('unitNoLongerAvailable')) {
      return BookingActionResultCode.unitNoLongerAvailable;
    }

    if (msg.contains('bookingNotFound')) {
      return BookingActionResultCode.bookingNotFound;
    }

    if (msg.contains('paymentAlreadyProcessed')) {
      return BookingActionResultCode.paymentAlreadyProcessed;
    }

    if (msg.contains('rejectionReasonRequired')) {
      return BookingActionResultCode.rejectionReasonRequired;
    }

    return BookingActionResultCode.unknownError;
  }

  Future<ActionResult> verifyCryptoPayment({
    required BookingModel booking,
    required String userId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final bookingRef = db.collection('bookings').doc(booking.id);

      await db.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);

        if (!bookingSnap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final bookingData = bookingSnap.data() as Map<String, dynamic>;

        if (bookingData['payment']?['status'] != 'awaiting_verification') {
          throw Exception(BookingActionResultCode.paymentAlreadyProcessed);
        }

        final txid = bookingData['payment']?['crypto']?['txid']
            ?.toString()
            .trim()
            .toLowerCase();

        if (txid == null || txid.isEmpty) {
          throw Exception(BookingActionResultCode.invalidTransactionHash);
        }

        final txidRef = db.collection('cryptoTransactions').doc(txid);

        final txidSnap = await transaction.get(txidRef);

        if (txidSnap.exists) {
          throw Exception(
            BookingActionResultCode.transactionHashAlreadyUsed.name,
          );
        }

        //
        // Find available unit
        //
        final units = await fetchAvailableCarUnitsByCarId(carId: booking.carId);

        final activeBookings = await fetchCarActiveBookings(booking.carId);

        final availableUnit = findAvailableUnit(units, activeBookings, booking);

        if (availableUnit == null) {
          throw Exception(
            BookingActionResultCode.noAvailableUnitForSelectedDates,
          );
        }

        final unitRef = db
            .collection('cars')
            .doc(booking.carId)
            .collection('units')
            .doc(availableUnit.id);

        final unitSnap = await transaction.get(unitRef);

        if (!unitSnap.exists) {
          throw Exception(BookingActionResultCode.unitNotFound);
        }

        final unitData = unitSnap.data() as Map<String, dynamic>;

        if (unitData['status'] != 'available') {
          throw Exception(BookingActionResultCode.unitNoLongerAvailable);
        }

        transaction.set(txidRef, {
          'txid': txid,
          'bookingId': booking.id,
          'verifiedBy': userId,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // transaction.update(unitRef, {
        //   'status': 'reserved',
        //   'reservedAt': FieldValue.serverTimestamp(),
        // });

        transaction.update(bookingRef, {
          'unitId': availableUnit.id,

          'status': 'reserved',

          'reservedAt': FieldValue.serverTimestamp(),

          'paymentVerified': true,

          'payment.completed': true,

          'payment.status': 'paid',

          'payment.verified': true,

          'payment.paidAt': FieldValue.serverTimestamp(),

          'payment.crypto.txidVerified': true,

          'payment.verification.verifiedBy': userId,

          'payment.verification.verifiedAt': FieldValue.serverTimestamp(),
        });
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.paymentVerifiedSuccessfully,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }

  Future<ActionResult> rejectCryptoPayment({
    required BookingModel booking,
    required String reason,
    required String userId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      final bookingRef = db.collection('bookings').doc(booking.id);

      await db.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);

        if (!bookingSnap.exists) {
          throw Exception(BookingActionResultCode.bookingNotFound);
        }

        final bookingData = bookingSnap.data() as Map<String, dynamic>;

        if (bookingData['payment']?['status'] != 'awaiting_verification') {
          throw Exception(BookingActionResultCode.paymentAlreadyProcessed);
        }

        if (reason.trim().isEmpty) {
          throw Exception(BookingActionResultCode.rejectionReasonRequired);
        }

        transaction.update(bookingRef, {
          'status': 'pending',

          'payment.completed': false,

          'payment.status': 'failed',

          'payment.verified': false,

          'paymentVerified': false,

          'payment.crypto.status': 'failed',

          'payment.crypto.txidVerified': false,

          'payment.crypto.txidRejectedReason': reason.trim(),

          'payment.rejection.reason': reason.trim(),

          'payment.rejection.rejectedBy': userId,

          'payment.rejection.rejectedAt': FieldValue.serverTimestamp(),

          'payment.expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 30)),
          ),
        });
      });

      return const ActionResult(
        success: true,
        code: BookingActionResultCode.paymentRejectedSuccessfully,
      );
    } catch (e) {
      return ActionResult(success: false, code: getErrorMessage(e));
    }
  }
}

CarUnit? findAvailableUnit(
  List<CarUnit> units,
  List<BookingModel> bookings,
  BookingModel currentBooking,
) {
  try {
    return units.firstWhere(
      (unit) =>
          unit.status == 'available' &&
          isUnitAvailable(
            unitId: unit.id,
            bookings: bookings,
            currentBooking: currentBooking,
          ),
    );
  } catch (_) {
    return null;
  }
}
