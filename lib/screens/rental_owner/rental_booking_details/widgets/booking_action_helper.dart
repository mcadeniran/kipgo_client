import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/rental_booking_details_page.dart';

class BookingActionHelper {
  static List<BookingAction> getActions(BookingModel booking) {
    final status = booking.status;
    final paymentMethod = booking.payment?.method;
    final paymentStatus = booking.payment?.status;

    // Pending + Pay on Pickup
    if (status == 'pending' &&
        paymentMethod == 'payOnPickup' &&
        paymentStatus == 'unpaid') {
      return [BookingAction.approve, BookingAction.reject];
    }

    // Reserved + Pay on Pickup
    if (status == 'reserved' &&
        paymentMethod == 'payOnPickup' &&
        paymentStatus == 'paid') {
      return [BookingAction.start, BookingAction.reject];
    }

    // Reserved + Crypto Paid
    if (status == 'reserved' &&
        paymentMethod == 'crypto' &&
        paymentStatus == 'paid') {
      return [BookingAction.start];
    }

    // Approved + Pay on Pickup
    if (status == 'approved' && paymentMethod == 'payOnPickup') {
      return [BookingAction.start, BookingAction.reject];
    }

    // Ongoing
    if (status == 'ongoing') {
      return [BookingAction.complete];
    }

    return [];
  }
}
