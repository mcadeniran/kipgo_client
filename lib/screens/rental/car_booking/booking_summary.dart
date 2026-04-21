import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingSummary extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String carName;
  final File? licenseFrontFile;
  final File? licenseBackFile;
  final File? idCardFile;
  final String? licenseFrontUrl;
  final String? licenseBackUrl;
  final String? idCardUrl;
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
  final double deposit;
  final double tax;
  final double dailyPrice;
  final String currency;

  const BookingSummary({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.carName,
    // required this.carColour,
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
    required this.licenseFrontUrl,
    required this.licenseBackUrl,
    required this.idCardUrl,
    required this.licenseFrontFile,
    required this.licenseBackFile,
    required this.idCardFile,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    late final double tempDelivery = deliveryType == DeliveryType.delivery
        ? deliveryPrice
        : 0;

    late final double preTax = rentalPrice + tempDelivery;

    late final double taxAmount = tax * preTax;

    late final double totalPrice = preTax + taxAmount + deposit;

    AppLocalizations loc = AppLocalizations.of(context)!;
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;

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
    Widget imageRowBuilder(String title, Widget details) => Row(
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
        details,
      ],
    );

    Widget imagePreview(String? url, File? file) {
      if (url == null && file == null) return Text(loc.notUploaded);

      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: file != null
                  ? Image.file(File(file.path))
                  : Image.network(url!),
            ),
          );
        },
        child: Text(loc.view, style: TextStyle(color: Colors.blue)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DRIVER'S DETAILS
        Text(
          loc.driversDetails,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        rowBuilder(loc.name, name),
        SizedBox(height: 5),
        rowBuilder(loc.phone, phone),
        SizedBox(height: 5),
        rowBuilder(loc.email, email),
        SizedBox(height: 5),
        // rowBuilder('Driver License (Front)', imagePreview(  licenseFrontUrl)),
        imageRowBuilder(
          loc.driverLicenseFront,
          imagePreview(licenseFrontUrl, licenseFrontFile),
        ),
        SizedBox(height: 5),
        imageRowBuilder(
          loc.driverLicenseBack,
          imagePreview(licenseBackUrl, licenseBackFile),
        ),
        // rowBuilder('Driver License (Back)', imagePreview(  licenseBackUrl)),
        SizedBox(height: 5),
        imageRowBuilder(loc.id, imagePreview(idCardUrl, idCardFile)),
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // CAR DETAILS
        Text(loc.carDetails, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        rowBuilder(loc.name, carName),
        // SizedBox(height: 5),
        // rowBuilder('Colour', carColour),
        SizedBox(height: 5),
        rowBuilder(loc.seatsLabel, carSeats.toString()),
        SizedBox(height: 5),
        rowBuilder(
          loc.transmission,
          carPropertiesTranslations(context, transmission),
        ),
        SizedBox(height: 5),
        rowBuilder(loc.fuel, carPropertiesTranslations(context, fuelType)),
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // BOOKING DETAILS
        Text(
          loc.bookingDetails,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        rowBuilder(
          loc.pickupDate,
          // DateFormat('dd MMMM, yyyy').format(pickupDate),
          DateFormat('dd MMM yyyy • HH:mm', '$locale').format(pickupDate),
        ),
        SizedBox(height: 5),
        rowBuilder(
          loc.dropoffDate,
          // DateFormat('dd MMMM, yyyy').format(dropoffDate),
          DateFormat('dd MMM yyyy • HH:mm', '$locale').format(dropoffDate),
        ),
        SizedBox(height: 5),
        rowBuilder(loc.totalDuration, loc.multiRentalDay(rentalDays)),
        SizedBox(height: 5),
        rowBuilder(
          loc.deliveryType,
          carPropertiesTranslations(context, deliveryType.name),
        ),
        if (deliveryType == DeliveryType.delivery) ...[
          SizedBox(height: 5),
          rowBuilder(loc.dropoffAddress, deliveryAddress),
        ],
        if (additionalNote.trim() != '') ...[
          SizedBox(height: 5),
          rowBuilder(loc.additionalNote, additionalNote),
        ],
        SizedBox(height: 5),
        Divider(thickness: 0, color: AppColors.border),
        SizedBox(height: 5),

        // PRICE DETAILS
        Text(loc.priceDetails, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 10),
        rowBuilder(
          loc.rentalPrice,
          '${formatCurrency(amount: dailyPrice, currencyCode: currency, context: context)} x ${loc.multiRentalDay(rentalDays)}',
        ),
        SizedBox(height: 2),
        rowBuilder(
          '',
          formatCurrency(
            amount: rentalPrice,
            currencyCode: currency,
            context: context,
          ),
        ),
        SizedBox(height: 5),
        if (deliveryType == DeliveryType.delivery) ...[
          rowBuilder(
            loc.deliveryPrice,
            formatCurrency(
              amount: deliveryPrice,
              currencyCode: currency,
              context: context,
            ),
          ),
          SizedBox(height: 5),
        ],
        rowBuilder(
          loc.depositRefundable,
          formatCurrency(
            amount: deposit * 1.0,
            currencyCode: currency,
            context: context,
          ),
        ),
        SizedBox(height: 5),
        rowBuilder(
          loc.totalPreTax,
          formatCurrency(
            amount: preTax,
            currencyCode: currency,
            context: context,
          ),
        ),
        SizedBox(height: 5),
        rowBuilder(
          '${loc.tax} (${100 * tax}%)',
          formatCurrency(
            amount: taxAmount,
            currencyCode: currency,
            context: context,
          ),
        ),
        SizedBox(height: 5),
        const Divider(thickness: 1.2),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.grandTotal,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              formatCurrency(
                amount: totalPrice,
                currencyCode: currency,
                context: context,
              ),
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
}
