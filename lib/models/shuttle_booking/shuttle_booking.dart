import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kipgo/models/shuttle_location.dart';

import 'shuttle_booking_driver.dart';
import 'shuttle_booking_passenger.dart';
import 'shuttle_booking_payment.dart';
import 'shuttle_booking_status.dart';
import 'shuttle_booking_timeline_item.dart';
import 'shuttle_booking_vehicle.dart';

@immutable
class ShuttleBooking {
  /// Firestore document id
  final String id;

  /// Human-readable booking number (e.g. SH-250701-0001)
  final String bookingNumber;

  /// app | admin | web
  final String source;

  /// User who created the booking
  final String userId;

  /// Contact passenger
  final ShuttleBookingPassenger passenger;

  /// Pickup location
  final ShuttleLocation pickup;

  /// Destination location
  final ShuttleLocation destination;

  /// Departure date/time
  final DateTime departureDate;

  /// Return trip date/time (nullable)
  final DateTime? returnDate;

  /// Indicates whether this is a return trip
  final bool roundTrip;

  /// Number of passengers
  final int passengers;

  /// Customer notes
  final String specialRequest;

  /// Assigned driver
  final ShuttleBookingDriver? driver;

  /// Assigned vehicle
  final ShuttleBookingVehicle? vehicle;

  /// Payment information
  final ShuttleBookingPayment payment;

  /// Booking status
  final ShuttleBookingStatus status;

  /// Booking history
  final List<ShuttleBookingTimelineItem> timeline;

  /// Booking amount
  final double total;

  /// Currency
  final String currency;

  const ShuttleBooking({
    required this.id,
    required this.bookingNumber,
    required this.source,
    required this.userId,
    required this.passenger,
    required this.pickup,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.roundTrip,
    required this.passengers,
    required this.specialRequest,
    this.driver,
    this.vehicle,
    required this.payment,
    required this.status,
    required this.timeline,
    required this.total,
    required this.currency,
  });

  factory ShuttleBooking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return ShuttleBooking(
      id: doc.id,
      bookingNumber: data['bookingNumber'] ?? '',
      source: data['source'] ?? 'app',
      userId: data['userId'] ?? '',

      passenger: ShuttleBookingPassenger.fromMap(data['passenger']),

      pickup: ShuttleLocation.fromMap(data['pickup']),

      destination: ShuttleLocation.fromMap(data['destination']),

      departureDate: (data['departureDate'] as Timestamp).toDate(),

      returnDate: _parseTimestamp(data['returnDate']),

      roundTrip: data['roundTrip'] ?? false,

      passengers: data['passengers'] ?? 1,

      specialRequest: data['specialRequest'] ?? '',

      driver: data['driver'] != null
          ? ShuttleBookingDriver.fromMap(data['driver'])
          : null,

      vehicle: data['vehicle'] != null
          ? ShuttleBookingVehicle.fromMap(data['vehicle'])
          : null,

      payment: ShuttleBookingPayment.fromMap(data['payment']),

      status: ShuttleBookingStatus.fromString(data['status']),

      timeline: (data['timeline'] as List<dynamic>? ?? [])
          .map(
            (e) => ShuttleBookingTimelineItem.fromMap(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),

      total: (data['total'] ?? 0).toDouble(),

      currency: data['currency'] ?? 'TRY',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingNumber': bookingNumber,
      'source': source,
      'userId': userId,

      'passenger': passenger.toMap(),

      'pickup': pickup.toMap(),

      'destination': destination.toMap(),

      'departureDate': departureDate,

      'returnDate': returnDate,

      'roundTrip': roundTrip,

      'passengers': passengers,

      'specialRequest': specialRequest,

      'driver': driver?.toMap(),

      'vehicle': vehicle?.toMap(),

      'payment': payment.toMap(),

      'status': status.value,

      'timeline': timeline.map((e) => e.toMap()).toList(),

      'total': total,

      'currency': currency,
    };
  }

  ShuttleBooking copyWith({
    String? id,
    String? bookingNumber,
    String? source,
    String? userId,
    ShuttleBookingPassenger? passenger,
    ShuttleLocation? pickup,
    ShuttleLocation? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    bool? roundTrip,
    int? passengers,
    String? specialRequest,
    ShuttleBookingDriver? driver,
    ShuttleBookingVehicle? vehicle,
    ShuttleBookingPayment? payment,
    ShuttleBookingStatus? status,
    List<ShuttleBookingTimelineItem>? timeline,
    double? total,
    String? currency,
  }) {
    return ShuttleBooking(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      source: source ?? this.source,
      userId: userId ?? this.userId,
      passenger: passenger ?? this.passenger,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      roundTrip: roundTrip ?? this.roundTrip,
      passengers: passengers ?? this.passengers,
      specialRequest: specialRequest ?? this.specialRequest,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      total: total ?? this.total,
      currency: currency ?? this.currency,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
