import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';

enum ShuttleBookingGroup { attention, upcoming, ongoing, completed, closed }

extension ShuttleBookingGroupExtension on ShuttleBookingGroup {
  List<ShuttleBookingStatus> get statuses {
    switch (this) {
      case ShuttleBookingGroup.attention:
        return [
          ShuttleBookingStatus.pending,

          ShuttleBookingStatus.awaitingPayment,

          ShuttleBookingStatus.paymentSubmitted,
        ];
      case ShuttleBookingGroup.upcoming:
        return [
          ShuttleBookingStatus.approved,

          ShuttleBookingStatus.reserved,

          ShuttleBookingStatus.confirmed,
        ];

      case ShuttleBookingGroup.ongoing:
        return [
          ShuttleBookingStatus.driverAssigned,

          ShuttleBookingStatus.driverArriving,

          ShuttleBookingStatus.inProgress,
        ];

      case ShuttleBookingGroup.completed:
        return [ShuttleBookingStatus.completed];

      case ShuttleBookingGroup.closed:
        return [
          ShuttleBookingStatus.cancelled,

          ShuttleBookingStatus.expired,

          ShuttleBookingStatus.rejected,
        ];
    }
  }
}
