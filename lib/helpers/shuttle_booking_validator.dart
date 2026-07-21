import 'package:kipgo/models/shuttle_draft.dart';

class ShuttleBookingValidator {
  const ShuttleBookingValidator._();

  static void validate(ShuttleDraft draft) {
    if (draft.pickup == null) {
      throw Exception("Pickup location is required.");
    }

    if (draft.destination == null) {
      throw Exception("Destination is required.");
    }

    if (draft.departureDate == null) {
      throw Exception("Departure date is required.");
    }

    if (draft.roundTrip && draft.returnDate == null) {
      throw Exception("Return date is required.");
    }

    if (draft.selectedVehicle == null) {
      throw Exception("Vehicle has not been selected.");
    }

    if (draft.passenger == null) {
      throw Exception("Passenger information is required.");
    }

    if (draft.passenger!.fullName.trim().isEmpty) {
      throw Exception("Passenger name is required.");
    }

    if (draft.passenger!.phoneNumber.trim().isEmpty) {
      throw Exception("Passenger phone number is required.");
    }

    if (draft.passenger!.email.trim().isEmpty) {
      throw Exception("Passenger email is required.");
    }

    if (draft.distanceKm <= 0) {
      throw Exception("Distance has not been calculated.");
    }

    if (draft.durationMinutes <= 0) {
      throw Exception("Route duration is invalid.");
    }

    if (draft.totalPrice <= 0) {
      throw Exception("Booking total is invalid.");
    }
  }
}
