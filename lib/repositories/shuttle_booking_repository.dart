import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kipgo/helpers/shuttle_booking_validator.dart';
import 'package:kipgo/mappers/shuttle_booking_mapper.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_event.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_item.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/repositories/shuttle_payment_repository.dart';
import 'package:kipgo/utils/generate_shuttle_number.dart';

import '../models/shuttle_booking/shuttle_booking.dart';
import '../models/shuttle_booking/shuttle_booking_group.dart';
import '../models/shuttle_booking/shuttle_booking_status.dart';
import '../models/shuttle_booking/shuttle_bookings_page.dart';

class ShuttleBookingRepository {
  ShuttleBookingRepository({
    ShuttlePaymentRepository? paymentRepository,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _paymentRepository = paymentRepository ?? ShuttlePaymentRepository();

  final FirebaseFirestore _firestore;

  static const String _collection = "shuttleBookings";

  // static const _closedStatuses = {
  //   ShuttleBookingStatus.completed,
  //   ShuttleBookingStatus.cancelled,
  //   ShuttleBookingStatus.rejected,
  //   ShuttleBookingStatus.expired,
  // };

  final ShuttlePaymentRepository _paymentRepository;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(_collection);

  Stream<List<ShuttleBooking>> watchUserBookings({required String userId}) {
    return _bookings
        .where("userId", isEqualTo: userId)
        .orderBy("departureDate")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(ShuttleBooking.fromFirestore).toList(),
        );
  }

  Future<ShuttleBooking?> getShuttleBooking(String bookingId) async {
    try {
      final document = await _bookings.doc(bookingId).get();

      if (!document.exists) {
        return null;
      }

      return ShuttleBooking.fromFirestore(document);
    } catch (e, stackTrace) {
      debugPrint("getBooking() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<void> createShuttleBooking(ShuttleBooking booking) async {
    try {
      await _bookings
          .doc(booking.id)
          .set(booking.toMap(), SetOptions(merge: false));
    } catch (e, stackTrace) {
      debugPrint("createBooking() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<ShuttleBooking> createFromDraft({
    required ShuttleDraft draft,
    required String userId,
    required String source,
  }) async {
    ShuttleBookingValidator.validate(draft);

    final bookingRef = _firestore.collection("shuttleBookings").doc();

    final bookingId = bookingRef.id;

    final invoiceNumber = generateShuttleInvoiceNumber();

    final payment = await _paymentRepository.buildPayment(draft: draft);

    final booking = ShuttleBookingMapper.fromDraft(
      draft: draft,
      bookingId: bookingId,
      bookingNumber: invoiceNumber,
      payment: payment,
      userId: userId,
      source: source,
    );

    await bookingRef.set(booking.toMap());

    return booking;
  }

  Stream<ShuttleBooking> watchBooking(String bookingId) {
    return _firestore.collection(_collection).doc(bookingId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        throw Exception("Booking not found.");
      }
      return ShuttleBooking.fromFirestore(doc);
    });
  }

  Future<void> submitCryptoPayment({
    required String bookingId,
    required String txid,
  }) async {
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection(_collection).doc(bookingId);

      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) {
        throw Exception("Booking not found.");
      }

      final booking = ShuttleBooking.fromFirestore(snapshot);

      if (booking.payment.method != ShuttlePaymentMethod.crypto) {
        throw Exception("This booking is not a crypto payment.");
      }

      if (booking.payment.status == ShuttlePaymentStatus.awaitingVerification) {
        throw Exception("Payment has already been submitted.");
      }

      if (booking.payment.status == ShuttlePaymentStatus.paid) {
        throw Exception("Payment has already been verified.");
      }

      if (booking.payment.expiresAt != null &&
          DateTime.now().isAfter(booking.payment.expiresAt!)) {
        throw Exception("This payment request has expired.");
      }

      final updatedPayment = booking.payment.copyWith(
        status: ShuttlePaymentStatus.awaitingVerification,
        reference: txid,
        expiresAt: null,
        crypto: booking.payment.crypto?.copyWith(
          transactionId: txid,
          submittedAt: now,
        ),
      );

      final updatedTimeline = [
        ...booking.timeline,
        ShuttleBookingTimelineItem(
          event: ShuttleBookingTimelineEvent.paymentSubmitted,
          timestamp: now,
          note: "Customer submitted crypto transaction.",
        ),
      ];

      transaction.update(bookingRef, {
        "payment": updatedPayment.toMap(),
        "timeline": updatedTimeline.map((e) => e.toMap()).toList(),
        "status": ShuttleBookingStatus.paymentSubmitted.value,
      });
    });
  }

  Future<void> submitCardPayment({required String bookingId}) async {
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection(_collection).doc(bookingId);

      final snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) {
        throw Exception("Booking not found.");
      }

      final booking = ShuttleBooking.fromFirestore(snapshot);

      if (booking.payment.method != ShuttlePaymentMethod.creditCard) {
        throw Exception("This booking is not a card payment.");
      }

      if (booking.payment.paymentLink == null ||
          booking.payment.paymentLink!.isEmpty) {
        throw Exception("Payment link has not been generated.");
      }

      if (booking.payment.status == ShuttlePaymentStatus.awaitingVerification) {
        throw Exception("Payment has already been submitted.");
      }

      if (booking.payment.status == ShuttlePaymentStatus.paid) {
        throw Exception("Payment has already been verified.");
      }

      if (booking.payment.expiresAt != null &&
          now.isAfter(booking.payment.expiresAt!)) {
        throw Exception("This payment request has expired.");
      }

      final updatedPayment = booking.payment.copyWith(
        status: ShuttlePaymentStatus.awaitingVerification,
        paidAt: now,
      );

      final updatedTimeline = [
        ...booking.timeline,

        ShuttleBookingTimelineItem(
          event: ShuttleBookingTimelineEvent.paymentSubmitted,
          timestamp: now,
          note: "Customer confirmed card payment.",
        ),
      ];

      transaction.update(bookingRef, {
        "payment": updatedPayment.toMap(),

        "timeline": updatedTimeline.map((e) => e.toMap()).toList(),
      });
    });
  }

  Future<void> updateShuttleBooking(ShuttleBooking booking) async {
    try {
      await _bookings
          .doc(booking.id)
          .set(booking.toMap(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint("updateBooking() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<void> deleteShuttleBooking(String bookingId) async {
    try {
      await _bookings.doc(bookingId).delete();
    } catch (e, stackTrace) {
      debugPrint("deleteBooking() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<void> updateShuttleStatus({
    required String bookingId,
    required ShuttleBookingStatus status,
  }) async {
    try {
      await _bookings.doc(bookingId).update({"status": status.value});
    } catch (e, stackTrace) {
      debugPrint("updateStatus() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<ShuttleBookingsPage> getShuttleBookings({
    required String userId,
    required ShuttleBookingGroup group,
    int limit = 10,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _bookings
          .where("userId", isEqualTo: userId)
          .where("status", whereIn: group.statuses.map((e) => e.value).toList())
          .orderBy("departureDate", descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      final bookings = snapshot.docs
          .map((doc) => ShuttleBooking.fromFirestore(doc))
          .toList();

      final DocumentSnapshot<Map<String, dynamic>>? newLastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : lastDocument;

      return ShuttleBookingsPage(
        bookings: bookings,
        lastDocument: newLastDocument,
        hasMore: snapshot.docs.length == limit,
      );
    } catch (e, stackTrace) {
      debugPrint("getBookings() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<void> cancelShuttleBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final document = await transaction.get(_bookings.doc(bookingId));

        if (!document.exists) {
          throw Exception("Booking not found.");
        }

        final booking = ShuttleBooking.fromFirestore(document);

        final updatedTimeline = [
          ...booking.timeline,
          ShuttleBookingTimelineItem(
            event: ShuttleBookingTimelineEvent.bookingCancelled,
            timestamp: DateTime.now(),
            note: reason,
          ),
        ];

        transaction.update(document.reference, {
          "status": ShuttleBookingStatus.cancelled.value,
          "timeline": updatedTimeline.map((e) => e.toMap()).toList(),
        });
      });
    } catch (e, stackTrace) {
      debugPrint("cancelBooking() failed\n$e\n$stackTrace");

      rethrow;
    }
  }

  Future<bool> bookingShuttleExists(String bookingId) async {
    try {
      final document = await _bookings.doc(bookingId).get();

      return document.exists;
    } catch (e, stackTrace) {
      debugPrint("bookingExists() failed\n$e\n$stackTrace");

      rethrow;
    }
  }
}
