import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/booking_status_badge.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/statuses.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental/bookings/widgets/timeline_item.dart';
import 'package:kipgo/screens/rental/bookings/widgets/user_booking_status_message.dart';
import 'package:kipgo/screens/rental/car_booking/crypto_payment_page.dart';
import 'package:kipgo/screens/rental/widgets/car_review_page.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/map_utils.dart';
import 'package:provider/provider.dart';

enum BookingStepStatus { completed, current, pending, rejected }

class BookingDetailsPage extends StatefulWidget {
  final BookingModel? booking;
  final String? bookingId;

  const BookingDetailsPage({super.key, this.booking, this.bookingId})
    : assert(
        booking != null || bookingId != null,
        "Either booking or bookingId must be provided",
      );

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  BookingModel? booking;
  bool isLoading = true;
  late int rentalDays;
  late AppLocalizations loc;

  Timer? _expiryTimer;
  Duration _remaining = Duration.zero;

  bool _expiring = false;

  @override
  void initState() {
    super.initState();

    if (widget.booking != null) {
      booking = widget.booking;
      rentalDays = booking!.dropoffDate.difference(booking!.pickupDate).inDays;
      startExpiryTimer();
      isLoading = false;
    } else {
      fetchBooking();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  Future<void> fetchBooking() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final fetchedBooking = BookingModel.fromFirestore(doc);

        setState(() {
          booking = fetchedBooking;
          rentalDays = fetchedBooking.dropoffDate
              .difference(fetchedBooking.pickupDate)
              .inDays;
          isLoading = false;
        });

        startExpiryTimer();
      } else {
        setState(() {
          booking = null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void startExpiryTimer() {
    final payment = booking?.payment;

    if (payment == null) return;

    DateTime? expiresAt = payment.expiresAt;

    if (expiresAt == null &&
        payment.status == PaymentStatuses.failed &&
        payment.rejection?.rejectedAt != null) {
      expiresAt = payment.rejection!.rejectedAt!.add(
        const Duration(minutes: 30),
      );
    }

    if (expiresAt == null) return;

    _updateRemaining(expiresAt);

    _expiryTimer?.cancel();

    _expiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(expiresAt!),
    );
  }

  void _updateRemaining(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      _expiryTimer?.cancel();

      if (mounted) {
        setState(() {
          _remaining = Duration.zero;
        });
      }

      expireBooking();

      return;
    }

    if (mounted) {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  Future<void> expireBooking() async {
    if (_expiring) return;

    _expiring = true;

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking!.id)
          .update({
            'status': 'expired',
            'expiredAt': FieldValue.serverTimestamp(),
            'payment.status': 'expired',
          });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String get remainingText {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: loc.bookingDetails),
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : booking == null
            ? Center(child: Text(loc.bookingNotFound))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingHeader(context, booking!, isDark, rentalDays),
                    BookingSectionCard(
                      title: loc.rentalCompany,
                      icon: Icons.storefront_rounded,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: .08,
                            ),
                            backgroundImage: booking!.shop.logo.isNotEmpty
                                ? NetworkImage(booking!.shop.logo)
                                : null,
                            child: booking!.shop.logo.isEmpty
                                ? Icon(
                                    Icons.storefront_rounded,
                                    color: isDark
                                        ? AppColors.lightLayer
                                        : AppColors.primary,
                                  )
                                : null,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking!.shop.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  booking!.shop.address,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  '${booking!.shop.district}, ${booking!.shop.city}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),

                                const SizedBox(height: 8),

                                TextButton.icon(
                                  onPressed: () => MapUtils.openMap(
                                    booking!.shop.location.lat,
                                    booking!.shop.location.lng,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.location_on_rounded,
                                    size: 17,
                                  ),
                                  label: Text(loc.viewOnMap),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    BookingSectionCard(
                      title: loc.bookingTimeline,
                      icon: Icons.route_rounded,
                      child: buildTimeline(booking!),
                    ),

                    // DRIVER'S DETAILS
                    BookingSectionCard(
                      title: loc.driversDetails,
                      icon: Icons.person_rounded,
                      child: Column(
                        children: [
                          rowBuilder(context, loc.name, booking!.driver.name),

                          const SizedBox(height: 11),

                          rowBuilder(context, loc.phone, booking!.driver.phone),

                          const SizedBox(height: 11),

                          rowBuilder(context, loc.email, booking!.driver.email),

                          const SizedBox(height: 14),

                          imageRowBuilder(
                            loc.driverLicenseFront,
                            imagePreview(booking!.driver.licenseFront),
                          ),

                          const SizedBox(height: 10),

                          imageRowBuilder(
                            loc.driverLicenseBack,
                            imagePreview(booking!.driver.licenseBack),
                          ),

                          const SizedBox(height: 10),

                          imageRowBuilder(
                            loc.id,
                            imagePreview(booking!.driver.idCard),
                          ),
                        ],
                      ),
                    ),

                    // CAR DETAILS
                    BookingSectionCard(
                      title: loc.carDetails,
                      icon: Icons.directions_car_rounded,
                      child: Column(
                        children: [
                          rowBuilder(
                            context,
                            loc.name,
                            "${booking!.car.brand} ${booking!.car.model} ${booking!.car.year}",
                          ),
                          const SizedBox(height: 10),
                          rowBuilder(
                            context,
                            loc.seatsLabel,
                            booking!.car.seats.toString(),
                          ),
                          const SizedBox(height: 10),
                          rowBuilder(
                            context,
                            loc.transmission,
                            carPropertiesTranslations(
                              context,
                              booking!.car.transmission,
                            ),
                          ),
                          const SizedBox(height: 10),
                          rowBuilder(
                            context,
                            loc.fuel,
                            carPropertiesTranslations(
                              context,
                              booking!.car.fuel,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BOOKING DETAILS
                    BookingSectionCard(
                      title: loc.bookingDetails,
                      icon: Icons.receipt_long_rounded,
                      child: Column(
                        children: [
                          rowBuilder(
                            context,
                            loc.pickupDate,
                            DateFormat(
                              'dd MMM yyyy • HH:mm',
                              '$locale',
                            ).format(booking!.pickupDate),
                          ),

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            loc.dropoffDate,
                            DateFormat(
                              'dd MMM yyyy • HH:mm',
                              '$locale',
                            ).format(booking!.dropoffDate),
                          ),

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            loc.totalDuration,
                            rentalDays == 1
                                ? loc.singleRentalDay(rentalDays)
                                : loc.multiRentalDay(rentalDays),
                          ),

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            loc.deliveryType,
                            carPropertiesTranslations(
                              context,
                              booking!.deliveryType,
                            ),
                          ),

                          if (booking!.deliveryType == 'dropoff') ...[
                            const SizedBox(height: 11),
                            rowBuilder(
                              context,
                              loc.dropoffAddress,
                              booking!.deliveryAddress,
                            ),
                          ],

                          if (booking!.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 11),
                            rowBuilder(
                              context,
                              loc.additionalNote,
                              booking!.note,
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (booking!.status == 'rejected') ...[
                      Text(
                        loc.rejectionDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 10),
                      rowBuilder(
                        context,
                        loc.rejectionNote,
                        booking!.rejectionReason ?? loc.noReasonProvided,
                      ),
                      SizedBox(height: 5),
                      Divider(thickness: 0, color: AppColors.border),
                      SizedBox(height: 5),
                    ],

                    // PRICE DETAILS
                    BookingSectionCard(
                      title: loc.priceDetails,
                      icon: Icons.payments_rounded,
                      child: Column(
                        children: [
                          rowBuilder(
                            context,
                            loc.rentalPrice,
                            formatCurrency(
                              currencyCode: booking!.currency,
                              context: context,
                              amount: booking!.rentalPrice,
                            ),
                          ),

                          if (booking!.deliveryType == 'delivery') ...[
                            const SizedBox(height: 11),
                            rowBuilder(
                              context,
                              loc.deliveryPrice,
                              formatCurrency(
                                currencyCode: booking!.currency,
                                context: context,
                                amount: booking!.deliveryPrice,
                              ),
                            ),
                          ],

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            loc.depositRefundable,
                            formatCurrency(
                              currencyCode: booking!.currency,
                              context: context,
                              amount: booking!.deposit,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Divider(
                            color: AppColors.border.withValues(alpha: .5),
                          ),

                          const SizedBox(height: 12),

                          rowBuilder(
                            context,
                            loc.totalPreTax,
                            formatCurrency(
                              currencyCode: booking!.currency,
                              context: context,
                              amount: booking!.preTax,
                            ),
                          ),

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            '${loc.tax} (${100 * booking!.taxRate}%)',
                            formatCurrency(
                              currencyCode: booking!.currency,
                              context: context,
                              amount: booking!.tax,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.grandTotal,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  formatCurrency(
                                    amount: booking!.totalPrice,
                                    currencyCode: booking!.currency,
                                    context: context,
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? AppColors.lightLayer
                                            : AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BOOKING DETAILS
                    BookingSectionCard(
                      title: loc.paymentDetails,
                      icon: Icons.credit_card_rounded,
                      child: Column(
                        children: [
                          rowBuilder(
                            context,
                            loc.paymentMethod,
                            carPropertiesTranslations(
                              context,
                              booking!.payment!.method,
                            ),
                          ),

                          const SizedBox(height: 11),

                          rowBuilder(
                            context,
                            loc.paymentStatus,
                            carPropertiesTranslations(
                              context,
                              booking!.payment!.status,
                            ),
                          ),

                          if (booking!.payment!.method ==
                                  PaymentMethods.crypto &&
                              booking!.payment!.status !=
                                  PaymentStatuses.unpaid &&
                              booking!.payment!.status !=
                                  PaymentStatuses.pending) ...[
                            const SizedBox(height: 11),

                            rowBuilder(
                              context,
                              'USDT',
                              booking!.payment!.crypto!.amount.toStringAsFixed(
                                2,
                              ),
                            ),

                            const SizedBox(height: 11),

                            rowBuilder(
                              context,
                              'TXID',
                              booking!.payment!.crypto!.txid ?? '',
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (booking!.status == 'completed') ...[
                      booking!.isRated
                          ? _buildReviewedState(context)
                          : _buildLeaveReviewButton(
                              context,
                              booking!,
                              isDark,
                              fetchBooking,
                            ),

                      const SizedBox(height: 14),
                    ],
                    // BOOKING MESSAGES
                    UserBookingStatusMessage(booking: booking!),

                    SizedBox(height: 5),

                    if (booking!.payment!.method == PaymentMethods.crypto &&
                        (booking!.payment!.status == PaymentStatuses.pending ||
                            booking!.payment!.status ==
                                PaymentStatuses.failed)) ...[
                      SizedBox(height: 5),
                      Center(
                        child: ElevatedButton(
                          onPressed: _remaining <= Duration.zero
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CryptoPaymentPage(
                                      bookingId: booking!.id,
                                    ),
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _remaining > Duration.zero
                                ? '${loc.addPayment} ($remainingText)'
                                : loc.paymentExpired,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 5),
                  ],
                ),
              ),
      ),
    );
  }

  Widget rowBuilder(BuildContext context, String title, String details) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .62),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          flex: 6,
          child: Text(
            details,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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

  Widget imagePreview(String url) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              gaplessPlayback: true,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Image.asset(
                  "assets/images/image_spinner.gif",
                  fit: BoxFit.cover,
                );
              },
              errorBuilder: (_, _, _) => Image.asset(
                "assets/images/placeholder.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      child: Text(loc.view, style: TextStyle(color: Colors.blue)),
    );
  }

  Widget buildTimeline(BookingModel booking) {
    List<Map<String, dynamic>> steps = [
      {
        "title": loc.bookingPlaced,
        "date": booking.createdAt,
        "status": BookingStepStatus.completed,
        "icon": Icons.receipt_long,
      },
      {
        "title": loc.approved,
        "date": booking.approvedAt,
        "status": booking.approvedAt != null
            ? BookingStepStatus.completed
            : booking.status == 'pending'
            ? BookingStepStatus.current
            : BookingStepStatus.pending,
        "icon": Icons.check_circle,
      },
      {
        "title": loc.ongoing,
        "date": booking.startedAt,
        "status": booking.startedAt != null
            ? BookingStepStatus.completed
            : booking.status == 'approved'
            ? BookingStepStatus.current
            : BookingStepStatus.pending,
        "icon": Icons.directions_car,
      },
      {
        "title": loc.completed,
        "date": booking.completedAt,
        "status": booking.completedAt != null
            ? BookingStepStatus.completed
            : BookingStepStatus.pending,
        "icon": Icons.flag,
      },
    ];

    // Handle rejection (override flow)
    if (booking.status == 'rejected') {
      steps.add({
        "title": loc.rejected,
        "date": booking.rejectedAt,
        "status": BookingStepStatus.rejected,
        "icon": Icons.cancel,
      });
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return TimelineItem(
          title: step["title"],
          date: step["date"],
          status: step["status"],
          icon: step["icon"],
          isLast: isLast,
        );
      }),
    );
  }
}

Widget _buildLeaveReviewButton(
  BuildContext context,
  BookingModel booking,
  bool isDark,
  Future<void> Function() onTap,
) {
  final loc = AppLocalizations.of(context)!;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .08),
          AppColors.tertiary.withValues(alpha: .05),
        ],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.primary.withValues(alpha: .12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppColors.secondary,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.leaveAReview,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    loc.shareYourRentalExperience,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: .65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CarReviewPage(booking: booking),
                ),
              );

              if (result == true && context.mounted) {
                await onTap();
              }
            },
            icon: const Icon(Icons.rate_review_rounded),
            label: Text(
              loc.leaveAReview,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildReviewedState(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.secondary.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.secondary.withValues(alpha: .18)),
    ),
    child: Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.secondary,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.reviewSubmitted,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                AppLocalizations.of(context)!.thankYouForSharing,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: .65),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Icon(Icons.star_rounded, color: AppColors.secondary, size: 24),
      ],
    ),
  );
}

class BookingSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const BookingSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent.withValues(alpha: 0.8)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.1)
              : AppColors.border.withValues(alpha: .55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.lightLayer.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          child,
        ],
      ),
    );
  }
}

Widget _buildBookingHeader(
  BuildContext context,
  BookingModel booking,
  bool isDark,
  int rentalDays,
) {
  final theme = Theme.of(context);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.darkLayer],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .18),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                booking.invoiceNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            BookingStatusBadge(status: booking.status),
          ],
        ),

        const SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 76,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  booking.car.carImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Image.asset(
                      'assets/images/placeholder.jpeg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.car.brand} ${booking.car.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${booking.car.year} • ${AppLocalizations.of(context)!.numOfSeats(booking.car.seats)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        size: 15,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          booking.shop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _headerInfo(
                context,
                Icons.calendar_month_rounded,
                DateFormat(
                  'dd MMM',
                  '${Provider.of<LocaleProvider>(context, listen: false).locale}',
                ).format(booking.pickupDate),
                AppLocalizations.of(context)!.pickup,
              ),
            ),

            Container(
              width: 1,
              height: 38,
              color: Colors.white.withValues(alpha: .18),
            ),

            Expanded(
              child: _headerInfo(
                context,
                Icons.event_available_rounded,
                DateFormat(
                  'dd MMM',
                  '${Provider.of<LocaleProvider>(context, listen: false).locale}',
                ).format(booking.dropoffDate),
                AppLocalizations.of(context)!.returnString,
              ),
            ),

            Container(
              width: 1,
              height: 38,
              color: Colors.white.withValues(alpha: .18),
            ),

            Expanded(
              child: _headerInfo(
                context,
                Icons.timelapse_rounded,
                rentalDays.toString(),
                AppLocalizations.of(context)!.numDays(rentalDays),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _headerInfo(
  BuildContext context,
  IconData icon,
  String value,
  String label,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: Colors.white70),
      const SizedBox(width: 7),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    ],
  );
}
