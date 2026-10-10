class AdminTaxiOperations {
  final int todayRides;
  final int completedToday;
  final int cancelledToday;
  final int onlineDrivers;

  const AdminTaxiOperations({
    required this.todayRides,
    required this.completedToday,
    required this.cancelledToday,
    required this.onlineDrivers,
  });
}

class AdminRentalOperations {
  final int todayBookings;
  final int pending;
  final int paymentSubmitted;
  final int ongoing;
  final int completedToday;

  const AdminRentalOperations({
    required this.todayBookings,
    required this.pending,
    required this.paymentSubmitted,
    required this.ongoing,
    required this.completedToday,
  });

  int get attention => pending + paymentSubmitted;
}

class AdminShuttleOperations {
  final int todayBookings;
  final int pending;
  final int paymentSubmitted;
  final int upcoming;
  final int inProgress;
  final int completedToday;

  const AdminShuttleOperations({
    required this.todayBookings,
    required this.pending,
    required this.paymentSubmitted,
    required this.upcoming,
    required this.inProgress,
    required this.completedToday,
  });

  int get attention => pending + paymentSubmitted;
}

class AdminOperationsModel {
  final AdminTaxiOperations taxi;
  final AdminRentalOperations rental;
  final AdminShuttleOperations shuttle;

  const AdminOperationsModel({
    required this.taxi,
    required this.rental,
    required this.shuttle,
  });

  int get totalAttention => rental.attention + shuttle.attention;

  int get totalTodayActivity =>
      taxi.todayRides + rental.todayBookings + shuttle.todayBookings;
}
