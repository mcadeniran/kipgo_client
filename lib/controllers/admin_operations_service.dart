import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_operations_model.dart';

class AdminOperationsService {
  AdminOperationsService._();

  static final AdminOperationsService instance = AdminOperationsService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _count(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  DateTime _startOfToday() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  DateTime _endOfToday() {
    return _startOfToday().add(const Duration(days: 1));
  }

  Timestamp get _todayStart => Timestamp.fromDate(_startOfToday());

  Timestamp get _tomorrowStart => Timestamp.fromDate(_endOfToday());

  Future<AdminTaxiOperations> getTaxiOperations() async {
    final rides = _firestore.collection('taxiRideHistory');
    final profiles = _firestore.collection('profiles');

    final results = await Future.wait<int>([
      _count(
        rides
            .where('time', isGreaterThanOrEqualTo: _todayStart)
            .where('time', isLessThan: _tomorrowStart),
      ),
      _count(
        rides
            .where('status', isEqualTo: 'completed')
            .where('time', isGreaterThanOrEqualTo: _todayStart)
            .where('time', isLessThan: _tomorrowStart),
      ),
      _count(
        rides
            .where('status', isEqualTo: 'cancelled')
            .where('time', isGreaterThanOrEqualTo: _todayStart)
            .where('time', isLessThan: _tomorrowStart),
      ),
      _count(
        profiles
            .where('role', isEqualTo: 'driver')
            .where('account.isOnline', isEqualTo: true),
      ),
    ]);

    return AdminTaxiOperations(
      todayRides: results[0],
      completedToday: results[1],
      cancelledToday: results[2],
      onlineDrivers: results[3],
    );
  }

  Future<AdminRentalOperations> getRentalOperations() async {
    final bookings = _firestore.collection('bookings');

    final results = await Future.wait<int>([
      _count(
        bookings
            .where('createdAt', isGreaterThanOrEqualTo: _todayStart)
            .where('createdAt', isLessThan: _tomorrowStart),
      ),
      _count(bookings.where('status', isEqualTo: 'pending')),
      _count(bookings.where('status', isEqualTo: 'payment_submitted')),
      _count(bookings.where('status', isEqualTo: 'ongoing')),
      _count(
        bookings
            .where('status', isEqualTo: 'completed')
            .where('completedAt', isGreaterThanOrEqualTo: _todayStart)
            .where('completedAt', isLessThan: _tomorrowStart),
      ),
    ]);

    return AdminRentalOperations(
      todayBookings: results[0],
      pending: results[1],
      paymentSubmitted: results[2],
      ongoing: results[3],
      completedToday: results[4],
    );
  }

  Future<AdminShuttleOperations> getShuttleOperations() async {
    final bookings = _firestore.collection('shuttleBookings');

    final results = await Future.wait<int>([
      _count(
        bookings
            .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
            .where('departureDate', isLessThan: _tomorrowStart),
      ),
      _count(bookings.where('status', isEqualTo: 'pending')),
      _count(bookings.where('status', isEqualTo: 'paymentSubmitted')),
      _count(
        bookings
            .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
            .where('departureDate', isLessThan: _tomorrowStart)
            .where(
              'status',
              whereIn: [
                'reserved',
                'approved',
                'confirmed',
                'driverAssigned',
                'driverArriving',
              ],
            ),
      ),
      _count(bookings.where('status', isEqualTo: 'inProgress')),
      _count(
        bookings
            .where('status', isEqualTo: 'completed')
            .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
            .where('departureDate', isLessThan: _tomorrowStart),
      ),
    ]);

    return AdminShuttleOperations(
      todayBookings: results[0],
      pending: results[1],
      paymentSubmitted: results[2],
      upcoming: results[3],
      inProgress: results[4],
      completedToday: results[5],
    );
  }

  Future<AdminOperationsModel> getOperations() async {
    final results = await Future.wait([
      getTaxiOperations(),
      getRentalOperations(),
      getShuttleOperations(),
    ]);

    return AdminOperationsModel(
      taxi: results[0] as AdminTaxiOperations,
      rental: results[1] as AdminRentalOperations,
      shuttle: results[2] as AdminShuttleOperations,
    );
  }
}
