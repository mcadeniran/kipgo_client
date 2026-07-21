import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';

class ShuttleActionButtons extends StatelessWidget {
  final ShuttleBooking booking;

  const ShuttleActionButtons({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: actions
          .map(
            (button) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: button,
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    AppLocalizations loc = AppLocalizations.of(context)!;

    //----------------------------------------------------
    // Continue Crypto Payment
    //----------------------------------------------------

    if (booking.payment.method == ShuttlePaymentMethod.crypto &&
        (booking.payment.status == ShuttlePaymentStatus.unpaid ||
            booking.payment.status == ShuttlePaymentStatus.pending ||
            booking.payment.status == ShuttlePaymentStatus.failed)) {
      // actions.add(
      //   FilledButton.icon(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (_) =>
      //               ShuttleCryptoPaymentScreen(bookingId: booking.id),
      //         ),
      //       );
      //     },
      //     icon: const Icon(Icons.currency_bitcoin),
      //     label: const Text("Continue Payment"),
      //   ),
      // );
    }

    //----------------------------------------------------
    // Cancel Booking
    //----------------------------------------------------

    if (_canCancelBooking) {
      actions.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            // Phase 10
          },
          icon: const Icon(Icons.cancel_outlined),
          label: Text(loc.cancelBooking),
        ),
      );
    }

    //----------------------------------------------------
    // Contact Driver
    //----------------------------------------------------

    if (booking.driver != null &&
        booking.status.index >= ShuttleBookingStatus.driverAssigned.index &&
        booking.status != ShuttleBookingStatus.completed) {
      actions.add(
        FilledButton.icon(
          onPressed: () {
            // url_launcher
          },
          icon: const Icon(Icons.call),
          label: Text(loc.callDriver),
        ),
      );
    }

    //----------------------------------------------------
    // Book Again
    //----------------------------------------------------

    if (booking.status == ShuttleBookingStatus.completed ||
        booking.status == ShuttleBookingStatus.cancelled ||
        booking.status == ShuttleBookingStatus.expired ||
        booking.status == ShuttleBookingStatus.rejected) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () {
            // copy booking into ShuttleDraft
          },
          icon: const Icon(Icons.refresh),
          label: Text(loc.bookAgain),
        ),
      );
    }

    return actions;
  }

  bool get _canCancelBooking {
    switch (booking.status) {
      case ShuttleBookingStatus.pending:
      case ShuttleBookingStatus.awaitingPayment:
      case ShuttleBookingStatus.paymentSubmitted:
      case ShuttleBookingStatus.reserved:
      case ShuttleBookingStatus.confirmed:
        return true;

      default:
        return false;
    }
  }
}
