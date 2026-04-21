import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:intl/intl.dart';
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

  Color _statusColor() {
    switch (booking.status) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'confirmed':
        return Colors.blue.shade100;
      case 'ongoing':
        return Colors.purple.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _statusTextColor() {
    switch (booking.status) {
      case 'pending':
        return Colors.yellow.shade700;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'ongoing':
        return Colors.purple.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String formatDate(BuildContext context, DateTime date) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          children: [
            /// 🔹 Top Row (Car + Status)
            Row(
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
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${booking.car.brand} ${booking.car.model} ${booking.car.year}",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w600),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        // _statusText(context),
                        carPropertiesTranslations(context, booking.status),
                        style: TextStyle(
                          color: _statusTextColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
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

            const SizedBox(height: 16),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 12),

            /// 🔹 Price + Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.status == 'ongoing' ||
                              booking.status == 'completed'
                          ? loc.totalPaid
                          : loc.totalDue,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(
                        amount: booking.totalPrice,
                        currencyCode: booking.currency,
                        context: context,
                      ),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        // color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                TextButton(onPressed: () {}, child: Text(loc.viewDetails)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
