import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/location_picker_sheet.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_app_bottom_sheet.dart';

class LocationPicker {
  static Future<ShuttleLocation?> show(
    BuildContext context,
    String title,
    String hint,
  ) {
    return ShuttleAppBottomSheet.show(
      context: context,

      title: title,

      child: LocationPickerSheet(hint: hint),
    );
  }
}
