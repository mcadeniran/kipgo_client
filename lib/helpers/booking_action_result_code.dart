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
  paymentAlreadyProcessed,
  invalidTransactionHash,
  transactionHashAlreadyUsed,
  noAvailableUnitForSelectedDates,
  unitNotFound,
  unitNoLongerAvailable,
  paymentVerifiedSuccessfully,
  rejectionReasonRequired,
  paymentRejectedSuccessfully,
}

String translateResult(BookingActionResultCode code, AppLocalizations loc) {
  print(code);
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
    case BookingActionResultCode.paymentAlreadyProcessed:
      return loc.paymentAlreadyProcessed;
    case BookingActionResultCode.invalidTransactionHash:
      return loc.invalidTransactionHash;
    case BookingActionResultCode.transactionHashAlreadyUsed:
      return loc.transactionHashAlreadyUsed;
    case BookingActionResultCode.noAvailableUnitForSelectedDates:
      return loc.noAvailableUnitForSelectedDates;
    case BookingActionResultCode.unitNotFound:
      return loc.unitNotFound;
    case BookingActionResultCode.unitNoLongerAvailable:
      return loc.unitNoLongerAvailable;
    case BookingActionResultCode.paymentVerifiedSuccessfully:
      return loc.paymentVerifiedSuccessfully;
    case BookingActionResultCode.rejectionReasonRequired:
      return loc.rejectionReasonRequired;
    case BookingActionResultCode.paymentRejectedSuccessfully:
      return loc.paymentRejectedSuccessfully;
  }
}
