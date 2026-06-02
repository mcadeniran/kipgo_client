import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

bool isUnitAvailable({
  required String unitId,
  required List<BookingModel> bookings,
  required BookingModel currentBooking,
}) {
  final unitBookings = bookings.where(
    (b) => b.unitId == unitId && b.id != currentBooking.id,
  );

  for (final booking in unitBookings) {
    final bStart = booking.pickupDate;
    final bEnd = booking.dropoffDate;

    if (bStart.isBefore(currentBooking.dropoffDate) &&
        bEnd.isAfter(currentBooking.pickupDate)) {
      return false;
    }
  }

  return true;
}

BookingModel? getUnitConflict({
  required String unitId,
  required List<BookingModel> bookings,
  required BookingModel currentBooking,
}) {
  final unitBookings = bookings.where(
    (b) => b.unitId == unitId && b.id != currentBooking.id,
  );

  for (final booking in unitBookings) {
    if (booking.pickupDate.isBefore(currentBooking.dropoffDate) &&
        booking.dropoffDate.isAfter(currentBooking.pickupDate)) {
      return booking;
    }
  }

  return null;
}

String? getConflictReason(
  BuildContext context,
  String unitId,
  List<BookingModel> bookings,
  BookingModel currentBooking,
) {
  for (final b in bookings) {
    if (b.unitId != unitId || b.id == currentBooking.id) continue;

    final overlap =
        b.pickupDate.isBefore(currentBooking.dropoffDate) &&
        b.dropoffDate.isAfter(currentBooking.pickupDate);

    if (overlap) {
      final start = DateFormat('dd MMM').format(b.pickupDate);
      final end = DateFormat('dd MMM').format(b.dropoffDate);
      return AppLocalizations.of(context)!.booked(start, end);
    }
  }
  return null;
}
