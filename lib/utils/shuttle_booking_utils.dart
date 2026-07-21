import 'package:kipgo/models/shuttle_booking/shuttle_booking_crypto.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_location.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_payment.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_event.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_timeline_item.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';

class ShuttleBookingUtils {
  const ShuttleBookingUtils._();

  /// ---------------------------------------------------------------------------
  /// INITIAL BOOKING STATUS
  /// ---------------------------------------------------------------------------

  static ShuttleBookingStatus initialBookingStatus(
    ShuttlePaymentMethod method,
  ) {
    switch (method) {
      case ShuttlePaymentMethod.crypto:
        return ShuttleBookingStatus.awaitingPayment;

      case ShuttlePaymentMethod.payOnDelivery:
        return ShuttleBookingStatus.pending;
    }
  }

  /// ---------------------------------------------------------------------------
  /// INITIAL PAYMENT
  /// ---------------------------------------------------------------------------

  static ShuttleBookingPayment buildInitialPayment({
    required ShuttlePaymentMethod method,
  }) {
    switch (method) {
      case ShuttlePaymentMethod.payOnDelivery:
        return ShuttleBookingPayment(
          method: ShuttlePaymentMethod.payOnDelivery,
          status: ShuttlePaymentStatus.unpaid,
          verified: false,
          completed: false,
        );

      case ShuttlePaymentMethod.crypto:
        return ShuttleBookingPayment(
          method: ShuttlePaymentMethod.crypto,
          status: ShuttlePaymentStatus.pending,
          verified: false,
          completed: false,
          expiresAt: paymentExpiry,
          crypto: ShuttleBookingCrypto.empty(),
        );
    }
  }

  /// ---------------------------------------------------------------------------
  /// PAYMENT EXPIRY
  /// ---------------------------------------------------------------------------

  static DateTime get paymentExpiry =>
      DateTime.now().add(const Duration(minutes: 30));

  static bool paymentExpired(DateTime? expiry) {
    if (expiry == null) return false;

    return DateTime.now().isAfter(expiry);
  }

  static Duration? paymentRemaining(DateTime? expiry) {
    if (expiry == null) return null;

    return expiry.difference(DateTime.now());
  }

  /// ---------------------------------------------------------------------------
  /// TIMELINE
  /// ---------------------------------------------------------------------------

  static List<ShuttleBookingTimelineItem> initialTimeline() {
    return [
      ShuttleBookingTimelineItem(
        event: ShuttleBookingTimelineEvent.bookingCreated,
        timestamp: DateTime.now(),
        performedBy: "Customer",
        note: "Booking created from mobile application.",
      ),
    ];
  }

  static ShuttleBookingTimelineItem timelineItem({
    required ShuttleBookingTimelineEvent event,
    String? performedBy,
    String? note,
    ShuttleBookingLocation? location,
  }) {
    return ShuttleBookingTimelineItem(
      event: event,
      timestamp: DateTime.now(),
      performedBy: performedBy,
      note: note,
      location: location,
    );
  }

  /// ---------------------------------------------------------------------------
  /// PAYMENT HELPERS
  /// ---------------------------------------------------------------------------

  static bool requiresPaymentVerification(ShuttlePaymentMethod method) {
    return method == ShuttlePaymentMethod.crypto;
  }

  static bool isCrypto(ShuttleBookingPayment payment) {
    return payment.method == ShuttlePaymentMethod.crypto;
  }

  static bool isPayOnDelivery(ShuttleBookingPayment payment) {
    return payment.method == ShuttlePaymentMethod.payOnDelivery;
  }

  static bool paymentCompleted(ShuttleBookingPayment payment) {
    return payment.completed;
  }

  static bool paymentVerified(ShuttleBookingPayment payment) {
    return payment.verified;
  }

  /// ---------------------------------------------------------------------------
  /// BOOKING HELPERS
  /// ---------------------------------------------------------------------------

  static bool bookingAwaitingPayment(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.awaitingPayment;
  }

  static bool bookingPending(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.pending;
  }

  static bool bookingCompleted(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.completed;
  }

  static bool bookingCancelled(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.cancelled;
  }

  static bool bookingExpired(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.expired;
  }

  /// ---------------------------------------------------------------------------
  /// STATUS HELPERS
  /// ---------------------------------------------------------------------------

  static bool canAssignDriver(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.pending &&
        booking.payment.status != ShuttlePaymentStatus.awaitingVerification;
  }

  static bool canStartTrip(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.driverArriving;
  }

  static bool canCompleteTrip(ShuttleBooking booking) {
    return booking.status == ShuttleBookingStatus.inProgress;
  }

  static bool canCancel(ShuttleBooking booking) {
    return booking.status != ShuttleBookingStatus.completed &&
        booking.status != ShuttleBookingStatus.cancelled &&
        booking.status != ShuttleBookingStatus.expired;
  }
}
