import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RevenueChart extends StatelessWidget {
  final int days;

  const RevenueChart({super.key, this.days = 7});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final data = bookingProvider.getRevenueChart(days: days);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final spots = List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), (data[index]['value'] as double));
    });

    return Container(
      width: double.maxFinite,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.length) return const SizedBox();

                  final date = data[index]['date'] as DateTime;

                  return Text("${date.day}/${date.month}");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
              preventCurveOverShooting: true,
            ),
          ],
        ),
      ),
    );
  }
}
