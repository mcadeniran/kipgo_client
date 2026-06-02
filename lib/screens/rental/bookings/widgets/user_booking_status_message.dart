import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

class UserBookingStatusMessage extends StatelessWidget {
  final BookingModel booking;
  const UserBookingStatusMessage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment!;
    final loc = AppLocalizations.of(context)!;
    final status = booking.status;

    if (status == 'pending' &&
        payment.method == 'crypto' &&
        (payment.status == 'unpaid' || payment.status == 'pending')) {
      return _MessageCard(
        color: Colors.orange,
        title: loc.waitingForPayment,
        message: loc.yourBookingRequestReceived,
      );
    }

    if (status == 'pending' && payment.method == 'payOnPickup') {
      return _MessageCard(
        color: Colors.orange,
        title: loc.bookingRequestSubmitted,
        message: loc.yourBookingRequestAwaitingReview,
      );
    }

    if (booking.status == 'payment_submitted' &&
        payment.method == 'crypto' &&
        payment.status == 'awaiting_verification') {
      return _MessageCard(
        color: Colors.blue,
        title: loc.paymentSubmittedSuccessfully,
        message: loc.yourTransHashReceived,
      );
    }

    if (booking.status == 'reserved' &&
        payment.method == 'crypto' &&
        payment.status == 'paid') {
      return _MessageCard(
        color: Colors.green,
        title: loc.vehicleReserved,
        message: loc.yourPaymentVerified,
      );
    }

    if (booking.status == 'approved') {
      return _MessageCard(
        color: Colors.teal,
        title: loc.bookingApproved,
        message: loc.yourBookingHasBeenApproved,
      );
    }

    if (booking.status == 'ongoing') {
      return _MessageCard(
        color: Colors.indigo,
        title: loc.rentalInProgress,
        message: loc.yourRentalPeriodCurrentlyActive,
      );
    }

    if (booking.status == 'completed') {
      return _MessageCard(
        color: Colors.green,
        title: loc.rentalCompleted,
        message: !booking.isRated
            ? loc.rentalCompletedFeedback
            : loc.rentalCompletedRated,
      );
    }

    if (booking.status == 'rejected') {
      return _MessageCard(
        color: Colors.red,
        title: loc.bookingRequestRejected,
        message: loc.unfortunatelyBookingRequest,
      );
    }

    if (booking.status == 'cancelled') {
      return _MessageCard(
        color: Colors.redAccent,
        title: loc.bookingCancelled,
        message: loc.thisBookingHasBeenCancelled,
      );
    }

    if (booking.status == 'expired') {
      return _MessageCard(
        color: Colors.grey,
        title: loc.bookingExpired,
        message: loc.paymentOrConfirmationExpired,
      );
    }

    if (payment.method == 'crypto' && payment.status == 'failed') {
      return _MessageCard(
        color: Colors.red,
        title: loc.paymentVerificationFailed,
        message:
            '${loc.rejectionReason(payment.rejection?.reason ?? payment.crypto?.txidRejectedReason ?? loc.unknownReason)}\n\n${loc.youMaySubmitAnotherValidTrans}',
      );
    }

    return const SizedBox.shrink();
  }
}

class _MessageCard extends StatelessWidget {
  final Color color;
  final String title;
  final String message;

  const _MessageCard({
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
