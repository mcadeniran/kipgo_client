import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/screens/admin/rentals/dashboard/dashboard_stat_card.dart';
import 'package:kipgo/screens/admin/rentals/dashboard/payment_method_chart.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminRentalDashboard extends StatelessWidget {
  const AdminRentalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BookingProvider>();

    final totalBookings = provider.adminBookings.length;
    final activeBookings = provider.adminOngoing.length;
    final pendingBookings = provider.adminAttention.length;
    final upcomingBookings = provider.adminUpcoming.length;

    // List<FlSpot> spots = [];

    final cryptoBookings = provider.adminBookings
        .where((b) => b.payment!.method == 'crypto')
        .length;
    final cashBookings = provider.adminBookings
        .where((b) => b.payment!.method == 'payOnPickup')
        .length;

    final now = DateTime.now();

    final paidBookings = provider.adminBookings.where(
      (b) =>
          // b.payment?.completed == true ||
          // b.payment?.status == 'paid' ||
          b.status == 'completed',
    );

    final monthlyRevenue = paidBookings.where(
      (b) =>
          b.completedAt!.year == now.year && b.completedAt!.month == now.month,
    );

    // final monthlyBookings = paidBookings.where(
    //   (b) => b.createdAt!.year == now.year && b.createdAt!.month == now.month,
    // );

    double usdRev = 0;
    double tryRev = 0;
    double eurRev = 0;
    double gbpRev = 0;

    for (final b in monthlyRevenue) {
      switch (b.currency) {
        case 'USD':
          usdRev += b.totalPrice;
          break;
        case 'TRY':
          tryRev += b.totalPrice;
          break;
        case 'EUR':
          eurRev += b.totalPrice;
          break;
        case 'GBP':
          gbpRev += b.totalPrice;
          break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                DashboardStatCard(
                  title: "USD Revenue",
                  value: formatCurrency(
                    amount: usdRev,
                    currencyCode: 'USD',
                    context: context,
                    decimalDigits: 0,
                  ),
                  // icon: Icons.attach_money,
                  color: Colors.green,
                ),

                DashboardStatCard(
                  title: "TRY Revenue",
                  // value: tryRev.toString(),
                  value: formatCurrency(
                    amount: tryRev,
                    currencyCode: 'TRY',
                    context: context,
                    decimalDigits: 0,
                  ),
                  // icon: Icons.currency_lira,
                  color: Colors.green,
                ),

                DashboardStatCard(
                  title: "GBP Revenue",
                  value: formatCurrency(
                    amount: gbpRev,
                    currencyCode: 'GBP',
                    context: context,
                    decimalDigits: 0,
                  ),
                  // icon: Icons.currency_pound_outlined,
                  color: Colors.green,
                ),

                DashboardStatCard(
                  title: "EUR Revenue",
                  value: formatCurrency(
                    amount: eurRev,
                    currencyCode: 'EUR',
                    context: context,
                    decimalDigits: 0,
                  ),
                  // icon: Icons.euro,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                DashboardStatCard(
                  title: "Total Bookings",
                  value: totalBookings.toString(),
                  icon: Icons.attach_money,
                  color: AppColors.tertiary,
                ),

                DashboardStatCard(
                  title: "Active Rentals",
                  value: activeBookings.toString(),
                  icon: Icons.directions_car,
                  color: Colors.green,
                ),

                DashboardStatCard(
                  title: "Upcoming",
                  value: upcomingBookings.toString(),
                  icon: Icons.calendar_month,
                  color: AppColors.primary,
                ),

                DashboardStatCard(
                  title: "Awaiting Review",
                  value: pendingBookings.toString(),
                  icon: Icons.payments,
                  color: AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            DashboardSection(
              title: "Payment Methods",
              child: Column(
                children: [
                  PaymentMethodChart(
                    cryptoBookings: cryptoBookings,
                    cashBookings: cashBookings,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem(
                        color: AppColors.primary,
                        label: 'Crypto',
                        value: cryptoBookings,
                      ),

                      _LegendItem(
                        color: AppColors.secondary,
                        label: 'Pay on Pickup',
                        value: cashBookings,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,

      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkAccent
            : Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 8),

        Text('$label ($value)'),
      ],
    );
  }
}
