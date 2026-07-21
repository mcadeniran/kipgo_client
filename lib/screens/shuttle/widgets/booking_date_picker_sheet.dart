import 'package:flutter/material.dart';

class BookingDatePickerSheet extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  const BookingDatePickerSheet({
    super.key,
    this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Here we'll embed your existing calendar widget
    // or build a reusable calendar configured with:
    // firstDate = DateTime.now().add(const Duration(days: 1))
    // lastDate = DateTime.now().add(const Duration(days: 365))
    //
    // The selected date is returned via onSelected.
    return const SizedBox.shrink();
  }
}
