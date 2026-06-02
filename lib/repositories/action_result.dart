import 'package:kipgo/helpers/booking_action_result_code.dart';

class ActionResult {
  final bool success;
  final BookingActionResultCode code;

  const ActionResult({required this.success, required this.code});
}
