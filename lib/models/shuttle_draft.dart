import 'package:flutter/foundation.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_payment.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_fleet_vehicle.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/models/shuttle_passenger_draft.dart';

@immutable
class ShuttleDraft {
  final ShuttleLocation? pickup;
  final ShuttleLocation? destination;

  final DateTime? departureDate;
  final DateTime? returnDate;

  final bool roundTrip;

  final int passengers;

  final String? specialRequest;

  final ShuttleFleetVehicle? selectedVehicle;

  final ShuttlePassengerDraft? passenger;

  final double distanceKm;

  final double totalPrice;

  final int durationMinutes;

  final ShuttleBookingPayment payment;

  const ShuttleDraft({
    this.pickup,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.roundTrip = false,
    this.passengers = 1,
    this.specialRequest,
    this.selectedVehicle,
    this.distanceKm = 0,
    this.totalPrice = 0,
    this.durationMinutes = 0,
    this.passenger,
    this.payment = const ShuttleBookingPayment(
      method: ShuttlePaymentMethod.creditCard,
      status: ShuttlePaymentStatus.unpaid,
      verified: false,
      completed: false,
    ),
  });

  ShuttleDraft copyWith({
    ShuttleLocation? pickup,
    ShuttleLocation? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    bool? roundTrip,
    int? passengers,
    String? specialRequest,
    ShuttleFleetVehicle? selectedVehicle,
    double? distanceKm,
    double? totalPrice,
    int? durationMinutes,
    ShuttlePassengerDraft? passenger,
    ShuttleBookingPayment? payment,
  }) {
    return ShuttleDraft(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      roundTrip: roundTrip ?? this.roundTrip,
      passengers: passengers ?? this.passengers,
      specialRequest: specialRequest ?? this.specialRequest,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      distanceKm: distanceKm ?? this.distanceKm,
      totalPrice: totalPrice ?? this.totalPrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      passenger: passenger ?? this.passenger,
      payment: payment ?? this.payment,
    );
  }

  bool get canContinue {
    return pickup != null &&
        destination != null &&
        departureDate != null &&
        (!roundTrip || returnDate != null);
  }
}
