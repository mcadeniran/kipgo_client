class DashboardStats {
  final int totalBookings;
  final int activeBookings;
  final int upcomingBookings;
  final int pendingPayments;

  final double totalRevenue;
  final double monthlyRevenue;

  final int totalUnits;
  final int reservedUnits;
  final int ongoingUnits;

  DashboardStats({
    required this.totalBookings,
    required this.activeBookings,
    required this.upcomingBookings,
    required this.pendingPayments,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalUnits,
    required this.reservedUnits,
    required this.ongoingUnits,
  });
}
