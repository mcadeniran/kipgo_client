import 'package:kipgo/l10n/app_localizations.dart';

enum BookingActionResultCode {
  bookingNotFound,
  alreadyProcessed,
  unknownError,
  bookingApprovedSuccessfully,
  bookingCanNoLongerBeRejected,
  bookingRejected,
  bookingCannotBeStarted,
  aVehicleUnitMustBeAssigned,
  bookingStartedSuccessfully,
  onlyOngoingBookingsCanBeCompleted,
  bookingCompletedSuccessfully,
}

String translateResult(BookingActionResultCode code, AppLocalizations loc) {
  switch (code) {
    case BookingActionResultCode.bookingNotFound:
      return loc.bookingNotFound;
    case BookingActionResultCode.alreadyProcessed:
      return loc.alreadyProcessed;
    case BookingActionResultCode.unknownError:
      return loc.unknownError;
    case BookingActionResultCode.bookingApprovedSuccessfully:
      return loc.bookingApprovedSuccessfully;
    case BookingActionResultCode.bookingCanNoLongerBeRejected:
      return loc.bookingCanNoLongerBeRejected;
    case BookingActionResultCode.bookingCannotBeStarted:
      return loc.bookingCannotBeStarted;
    case BookingActionResultCode.bookingCompletedSuccessfully:
      return loc.bookingCompletedSuccessfully;
    case BookingActionResultCode.bookingRejected:
      return loc.bookingRejected;
    case BookingActionResultCode.aVehicleUnitMustBeAssigned:
      return loc.aVehicleUnitMustBeAssigned;
    case BookingActionResultCode.bookingStartedSuccessfully:
      return loc.bookingStartedSuccessfully;
    case BookingActionResultCode.onlyOngoingBookingsCanBeCompleted:
      return loc.onlyOngoingBookingsCanBeCompleted;
  }
}
