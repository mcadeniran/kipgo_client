import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental_owner/widgets/chart_range_selector.dart';
import 'package:kipgo/screens/rental_owner/widgets/revenue_chart.dart';

class RevenueChartSection extends StatefulWidget {
  const RevenueChartSection({super.key});

  @override
  State<RevenueChartSection> createState() => _RevenueChartSectionState();
}

class _RevenueChartSectionState extends State<RevenueChartSection> {
  int selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.revenue,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ChartRangeSelector(
              selectedDays: selectedDays,
              onChanged: (days) {
                setState(() => selectedDays = days);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// CHART
        RevenueChart(days: selectedDays),
      ],
    );
  }
}
