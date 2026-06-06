import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/rental_company_card.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental/bookings/widgets/timeline_item.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_car_details.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_assigned_unit.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_car_summary.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_delivery.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_payments_breakdown.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_schedule.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_driver_details.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_driver_documents.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/booking_status_message.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminRentalBookingDetailsPage extends StatefulWidget {
  final String bookingId;
  const AdminRentalBookingDetailsPage({super.key, required this.bookingId});

  @override
  State<AdminRentalBookingDetailsPage> createState() =>
      _AdminRentalBookingDetailsPageState();
}

class _AdminRentalBookingDetailsPageState
    extends State<AdminRentalBookingDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  late bool isDark;
  late BookingModel booking;
  late AppLocalizations loc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    loc = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BookingModel>(
      stream: BookingRepository().streamBookingById(widget.bookingId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.data == null) {
          return Scaffold(
            appBar: AppBarWidget(
              title: AppLocalizations.of(context)!.bookingDetails,
            ),
            backgroundColor: AppColors.primary,
            body: Container(
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Center(child: Text(loc.bookingNotFound)),
            ),
          );
        }

        booking = snapshot.data!;

        return _buildContent(context, booking);
      },
    );
  }

  Widget _buildContent(BuildContext context, BookingModel booking) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarWidget(title: loc.bookingDetails),
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                tileContainer(
                  title: loc.company,
                  child: RentalCompanyCard(booking: booking, isDark: isDark),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.car,
                  child: BookingCarDetails(booking: booking, isDark: isDark),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.status,
                  child: buildTimeline(booking, loc),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.driversDetails,
                  child: RentalDriverDetails(booking: booking, isDark: isDark),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.driversDocuments,
                  child: RentalDriverDocuments(
                    booking: booking,
                    isDark: isDark,
                  ),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.carSummary,
                  child: RentalBookingCarSummary(
                    booking: booking,
                    isDark: isDark,
                  ),
                ),
                if (booking.status == 'reserved' ||
                    booking.status == 'ongoing' ||
                    booking.status == 'completed') ...[
                  SizedBox(height: 12),
                  tileContainer(
                    child: RentalAssignedUnit(booking: booking, isDark: isDark),
                    title: loc.assignedUnit,
                  ),
                ],
                SizedBox(height: 12),
                tileContainer(
                  title: loc.schedule,
                  child: RentalBookingSchedule(
                    booking: booking,
                    isDark: isDark,
                  ),
                ),
                SizedBox(height: 12),
                tileContainer(
                  title: loc.deliveryInformation,
                  child: RentalBookingDelivery(
                    booking: booking,
                    isDark: isDark,
                  ),
                ),
                if (booking.status == 'rejected') ...[
                  SizedBox(height: 12),
                  tileContainer(
                    child: Text(
                      booking.rejectionReason ?? loc.noReasonProvided,
                    ),
                    title: loc.reasonForRejection,
                  ),
                ],
                SizedBox(height: 12),
                tileContainer(
                  title: loc.paymentBreakdown,
                  child: RentalBookingPaymentsBreakdown(
                    booking: booking,
                    isDark: isDark,
                  ),
                ),
                SizedBox(height: 12),

                BookingStatusMessage(booking: booking),

                SizedBox(height: 12),
                // BookingActionsWidget(
                //   booking: booking,
                //   isProcessing: isProcessing,
                //   onAction: (action) => executeAction(action, booking),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container tileContainer({required Widget child, required String title}) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget buildTimeline(BookingModel booking, AppLocalizations loc) {
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
      steps.removeWhere((s) => s['title'] == loc.completed);
      steps.removeWhere((s) => s['title'] == loc.ongoing);
      steps.removeWhere((s) => s['title'] == loc.approved);
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
