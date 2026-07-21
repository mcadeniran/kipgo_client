import 'package:flutter/material.dart';
import 'package:kipgo/controllers/shuttle_fleet_provider.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_fleet_vehicle.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_route_result.dart';
import 'package:kipgo/models/shuttle_draft.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/models/shuttle_passenger_draft.dart';
import 'package:kipgo/repositories/shuttle_booking_repository.dart';
import 'package:kipgo/services/shuttle_route_service.dart';

class ShuttleBookingProvider extends ChangeNotifier {
  ShuttleBookingProvider({ShuttleBookingRepository? repository})
    : _repository = repository ?? ShuttleBookingRepository();

  final ShuttleBookingRepository _repository;
  ShuttleDraft draft = const ShuttleDraft();

  bool _creatingBooking = false;

  bool get creatingBooking => _creatingBooking;

  ShuttleBooking? _lastBooking;

  ShuttleBooking? get lastBooking => _lastBooking;

  String? _error;

  String? get error => _error;

  bool _loadingRoute = false;

  bool get loadingRoute => _loadingRoute;

  Future<ShuttleBooking> completeBooking({
    required String userId,
    String source = "app",
  }) async {
    _creatingBooking = true;
    notifyListeners();

    try {
      final booking = await _repository.createFromDraft(
        draft: draft,
        userId: userId,
        source: source,
      );

      _lastBooking = booking;

      // draft = const ShuttleDraft();

      return booking;
    } catch (e) {
      _error = e.toString();

      rethrow;
    } finally {
      _creatingBooking = false;
      notifyListeners();
    }
  }

  void _setLoadingRoute(bool value) {
    if (_loadingRoute == value) return;

    _loadingRoute = value;
    notifyListeners();
  }

  Future<void> prepareVehicleSelection(
    ShuttleFleetProvider fleetProvider,
  ) async {
    _setLoadingRoute(true);

    try {
      final results = await Future.wait<dynamic>([
        fleetProvider.loadFleet(),
        ShuttleRouteService.instance.calculateRoute(
          origin: draft.pickup!,
          destination: draft.destination!,
        ),
      ]);

      final route = results[1] as ShuttleRouteResult;

      setDistanceDuration(route);
    } finally {
      _setLoadingRoute(false);
    }
  }

  void setPickup(ShuttleLocation location) {
    draft = draft.copyWith(
      pickup: location,
      selectedVehicle: null,
      totalPrice: 0,
      distanceKm: 0,
      durationMinutes: 0,
    );

    notifyListeners();
  }

  void setDestination(ShuttleLocation location) {
    draft = draft.copyWith(
      destination: location,
      selectedVehicle: null,
      totalPrice: 0,
      distanceKm: 0,
      durationMinutes: 0,
    );

    notifyListeners();
  }

  void setDepartureDate(DateTime date) {
    draft = draft.copyWith(departureDate: date);

    notifyListeners();
  }

  void setReturnDate(DateTime date) {
    draft = draft.copyWith(returnDate: date);
    notifyListeners();
  }

  void toggleRoundTrip(bool value) {
    draft = draft.copyWith(roundTrip: value);
    notifyListeners();
  }

  void incrementPassengers() {
    int p = draft.passengers;
    if (p < 40) {
      draft = draft.copyWith(passengers: ++p);
      notifyListeners();
    }
  }

  void decrementPassengers() {
    int p = draft.passengers;
    if (p > 1) {
      draft = draft.copyWith(passengers: --p);
      notifyListeners();
    }
  }

  void setPaymentMethod(ShuttlePaymentMethod method) {
    final payment = draft.payment.copyWith(method: method);

    draft = draft.copyWith(payment: payment);

    notifyListeners();
  }

  void setDistanceDuration(ShuttleRouteResult value) {
    draft = draft.copyWith(
      distanceKm: value.distanceKm,
      durationMinutes: value.durationMinutes,
    );

    notifyListeners();
  }

  void selectVehicle(ShuttleFleetVehicle vehicle) {
    draft = draft.copyWith(
      selectedVehicle: vehicle,
      totalPrice: draft.distanceKm * vehicle.pricePerKm,
    );

    notifyListeners();
  }

  void setSpecialRequest(String? request) {
    draft = draft.copyWith(specialRequest: request);

    notifyListeners();
  }

  void resetVehicleSelection() {
    draft = draft.copyWith(selectedVehicle: null, totalPrice: 0);

    notifyListeners();
  }

  void updatePassenger({String? fullName, String? phoneNumber, String? email}) {
    final passenger = draft.passenger ?? const ShuttlePassengerDraft();

    if (passenger.fullName == fullName &&
        passenger.phoneNumber == phoneNumber &&
        passenger.email == email) {
      return;
    }

    draft = draft.copyWith(
      passenger: passenger.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      ),
    );

    notifyListeners();
  }

  void resetDraft() {
    draft = const ShuttleDraft();

    _lastBooking = null;
    _error = null;

    notifyListeners();
  }

  String get passengerName => draft.passenger?.fullName ?? '';

  String get passengerPhone => draft.passenger?.phoneNumber ?? '';

  String get passengerEmail => draft.passenger?.email ?? '';

  bool get canContinueToReview {
    final passenger = draft.passenger;

    return draft.selectedVehicle != null &&
        passenger != null &&
        passenger.fullName.trim().isNotEmpty &&
        passenger.phoneNumber.trim().isNotEmpty;
  }

  String? get validationMessage {
    if (draft.pickup == null) {
      return "Please select a pickup location";
    }

    if (draft.destination == null) {
      return "Please select your destination";
    }

    if (draft.departureDate == null) {
      return "Please select a departure date";
    }

    if (draft.roundTrip && draft.returnDate == null) {
      return "Please select a return date";
    }

    return null;
  }

  bool get canCompleteBooking =>
      draft.selectedVehicle != null && draft.passenger != null;
}
