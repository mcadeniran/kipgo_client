import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/screens/rental/widgets/car_booking_page.dart';
import 'package:kipgo/utils/colors.dart';

class BookingSummary extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String carName;
  final String carColour;
  final int carSeats;
  final String transmission;
  final String fuelType;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final int rentalDays;
  final DeliveryType deliveryType;
  final String deliveryAddress;
  final String additionalNote;
  final double rentalPrice;
  final double deliveryPrice;
  final int deposit;
  final double tax;
  final double dailyPrice;

  const BookingSummary({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.carName,
    required this.carColour,
    required this.carSeats,
    required this.transmission,
    required this.pickupDate,
    required this.dropoffDate,
    required this.rentalDays,
    required this.deliveryType,
    required this.deliveryAddress,
    required this.additionalNote,
    required this.rentalPrice,
    required this.deliveryPrice,
    required this.deposit,
    required this.tax,
    required this.fuelType,
    required this.dailyPrice,
  });

  @override
  Widget build(BuildContext context) {
    late final double tempDelivery = deliveryType == DeliveryType.delivery
        ? deliveryPrice
        : 0;

    late final double preTax = rentalPrice + deposit + tempDelivery;

    late final double taxAmount = tax * preTax;

    late final double totalPrice = preTax + taxAmount;

    Widget rowBuilder(String title, String details) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            details,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DRIVER'S DETAILS
        Text(
          "Driver's Details",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        rowBuilder('Name', name),
        SizedBox(height: 5),
        rowBuilder('Phone', phone),
        SizedBox(height: 5),
        rowBuilder('Email', email),
        SizedBox(height: 5),
        rowBuilder('Driver License', 'preview'),
        SizedBox(height: 5),
        rowBuilder('ID', 'preview'),
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // CAR DETAILS
        Text("Car Details", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        rowBuilder('Name', carName),
        SizedBox(height: 5),
        rowBuilder('Colour', carColour),
        SizedBox(height: 5),
        rowBuilder('Seats', carSeats.toString()),
        SizedBox(height: 5),
        rowBuilder('Transmission', transmission),
        SizedBox(height: 5),
        rowBuilder('Fuel', fuelType),
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // BOOKING DETAILS
        Text("Booking Details", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        rowBuilder(
          'Pickup Date',
          DateFormat('dd MMMM, yyyy').format(pickupDate),
        ),
        SizedBox(height: 5),
        rowBuilder(
          'Drop-off Date',
          DateFormat('dd MMMM, yyyy').format(dropoffDate),
        ),
        SizedBox(height: 5),
        rowBuilder('Total Duration', '$rentalDays Days'),
        SizedBox(height: 5),
        rowBuilder('Delivery Type', deliveryType.name),
        if (deliveryType == DeliveryType.delivery) ...[
          SizedBox(height: 5),
          rowBuilder('Dropoff Address', deliveryAddress),
        ],
        if (additionalNote.trim() != '') ...[
          SizedBox(height: 5),
          rowBuilder('Additional Note', additionalNote),
        ],
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // PRICE DETAILS
        Text("Price Details", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        rowBuilder(
          'Rental Price',
          '${formatCurrency(dailyPrice)} x $rentalDays days',
        ),
        SizedBox(height: 2),
        rowBuilder('', formatCurrency(rentalPrice)),
        SizedBox(height: 5),
        if (deliveryType == DeliveryType.delivery) ...[
          rowBuilder('Delivery Price', formatCurrency(deliveryPrice)),
          SizedBox(height: 5),
        ],
        rowBuilder('Deposit (Refundable)', formatCurrency(deposit * 1.0)),
        SizedBox(height: 5),
        rowBuilder('Total (Pre-Tax)', formatCurrency(preTax)),
        SizedBox(height: 5),
        rowBuilder('Tax (${100 * tax}%)', formatCurrency(taxAmount)),
        SizedBox(height: 5),
        const Divider(thickness: 1.2),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grand Total',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              formatCurrency(totalPrice),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                // color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en', symbol: '₺').format(amount);
  }
}
