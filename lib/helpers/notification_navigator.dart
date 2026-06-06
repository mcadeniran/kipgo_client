import 'package:flutter/material.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_crypto_payment_details_page.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/rental_booking_details_page.dart';

class NotificationNavigator {
  static void navigate(
    BuildContext context, {
    required String audience,
    required String bookingId,
  }) {
    switch (audience) {
      case 'customer':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsPage(bookingId: bookingId),
          ),
        );
        break;

      case 'shop':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RentalBookingDetailsPage(bookingId: bookingId),
          ),
        );
        break;

      case 'admin':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminCryptoPaymentDetailsPage(bookingId: bookingId),
          ),
        );
        break;
    }
  }
}
