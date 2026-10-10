class AdminDashboardModel {
  final int todayRides;
  final int todayRentalBookings;
  final int todayShuttleBookings;

  final int totalUsers;
  final int onlineDrivers;
  final int unansweredSupport;

  final int completedRides;
  final int completedRentalBookings;
  final int completedShuttleBookings;

  final double todayTaxiRevenue;
  final double todayRentalRevenue;
  final double todayShuttleRevenue;

  const AdminDashboardModel({
    required this.todayRides,
    required this.todayRentalBookings,
    required this.todayShuttleBookings,
    required this.totalUsers,
    required this.onlineDrivers,
    required this.unansweredSupport,
    required this.completedRides,
    required this.completedRentalBookings,
    required this.completedShuttleBookings,
    required this.todayTaxiRevenue,
    required this.todayRentalRevenue,
    required this.todayShuttleRevenue,
  });

  const AdminDashboardModel.empty()
    : todayRides = 0,
      todayRentalBookings = 0,
      todayShuttleBookings = 0,
      totalUsers = 0,
      onlineDrivers = 0,
      unansweredSupport = 0,
      completedRides = 0,
      completedRentalBookings = 0,
      completedShuttleBookings = 0,
      todayTaxiRevenue = 0,
      todayRentalRevenue = 0,
      todayShuttleRevenue = 0;

  int get totalTodayActivity =>
      todayRides + todayRentalBookings + todayShuttleBookings;

  double get totalTodayRevenue =>
      todayTaxiRevenue + todayRentalRevenue + todayShuttleRevenue;
}
