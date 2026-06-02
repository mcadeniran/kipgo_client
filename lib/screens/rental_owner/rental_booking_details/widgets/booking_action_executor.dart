import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/repositories/action_result.dart';
import 'package:kipgo/repositories/booking_repository.dart';

class BookingActionExecutor {
  static Future<ActionResult> approveBooking(BookingModel booking) async {
    return BookingRepository().approveBookingWithoutUnit(bookingId: booking.id);
  }

  static Future<ActionResult> startBooking(
    BookingModel booking,
    String? unitId,
  ) async {
    return BookingRepository().startBooking(booking: booking, unitId: unitId);
  }

  static Future<ActionResult> completeBooking(BookingModel booking) async {
    return BookingRepository().completeBooking(bookingId: booking.id);
  }

  static Future<ActionResult> rejectBooking(
    BookingModel booking,
    String reason,
  ) async {
    return BookingRepository().rejectBooking(
      bookingId: booking.id,
      reason: reason,
    );
  }
}
