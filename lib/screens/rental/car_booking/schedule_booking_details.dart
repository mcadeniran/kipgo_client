import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/screens/rental/car_booking/availability_calendar.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart'
    show DeliveryType;
import 'package:kipgo/screens/rental/car_booking/car_delivery_widget.dart';
// import 'package:kipgo/screens/rental/car_booking/schedule_selector.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
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
  final String currency;
  final Function(DateTime, DateTime, int) onDateChanged;
  final ValueChanged<DeliveryType> onDeliveryTypeChanged;
  final List<BookingModel> bookings;
  final List<CarUnit> units;
  final bool offersDelivery;

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
    required this.currency,
    required this.bookings,
    required this.units,
    required this.offersDelivery,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.rentalDate, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        // ScheduleSelector(
        //   pickupDate: pickupDate,
        //   dropoffDate: dropoffDate,
        //   dailyPrice: dailyPrice.toInt(),
        //   minimumRentalDays: 3,
        //   onChanged: onDateChanged,
        // ),
        AvailabilityCalendar(
          units: units,
          bookings: bookings,
          minimumRentalDays: 3,

          initialPickup: pickupDate,
          initialDropoff: dropoffDate,

          onRangeSelected: (pickup, dropoff, chargeableDays) {
            final totalPrice = chargeableDays * dailyPrice.toInt();

            onDateChanged(pickup, dropoff, totalPrice);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: 6),
                Text(
                  loc.multiRentalDay(rentalDays),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              formatCurrency(
                amount: rentalPrice,
                currencyCode: currency,
                context: context,
              ),
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
          "${formatCurrency(amount: dailyPrice, currencyCode: currency, context: context)} x ${loc.multiRentalDay(rentalDays)}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),

        SizedBox(height: 15),
        Text(loc.receiveVia, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        CarDeliveryWidget(
          deliveryType: deliveryType,
          deliveryFee: deliveryPrice,
          deliveryAddress: deliveryAddress,
          onChanged: onDeliveryTypeChanged,
          offersDelivery: offersDelivery,
          currency: currency,
        ),
        TextField(
          controller: additionalNote,
          minLines: 2,
          maxLines: 2,
          decoration: inputDecoration(
            context: context,
            hint: loc.additionalNote,
          ),
        ),
      ],
    );
  }
}
