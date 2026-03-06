import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/screens/rental/widgets/car_booking_page.dart'
    show DeliveryType;
import 'package:kipgo/screens/rental/widgets/car_delivery_widget.dart';
import 'package:kipgo/screens/rental/widgets/schedule_selector.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';

class ScheduleBookingDetails extends StatelessWidget {
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final double rentalPrice;
  final double deliveryPrice;
  final TextEditingController deliveryAddress;
  final TextEditingController additionalNote;
  final DeliveryType deliveryType;
  final int rentalDays;
  final double dailyPrice;
  final Function(DateTime, DateTime, int) onDateChanged;
  final ValueChanged<DeliveryType> onDeliveryTypeChanged;

  const ScheduleBookingDetails({
    super.key,
    required this.pickupDate,
    required this.dropoffDate,
    required this.rentalPrice,
    required this.deliveryPrice,
    required this.deliveryAddress,
    required this.additionalNote,
    required this.deliveryType,
    required this.onDateChanged,
    required this.onDeliveryTypeChanged,
    required this.rentalDays,
    required this.dailyPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rental Date", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        ScheduleSelector(
          pickupDate: pickupDate,
          dropoffDate: dropoffDate,
          dailyPrice: 1200,
          minimumRentalDays: 3,
          onChanged: onDateChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: 6),
                Text(
                  "$rentalDays Day${rentalDays > 1 ? 's' : ''}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              NumberFormat.currency(
                locale: 'en',
                symbol: '₺',
              ).format(rentalPrice),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                // color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "₺$dailyPrice x $rentalDays days",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),

        SizedBox(height: 15),
        Text("Receive Via", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        CarDeliveryWidget(
          deliveryType: deliveryType,
          deliveryFee: deliveryPrice,
          deliveryAddress: deliveryAddress,
          onChanged: onDeliveryTypeChanged,
        ),
        TextField(
          controller: additionalNote,
          minLines: 2,
          maxLines: 2,
          decoration: inputDecoration(
            context: context,
            hint: "Additional note",
          ),
        ),
      ],
    );
  }
}
