import 'package:kipgo/helpers/shuttle_booking_validator.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_payment.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/utils/shuttle_booking_utils.dart';

class ShuttleBookingMapper {
  const ShuttleBookingMapper._();

  static ShuttleBooking fromDraft({
    required ShuttleDraft draft,
    required String bookingId,
    required String bookingNumber,
    required String userId,
    required String source,
    required ShuttleBookingPayment payment,
  }) {
    ShuttleBookingValidator.validate(draft);
    // _validateDraft(draft);

    return ShuttleBooking(
      id: bookingId,
      bookingNumber: bookingNumber,
      source: source,
      userId: userId,

      passenger: draft.passenger!.toBookingPassenger(id: userId),

      pickup: draft.pickup!,

      destination: draft.destination!,

      departureDate: draft.departureDate!,

      returnDate: draft.returnDate,

      roundTrip: draft.roundTrip,

      passengers: draft.passengers,

      specialRequest: draft.specialRequest ?? "",

      driver: null,

      vehicle: draft.selectedVehicle!.toBookingVehicle(),

      payment: payment,

      status: ShuttleBookingUtils.initialBookingStatus(payment.method),

      timeline: ShuttleBookingUtils.initialTimeline(),

      total: draft.totalPrice,

      currency: draft.selectedVehicle!.currency,
    );
  }
}
