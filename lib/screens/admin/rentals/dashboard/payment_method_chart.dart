import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/utils/colors.dart';

class PaymentMethodChart extends StatelessWidget {
  final int cryptoBookings;
  final int cashBookings;

  const PaymentMethodChart({
    super.key,
    required this.cryptoBookings,
    required this.cashBookings,
  });

  @override
  Widget build(BuildContext context) {
    final total = cryptoBookings + cashBookings;

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 65,
              sectionsSpace: 4,
              borderData: FlBorderData(show: false),
              sections: [
                PieChartSectionData(
                  value: cryptoBookings.toDouble(),
                  title: total == 0
                      ? '0%'
                      : '${((cryptoBookings / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  color: AppColors.primary,
                ),

                PieChartSectionData(
                  value: cashBookings.toDouble(),
                  title: total == 0
                      ? '0%'
                      : '${((cashBookings / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                total.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text('Bookings', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
