import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/payment_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_crypto_payment_details_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CryptoPaymentSlip extends StatelessWidget {
  final BookingModel booking;
  const CryptoPaymentSlip({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;

    final DateTime? time = booking.payment!.crypto!.txidSubmittedAt;
    final String formattedTime = time != null ? timeago.format(time) : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminCryptoPaymentDetailsPage(bookingId: booking.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.shop.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${booking.payment!.crypto!.amount.toStringAsFixed(2)} USDT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.driver.name,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  formatCurrency(
                    amount: booking.totalPrice,
                    currencyCode: booking.currency,
                    context: context,
                  ),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall!.color!.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.invoiceNumber,
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                Text(
                  "Fee: ${booking.payment!.crypto!.networkFee} USDT",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall!.color!.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4),

            Divider(color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                PaymentStatusBadge(status: booking.payment!.status),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time != null
                          ? DateFormat('dd MMM • HH:mm', '$locale').format(time)
                          : '',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall!.color!.withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall!.color!.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
