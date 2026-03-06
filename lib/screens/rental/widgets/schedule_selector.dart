import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ScheduleSelector extends StatelessWidget {
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final int dailyPrice;
  final int minimumRentalDays;
  final Function(DateTime pickup, DateTime dropoff, int totalPrice) onChanged;
  const ScheduleSelector({
    super.key,
    required this.pickupDate,
    required this.dropoffDate,
    required this.dailyPrice,
    required this.minimumRentalDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    void showMinimumError() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Minimum rental duration is $minimumRentalDays days"),
          backgroundColor: Colors.red,
        ),
      );
    }

    Future<void> selectDateRange() async {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        initialDateRange: DateTimeRange(start: pickupDate, end: dropoffDate),
        locale: locale,
        helpText: 'Select Rental Period',
        barrierColor: AppColors.primary,
        builder: (context, child) => Theme(
          data: ThemeData().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.primary,
              onSurface: Colors.black87,
              secondary: AppColors.lightLayer,
            ),
          ),
          child: child!,
        ),
      );

      if (picked != null) {
        final int selectedDays = picked.end.difference(picked.start).inDays;

        if (selectedDays < minimumRentalDays) {
          showMinimumError();
          return;
        }
        int totalPrice = selectedDays * dailyPrice;

        onChanged(picked.start, picked.end, totalPrice);
      }
    }

    String formatDate(DateTime date) {
      return DateFormat('EEE, MMM d').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Segmented Control
        GestureDetector(
          onTap: selectDateRange,
          child: Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentBox(
                    title: "Pickup",
                    value: formatDate(pickupDate),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SegmentBox(
                    title: "Drop-off",
                    value: formatDate(dropoffDate),
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Text(
        //   "₺${widget.dailyPrice} x $rentalDays days",
        //   style: const TextStyle(fontSize: 12, color: Colors.grey),
        // ),
      ],
    );
  }
}

class _SegmentBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SegmentBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
