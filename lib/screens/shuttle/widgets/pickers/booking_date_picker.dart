import 'package:flutter/material.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_date_sheet.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_app_bottom_sheet.dart';

class BookingDatePicker {
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? selectedDate,
    bool allowToday = false,
    String title = "Departure Date",
  }) {
    return ShuttleAppBottomSheet.show<DateTime>(
      context: context,
      title: title,
      child: BookingDateSheet(
        selectedDate: selectedDate,
        allowToday: allowToday,
      ),
    );
  }
}
