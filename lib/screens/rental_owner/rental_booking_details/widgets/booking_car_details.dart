import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:provider/provider.dart';

class BookingCarDetails extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const BookingCarDetails({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.car.year} ${booking.car.brand} ${booking.car.model}',
              ),
              SizedBox(height: 8),
              Text(
                "${formatDate(context, booking.pickupDate)} → ${formatDate(context, booking.dropoffDate)}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall!.color!.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${AppLocalizations.of(context)!.invoiceNumber}: ${booking.invoiceNumber}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall!.color!.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          formatCurrency(
            amount: booking.totalPrice,
            currencyCode: booking.currency,
            context: context,
          ),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            // color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
