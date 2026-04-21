import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental/bookings/widgets/timeline_item.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.booking != null) {
      booking = widget.booking;
      rentalDays = booking!.dropoffDate.difference(booking!.pickupDate).inDays;
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

      if (doc.exists) {
        setState(() {
          booking = BookingModel.fromFirestore(doc);
          rentalDays = booking!.dropoffDate
              .difference(booking!.pickupDate)
              .inDays;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return Scaffold(
      appBar: AppBarWidget(title: loc.bookingDetails),
      backgroundColor: AppColors.primary,
      bottomNavigationBar: isLoading || booking == null
          ? null
          : SafeArea(
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.grandTotal,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatCurrency(
                        amount: booking!.totalPrice,
                        currencyCode: booking!.currency,
                        context: context,
                      ),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        // color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    Container(
                      padding: EdgeInsets.only(top: 8, bottom: 12),
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${loc.invoiceNumber}: ${booking!.invoiceNumber}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.primary,
                                backgroundImage: NetworkImage(
                                  booking!.shop.logo,
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking!.shop.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    booking!.shop.address,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    "${booking!.shop.district} ${booking!.shop.city}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => MapUtils.openMap(
                                      booking!.shop.location.lat,
                                      booking!.shop.location.lng,
                                    ),
                                    child: Text(loc.viewOnMap),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      loc.bookingTimeline,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    buildTimeline(booking!),
                    // SizedBox(height: 10),
                    Divider(thickness: 0, color: AppColors.border),
                    SizedBox(height: 5),
                    // DRIVER'S DETAILS
                    Text(
                      loc.driversDetails,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    rowBuilder(context, loc.name, booking!.driver.name),
                    SizedBox(height: 5),
                    rowBuilder(context, loc.phone, booking!.driver.phone),
                    SizedBox(height: 5),
                    rowBuilder(context, loc.email, booking!.driver.email),
                    SizedBox(height: 5),
                    imageRowBuilder(
                      loc.driverLicenseFront,
                      imagePreview(booking!.driver.licenseFront),
                    ),
                    SizedBox(height: 5),
                    imageRowBuilder(
                      loc.driverLicenseBack,
                      imagePreview(booking!.driver.licenseBack),
                    ),
                    SizedBox(height: 5),
                    imageRowBuilder(
                      loc.id,
                      imagePreview(booking!.driver.idCard),
                    ),
                    SizedBox(height: 5),
                    Divider(thickness: 0, color: AppColors.border),
                    SizedBox(height: 5),

                    // CAR DETAILS
                    Text(
                      loc.carDetails,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    rowBuilder(
                      context,
                      loc.name,
                      "${booking!.car.brand} ${booking!.car.model} ${booking!.car.year}",
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.seatsLabel,
                      booking!.car.seats.toString(),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.transmission,
                      carPropertiesTranslations(
                        context,
                        booking!.car.transmission,
                      ),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.fuel,
                      carPropertiesTranslations(context, booking!.car.fuel),
                    ),
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
                      context,
                      loc.pickupDate,
                      DateFormat(
                        'dd MMM yyyy • HH:mm',
                        '$locale',
                      ).format(booking!.pickupDate),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.dropoffDate,
                      DateFormat(
                        'dd MMM yyyy • HH:mm',
                        '$locale',
                      ).format(booking!.dropoffDate),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.totalDuration,
                      rentalDays == 1
                          ? loc.singleRentalDay(rentalDays)
                          : loc.multiRentalDay(rentalDays),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.deliveryType,
                      carPropertiesTranslations(context, booking!.deliveryType),
                    ),
                    if (booking!.deliveryType == 'dropoff') ...[
                      SizedBox(height: 5),
                      rowBuilder(
                        context,
                        loc.dropoffAddress,
                        booking!.deliveryAddress,
                      ),
                    ],
                    if (booking!.note.trim() != '') ...[
                      SizedBox(height: 5),
                      rowBuilder(context, loc.additionalNote, booking!.note),
                    ],
                    SizedBox(height: 5),
                    Divider(thickness: 0, color: AppColors.border),
                    SizedBox(height: 5),

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
                    Text(
                      loc.priceDetails,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    rowBuilder(
                      context,
                      loc.rentalPrice,
                      formatCurrency(
                        currencyCode: booking!.currency,
                        context: context,
                        amount: booking!.rentalPrice,
                      ),
                    ),
                    SizedBox(height: 5),
                    if (booking!.deliveryType == 'delivery') ...[
                      rowBuilder(
                        context,
                        loc.deliveryPrice,
                        formatCurrency(
                          currencyCode: booking!.currency,
                          context: context,
                          amount: booking!.deliveryPrice,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                    rowBuilder(
                      context,
                      loc.depositRefundable,
                      formatCurrency(
                        currencyCode: booking!.currency,
                        context: context,
                        amount: booking!.deposit,
                      ),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      loc.totalPreTax,
                      formatCurrency(
                        currencyCode: booking!.currency,
                        context: context,
                        amount: booking!.preTax,
                      ),
                    ),
                    SizedBox(height: 5),
                    rowBuilder(
                      context,
                      "${loc.tax} (${100 * booking!.taxRate}%)",
                      formatCurrency(
                        currencyCode: booking!.currency,
                        context: context,
                        amount: booking!.tax,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
      ),
    );
  }

  Widget rowBuilder(BuildContext context, String title, String details) => Row(
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

  Widget imagePreview(String url) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: FadeInImage.assetNetwork(
              fadeInCurve: Curves.easeIn,
              fadeInDuration: Duration(seconds: 2),
              fit: BoxFit.cover,
              placeholder: "assets/images/image_spinner.gif",
              image: url,
              imageErrorBuilder: (c, e, s) => Image.asset(
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
