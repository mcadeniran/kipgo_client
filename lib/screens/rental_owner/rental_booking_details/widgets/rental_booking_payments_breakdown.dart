import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';

class RentalBookingPaymentsBreakdown extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalBookingPaymentsBreakdown({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        rentalPaymentCard(
          title: loc.rentalPrice,
          details: formatCurrency(
            amount: booking.rentalPrice,
            currencyCode: booking.currency,
            context: context,
          ),
        ),
        SizedBox(height: 8),
        if (booking.deliveryType == 'delivery') ...[
          rentalPaymentCard(
            title: loc.deliveryPrice,
            details: formatCurrency(
              amount: booking.deliveryPrice,
              currencyCode: booking.currency,
              context: context,
            ),
          ),
          SizedBox(height: 8),
        ],
        rentalPaymentCard(
          title: loc.depositRefundable,
          details: formatCurrency(
            amount: booking.deposit,
            currencyCode: booking.currency,
            context: context,
          ),
        ),
        SizedBox(height: 8),
        rentalPaymentCard(
          title: loc.totalPreTax,
          details: formatCurrency(
            amount: booking.preTax,
            currencyCode: booking.currency,
            context: context,
          ),
        ),
        SizedBox(height: 8),
        rentalPaymentCard(
          title: '${loc.tax} (${100 * booking.taxRate}%)',
          details: formatCurrency(
            amount: booking.tax,
            currencyCode: booking.currency,
            context: context,
          ),
        ),
        SizedBox(height: 4),
        Divider(thickness: 1.2, color: AppColors.border),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.grandTotal,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              formatCurrency(
                amount: booking.totalPrice,
                currencyCode: booking.currency,
                context: context,
              ),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Row rentalPaymentCard({required String title, required String details}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(details),
      ],
    );
  }
}
