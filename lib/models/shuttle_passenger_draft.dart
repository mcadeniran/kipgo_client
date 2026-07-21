import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_passenger.dart';

@immutable
class ShuttlePassengerDraft {
  final String fullName;
  final String phoneNumber;
  final String email;

  const ShuttlePassengerDraft({
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
  });

  ShuttlePassengerDraft copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
  }) {
    return ShuttlePassengerDraft(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  ShuttleBookingPassenger toBookingPassenger({required String id}) {
    return ShuttleBookingPassenger(
      id: id,
      fullName: fullName.trim(),
      phoneNumber: phoneNumber.trim(),
      email: email.trim(),
    );
  }
}
