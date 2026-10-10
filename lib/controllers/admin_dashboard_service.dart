import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_dashboard_model.dart';

class AdminDashboardService {
  final FirebaseFirestore _firestore;

  AdminDashboardService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the beginning of today using the device's local timezone.
  DateTime _startOfToday() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the beginning of tomorrow using the device's local timezone.
  DateTime _startOfTomorrow() {
    return _startOfToday().add(const Duration(days: 1));
  }

  Timestamp get _todayStart => Timestamp.fromDate(_startOfToday());

  Timestamp get _tomorrowStart => Timestamp.fromDate(_startOfTomorrow());

  Future<int> _count(Query<Map<String, dynamic>> query) async {
    final aggregate = await query.count().get();
    return aggregate.count ?? 0;
  }

  Future<AdminDashboardModel> getDashboard() async {
    final results = await Future.wait([
      _getTodayRides(),
      _getTodayRentalBookings(),
      _getTodayShuttleBookings(),
      _getTotalUsers(),
      _getOnlineDrivers(),
      _getUnansweredSupport(),
      _getCompletedRides(),
      _getCompletedRentalBookings(),
      _getCompletedShuttleBookings(),
      _getTodayTaxiRevenue(),
      _getTodayRentalRevenue(),
      _getTodayShuttleRevenue(),
    ]);

    return AdminDashboardModel(
      todayRides: results[0] as int,
      todayRentalBookings: results[1] as int,
      todayShuttleBookings: results[2] as int,
      totalUsers: results[3] as int,
      onlineDrivers: results[4] as int,
      unansweredSupport: results[5] as int,
      completedRides: results[6] as int,
      completedRentalBookings: results[7] as int,
      completedShuttleBookings: results[8] as int,
      todayTaxiRevenue: results[9] as double,
      todayRentalRevenue: results[10] as double,
      todayShuttleRevenue: results[11] as double,
    );
  }

  // ============================================================
  // TAXI
  // ============================================================

  Future<int> _getTodayRides() {
    return _count(
      _firestore
          .collection('taxiRideHistory')
          .where('time', isGreaterThanOrEqualTo: _todayStart)
          .where('time', isLessThan: _tomorrowStart),
    );
  }

  Future<int> _getCompletedRides() {
    return _count(
      _firestore
          .collection('taxiRideHistory')
          .where('time', isGreaterThanOrEqualTo: _todayStart)
          .where('time', isLessThan: _tomorrowStart)
          .where('status', isEqualTo: 'completed'),
    );
  }

  Future<double> _getTodayTaxiRevenue() async {
    final snapshot = await _firestore
        .collection('taxiRideHistory')
        .where('time', isGreaterThanOrEqualTo: _todayStart)
        .where('time', isLessThan: _tomorrowStart)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final fare = data['proposedFare'];

      if (fare is num) {
        total += fare.toDouble();
      } else if (fare is String) {
        total += double.tryParse(fare) ?? 0;
      }
    }

    return total;
  }

  // ============================================================
  // CAR RENTAL
  // ============================================================

  Future<int> _getTodayRentalBookings() {
    return _count(
      _firestore
          .collection('bookings')
          .where('createdAt', isGreaterThanOrEqualTo: _todayStart)
          .where('createdAt', isLessThan: _tomorrowStart),
    );
  }

  Future<int> _getCompletedRentalBookings() {
    return _count(
      _firestore
          .collection('bookings')
          .where('completedAt', isGreaterThanOrEqualTo: _todayStart)
          .where('completedAt', isLessThan: _tomorrowStart)
          .where('status', isEqualTo: 'completed'),
    );
  }

  Future<double> _getTodayRentalRevenue() async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('completedAt', isGreaterThanOrEqualTo: _todayStart)
        .where('completedAt', isLessThan: _tomorrowStart)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final value = data['totalPrice'];

      if (value is num) {
        total += value.toDouble();
      } else if (value is String) {
        total += double.tryParse(value) ?? 0;
      }
    }

    return total;
  }

  // ============================================================
  // SHUTTLE
  // ============================================================

  Future<int> _getTodayShuttleBookings() {
    return _count(
      _firestore
          .collection('shuttleBookings')
          .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
          .where('departureDate', isLessThan: _tomorrowStart),
    );
  }

  Future<int> _getCompletedShuttleBookings() {
    return _count(
      _firestore
          .collection('shuttleBookings')
          .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
          .where('departureDate', isLessThan: _tomorrowStart)
          .where('status', isEqualTo: 'completed'),
    );
  }

  Future<double> _getTodayShuttleRevenue() async {
    final snapshot = await _firestore
        .collection('shuttleBookings')
        .where('departureDate', isGreaterThanOrEqualTo: _todayStart)
        .where('departureDate', isLessThan: _tomorrowStart)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final value = data['total'];

      if (value is num) {
        total += value.toDouble();
      } else if (value is String) {
        total += double.tryParse(value) ?? 0;
      }
    }

    return total;
  }

  // ============================================================
  // USERS
  // ============================================================

  Future<int> _getTotalUsers() async {
    final customerCount = await _count(
      _firestore.collection('profiles').where('role', isEqualTo: 'customer'),
    );

    final riderCount = await _count(
      _firestore.collection('profiles').where('role', isEqualTo: 'rider'),
    );

    return customerCount + riderCount;
  }

  Future<int> _getOnlineDrivers() {
    return _count(
      _firestore
          .collection('profiles')
          .where('role', isEqualTo: 'driver')
          .where('account.isOnline', isEqualTo: true),
    );
  }

  // ============================================================
  // SUPPORT
  // ============================================================

  Future<int> _getUnansweredSupport() {
    return _count(
      _firestore
          .collection('supportChats')
          .where('lastMessageSender', isEqualTo: 'user'),
    );
  }
}
