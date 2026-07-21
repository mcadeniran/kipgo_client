import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/badges/payment_method_badge.dart';
import 'package:kipgo/badges/payment_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_rental_booking_details_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminBookingCard extends StatelessWidget {
  final BookingModel booking;

  const AdminBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    String formatDate(BuildContext context, DateTime date) {
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      return DateFormat('EEE, MMM d • HH:mm', '$locale').format(date);
    }

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
                  AdminRentalBookingDetailsPage(bookingId: booking.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.car.carImage,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 60,
                    gaplessPlayback: true,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return Image.asset(
                        "assets/images/image_spinner.gif",
                        fit: BoxFit.cover,
                        width: 80,
                        height: 60,
                      );
                    },
                    errorBuilder: (_, _, _) => Image.asset(
                      "assets/images/placeholder.jpeg",
                      fit: BoxFit.cover,
                      width: 80,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${booking.car.brand} ${booking.car.model}  ${booking.car.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        booking.shop.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 10),

            /// 🔹 CUSTOMER
            Text(
              booking.driver.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(booking.driver.phone),

            const SizedBox(height: 10),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 10),

            /// 🔹 DATES
            Column(
              children: [
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
                SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      carPropertiesTranslations(context, booking.deliveryType),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 0, height: 0, color: AppColors.border),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PaymentMethodBadge(method: booking.payment!.method),
                PaymentStatusBadge(status: booking.payment!.status),
              ],
            ),

            const SizedBox(height: 0),

            /// 🔹 PRICE
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
