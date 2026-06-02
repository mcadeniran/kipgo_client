import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/badges/payment_method_badge.dart';
import 'package:kipgo/badges/payment_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental/widgets/car_rating_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingHistoryCard extends StatelessWidget {
  final BookingModel booking;
  final int rentalDays;
  const BookingHistoryCard({
    super.key,
    required this.booking,
    required this.rentalDays,
  });

  String formatDate(BuildContext context, DateTime date) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsPage(booking: booking),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// 🔹 Top Row (Car + Status)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FadeInImage.assetNetwork(
                    fadeInCurve: Curves.easeIn,
                    fadeInDuration: Duration(seconds: 2),
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: "assets/images/image_spinner.gif",
                    image: booking.car.carImage,
                    imageErrorBuilder: (c, e, s) => Image.asset(
                      "assets/images/placeholder.jpeg",
                      height: 60,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${booking.car.brand} ${booking.car.model} ${booking.car.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${loc.ref}: ${booking.invoiceNumber}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 6),
                    if (booking.status == 'completed' &&
                        booking.isRated == true) ...[
                      StarRating(
                        starCount: 5,
                        rating: booking.rating.carRating,
                        allowHalfRating: true,
                        color: Colors.amber,
                      ),
                    ],
                    if (booking.status == 'completed' &&
                        booking.isRated == false) ...[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarRatingPage(
                                bookingId: booking.id,
                                carId: booking.carId,
                                shopId: booking.shopId,
                              ),
                            ),
                          );
                        },
                        child: Text(loc.rateNow),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 12),

            /// 🔹 Booking Info
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${formatDate(context, booking.pickupDate)} → ${formatDate(context, booking.dropoffDate)}",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 18),
                const SizedBox(width: 8),
                Text(carPropertiesTranslations(context, booking.deliveryType)),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PaymentMethodBadge(method: booking.payment!.method),
                PaymentStatusBadge(status: booking.payment!.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                BookingStatusBadge(status: booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
