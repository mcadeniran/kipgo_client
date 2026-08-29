import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/badges/payment_method_badge.dart';
import 'package:kipgo/badges/payment_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental/widgets/car_review_page.dart';
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

  bool get isCompleted => booking.status == 'completed';

  bool get isRated => booking.isRated;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final cardColor = isDark ? AppColors.darkAccent : theme.cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : AppColors.border.withValues(alpha: .45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .18 : .055),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsPage(booking: booking),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehicleHeader(context, isDark, loc),

                const SizedBox(height: 16),

                _buildBookingDates(context, isDark),

                const SizedBox(height: 10),

                _buildDeliveryInfo(context, isDark),

                const SizedBox(height: 14),

                _buildDivider(isDark),

                const SizedBox(height: 14),

                _buildPaymentSection(context, isDark),

                const SizedBox(height: 14),

                _buildBottomSection(context, isDark, loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCarImage(isDark),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${booking.car.brand} ${booking.car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BookingStatusBadge(status: booking.status),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                '${booking.car.year} • ${carPropertiesTranslations(context, booking.car.transmission)} • ${loc.numOfSeats(booking.car.seats)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: .55)
                      : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: .45)
                        : Colors.black45,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${loc.ref}: ${booking.invoiceNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: .45)
                            : Colors.black45,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarImage(bool isDark) {
    return Container(
      width: 92,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: isDark
            ? Colors.white.withValues(alpha: .05)
            : Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        booking.car.carImage,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Image.asset(
            'assets/images/image_spinner.gif',
            fit: BoxFit.cover,
          );
        },
        errorBuilder: (_, _, _) {
          return Image.asset(
            'assets/images/placeholder.jpeg',
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildBookingDates(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .035)
            : AppColors.primary.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .045)
              : AppColors.primary.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          _buildInfoIcon(icon: Icons.calendar_month_rounded, isDark: isDark),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(context, booking.pickupDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: .55),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(context, booking.dropoffDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: .52)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildDaysBadge(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDaysBadge(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            '$rentalDays',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.lightLayer : AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            loc.numDays(rentalDays),
            // rentalDays == 1 ? 'day' : 'days',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: .5)
                  : Colors.black45,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _buildInfoIcon(icon: Icons.location_on_outlined, isDark: isDark),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carPropertiesTranslations(context, booking.deliveryType),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (booking.deliveryAddress.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    booking.deliveryAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: .48)
                          : Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoIcon({required IconData icon, required bool isDark}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: .12)
            : AppColors.primary.withValues(alpha: .065),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark ? AppColors.lightLayer : AppColors.primary,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withValues(alpha: .06)
          : AppColors.border.withValues(alpha: .55),
    );
  }

  Widget _buildPaymentSection(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: .035)
                : Colors.grey.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(11),
          ),
          child: PaymentMethodBadge(method: booking.payment!.method),
        ),

        const SizedBox(width: 7),

        PaymentStatusBadge(status: booking.payment!.status),

        const Spacer(),

        Text(
          formatCurrency(
            amount: booking.totalPrice,
            currencyCode: booking.currency,
            context: context,
          ),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    if (!isCompleted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTapHint(context, isDark),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark
                ? Colors.white.withValues(alpha: .35)
                : Colors.black38,
          ),
        ],
      );
    }

    if (isRated) {
      return _buildReviewedState(context, isDark, loc);
    }

    return _buildLeaveReviewButton(context, isDark, loc);
  }

  Widget _buildTapHint(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.touch_app_outlined,
          size: 16,
          color: isDark ? Colors.white.withValues(alpha: .35) : Colors.black38,
        ),
        const SizedBox(width: 6),
        Text(
          loc.viewDetails,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white.withValues(alpha: .4) : Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveReviewButton(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: .86)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? .18 : .13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarReviewPage(booking: booking),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.leaveAReview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewedState(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: isDark ? .10 : .07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.green.withValues(alpha: isDark ? .18 : .12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.reviewSubmitted,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.green.shade300
                        : Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.thankYouForReview,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: .45)
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
        ],
      ),
    );
  }
}
