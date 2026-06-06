import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/badges/payment_status_badge.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/booking_action_result_code.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/repositories/action_result.dart';
import 'package:kipgo/repositories/booking_repository.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/rental_company_card.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_car_details.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_assigned_unit.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/rental_driver_details.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCryptoPaymentDetailsPage extends StatefulWidget {
  final String bookingId;
  const AdminCryptoPaymentDetailsPage({super.key, required this.bookingId});

  @override
  State<AdminCryptoPaymentDetailsPage> createState() =>
      _AdminCryptoPaymentDetailsPageState();
}

class _AdminCryptoPaymentDetailsPageState
    extends State<AdminCryptoPaymentDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool isProcessing = false;
  late bool isDark;
  late BookingModel booking;
  late AppLocalizations loc;

  final TextEditingController rejectionController = TextEditingController();

  final List<String> quickRejectionReasons = [
    'Invalid TXID',
    'Duplicate transaction',
    'Wrong payment amount',
    'Incorrect network',
    'Transaction not found',
    'Wallet address mismatch',
  ];

  Future<void> _showVerifyDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.verifyCryptoPayment,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                Text(loc.thisWillMarkPaymentVerified),

                const SizedBox(height: 24),

                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.cancel),
                          ),
                        ),
                      ),

                      const VerticalDivider(
                        color: AppColors.border,
                        thickness: 1,
                        width: 1,
                        indent: 8,
                        endIndent: 8,
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(loc.verify),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      await _verifyPayment();
    }
  }

  Future<void> _verifyPayment() async {
    try {
      setState(() {
        isProcessing = true;
      });

      String userId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).profile!.id;

      final res = await BookingRepository().verifyCryptoPayment(
        booking: booking,
        userId: userId,
      );

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

  Future<void> _showRejectDialog() async {
    rejectionController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.rejectCryptoPayment,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 12),

                      Text(loc.customerWillNeedToSubmitValid),

                      const SizedBox(height: 20),

                      Text(
                        loc.quickReasons,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: quickRejectionReasons.map((reason) {
                          return ChoiceChip(
                            label: Text(reason),
                            selected: rejectionController.text == reason,
                            onSelected: (_) {
                              setModalState(() {
                                rejectionController.text = reason;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: rejectionController,
                        maxLines: 4,
                        onChanged: (_) {
                          setModalState(() {});
                        },
                        decoration: inputDecoration(
                          context: context,
                          hint: loc.reasonForRejection,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        loc.customerMaySeeReason,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const SizedBox(height: 24),

                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tertiary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: isProcessing
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(loc.cancel),
                                ),
                              ),
                            ),

                            const VerticalDivider(
                              color: AppColors.border,
                              thickness: 1,
                              width: 1,
                              indent: 8,
                              endIndent: 8,
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed:
                                      rejectionController.text.trim().isEmpty
                                      ? null
                                      : () async {
                                          Navigator.pop(context);

                                          await _rejectPayment(
                                            rejectionController.text,
                                          );
                                        },
                                  child: isProcessing
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(loc.rejectPayment),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _rejectPayment(String reason) async {
    try {
      setState(() {
        isProcessing = true;
      });

      String userId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).profile!.id;

      await BookingRepository().rejectCryptoPayment(
        booking: booking,
        reason: reason,
        userId: userId,
      );

      if (mounted) {
        ReusableToast.success(
          context,
          "Success",
          "Payment rejected successfully",
        );
      }
    } catch (e) {
      if (mounted) {
        ReusableToast.error(context, "Error", e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
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
            appBar: AppBarWidget(title: loc.paymentDetails),
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
        // return Container();
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
                  title: loc.driversDetails,
                  child: RentalDriverDetails(booking: booking, isDark: isDark),
                ),
                SizedBox(height: 12),
                if (booking.status == 'reserved' ||
                    booking.status == 'ongoing' ||
                    booking.status == 'completed') ...[
                  SizedBox(height: 12),
                  tileContainer(
                    child: RentalAssignedUnit(booking: booking, isDark: isDark),
                    title: loc.assignedUnit,
                  ),
                ],

                if (booking.status == 'rejected') ...[
                  SizedBox(height: 12),
                  tileContainer(
                    child: Text(
                      booking.rejectionReason ?? loc.noReasonProvided,
                    ),
                    title: loc.reasonForRejection,
                  ),
                ],

                tileContainer(
                  child: cryptoPaymentDetails(),
                  title: loc.cryptoDetails,
                ),

                if (booking.payment?.status == 'awaiting_verification')
                  Column(
                    children: [
                      SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
                          onPressed: isProcessing ? null : _showVerifyDialog,
                          icon: isProcessing ? null : Icon(Icons.check),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(loc.verifyPayment),
                        ),
                      ),

                      SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.tertiary
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isProcessing ? null : _showRejectDialog,
                          icon: isProcessing ? null : Icon(Icons.close),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(loc.rejectPayment),
                        ),
                      ),
                    ],
                  ),
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

  Column cryptoPaymentDetails() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc.cryptoAmount),
            Text(
              "${booking.payment!.crypto!.amount.toStringAsFixed(2)} USDT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox.shrink(),
            Text(
              loc.includesUSDTFee(booking.payment!.crypto!.networkFee),
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.wallet),
            SizedBox(width: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: Text(booking.payment!.crypto!.walletAddress),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(loc.network), Text(booking.payment!.crypto!.network)],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TXID"),
            SizedBox(width: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(booking.payment!.crypto!.txid!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton.outlined(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: booking.payment!.crypto!.txid!),
                          );

                          if (context.mounted) {
                            ReusableToast.success(
                              context,
                              loc.copied,
                              loc.walletAddressCopied,
                            );
                          }
                        },
                        icon: Icon(Icons.copy),
                      ),
                      IconButton.outlined(
                        onPressed: () async {
                          final uri = Uri.parse(
                            "https://tronscan.org/#/transaction/${booking.payment?.crypto?.txid}",
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: Icon(Icons.open_in_new),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc.status),
            PaymentStatusBadge(status: booking.payment?.status ?? ''),
          ],
        ),
        if (booking.payment?.crypto?.txidSubmittedAt != null) ...[
          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.submitted),
              Text(
                DateFormat.yMMMd().add_jm().format(
                  booking.payment!.crypto!.txidSubmittedAt!,
                ),
              ),
            ],
          ),
        ],
      ],
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
}
