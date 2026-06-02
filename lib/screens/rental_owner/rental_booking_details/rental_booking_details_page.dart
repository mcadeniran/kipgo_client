import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/booking_action_result_code.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/repositories/action_result.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:kipgo/screens/rental/bookings/widgets/timeline_item.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_action_executor.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_action_helper.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_actions_widget.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_app_bottom_sheet.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_car_details.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/reject_booking_sheet.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_assigned_unit.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_car_summary.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_delivery.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_payments_breakdown.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_booking_schedule.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_driver_details.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_driver_documents.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/start_booking_sheet.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/booking_status_message.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';

import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum BookingAction { approve, reject, start, complete }

class RentalBookingDetailsPage extends StatefulWidget {
  final String bookingId;
  const RentalBookingDetailsPage({super.key, required this.bookingId});

  @override
  State<RentalBookingDetailsPage> createState() =>
      _RentalBookingDetailsPageState();
}

class _RentalBookingDetailsPageState extends State<RentalBookingDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  late bool isDark;
  late BookingModel booking;
  bool isProcessing = false;
  late AppLocalizations loc;
  late List actions = [];

  Future<void> executeAction(BookingAction action, BookingModel booking) async {
    switch (action) {
      case BookingAction.approve:
        await _approveBooking(booking);
        break;

      case BookingAction.start:
        await _startBooking(booking);
        break;

      case BookingAction.complete:
        await _completeBooking(booking);
        break;

      case BookingAction.reject:
        final reason = await RejectBookingSheet.show(context);

        if (reason == null) return;

        await _rejectBooking(booking, reason);

        break;
    }
  }

  Future<void> _startBooking(BookingModel booking) async {
    String? unitId;

    if (booking.payment?.method == 'payOnPickup' &&
        booking.status == 'approved') {
      final result = await StartBookingSheet.show(context, booking);

      if (result == null) return;

      unitId = result.unitId;
    }

    final confirm = await AppBottomSheets.confirm(
      context: context,
      title: loc.startBooking,
      message: booking.status == 'reserved'
          ? loc.actionWillStartRental
          : loc.actionWillAssignSelectedUnit,
      confirmText: loc.start,
    );

    if (!confirm) return;

    setState(() => isProcessing = true);

    try {
      final res = await BookingActionExecutor.startBooking(booking, unitId);
      if (!mounted) return;
      if (res.success) {
        ReusableToast.success(
          context,
          loc.success,
          translateResult(res.code, loc),
        );
      } else {
        ReusableToast.error(context, loc.error, translateResult(res.code, loc));
      }
    } on ActionResult catch (e) {
      if (!mounted) return;
      ReusableToast.error(context, loc.error, translateResult(e.code, loc));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _approveBooking(BookingModel booking) async {
    final confirm = await AppBottomSheets.confirm(
      context: context,
      title: loc.approveBooking,
      message: loc.doYouWantToApproveBooking,
      confirmText: loc.approve,
    );

    if (!confirm) return;

    setState(() => isProcessing = true);

    try {
      final res = await BookingActionExecutor.approveBooking(booking);
      if (!mounted) return;
      if (res.success) {
        ReusableToast.success(
          context,
          loc.success,
          translateResult(res.code, loc),
        );
      } else {
        ReusableToast.error(context, loc.error, translateResult(res.code, loc));
      }
    } on ActionResult catch (e) {
      if (!mounted) return;
      ReusableToast.error(context, loc.error, translateResult(e.code, loc));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _completeBooking(BookingModel booking) async {
    final confirm = await AppBottomSheets.confirm(
      context: context,
      title: loc.completeBooking,
      message: loc.willEndRentalPeriod,
      confirmText: loc.complete,
    );

    if (!confirm) return;

    setState(() => isProcessing = true);

    try {
      final res = await BookingActionExecutor.completeBooking(booking);
      if (!mounted) return;
      if (res.success) {
        ReusableToast.success(
          context,
          loc.success,
          translateResult(res.code, loc),
        );
      } else {
        ReusableToast.error(context, loc.error, translateResult(res.code, loc));
      }
    } on ActionResult catch (e) {
      if (!mounted) return;
      ReusableToast.error(context, loc.error, translateResult(e.code, loc));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _rejectBooking(BookingModel booking, String reason) async {
    final confirm = await AppBottomSheets.confirm(
      context: context,
      title: loc.rejectBooking,
      message: loc.rejectBookingPrompt,
      confirmText: loc.reject,
    );

    if (!confirm) return;

    setState(() => isProcessing = true);

    try {
      final res = await BookingActionExecutor.rejectBooking(booking, reason);

      if (!mounted) return;
      if (res.success) {
        ReusableToast.success(
          context,
          loc.success,
          translateResult(res.code, loc),
        );
      } else {
        ReusableToast.error(context, loc.error, translateResult(res.code, loc));
      }
    } on ActionResult catch (e) {
      if (!mounted) return;
      ReusableToast.error(context, loc.error, translateResult(e.code, loc));
    } finally {
      setState(() => isProcessing = false);
    }
  }

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

        actions = BookingActionHelper.getActions(booking);

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
                BookingActionsWidget(
                  booking: booking,
                  isProcessing: isProcessing,
                  onAction: (action) => executeAction(action, booking),
                ),
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
