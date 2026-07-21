import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_booking_status.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_status.dart';
import 'package:kipgo/models/wallet.dart';
import 'package:kipgo/repositories/shuttle_booking_repository.dart';
import 'package:kipgo/screens/shuttle/shuttle_bottom_navigation.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/info_card.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/info_row.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/payment_status_chip.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cryptocurrency.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toastification/toastification.dart';

class ShuttleCryptoPaymentScreen extends StatefulWidget {
  final String bookingId;

  const ShuttleCryptoPaymentScreen({super.key, required this.bookingId});

  @override
  State<ShuttleCryptoPaymentScreen> createState() =>
      _ShuttleCryptoPaymentScreenState();
}

class _ShuttleCryptoPaymentScreenState
    extends State<ShuttleCryptoPaymentScreen> {
  late WalletModel wallet;
  ShuttleBooking? booking;

  final cryptoFormKey = GlobalKey<FormState>();

  final ScrollController scrollController = ScrollController();

  final TextEditingController txid = TextEditingController();

  late AppLocalizations loc;

  bool isLoading = true;

  bool isSubmitting = false;

  Duration? remaining;

  Timer? timer;

  final _repository = ShuttleBookingRepository();

  String? validateTxid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return loc.transactionHashRequired;
    }

    final txid = value.trim();

    /// TRON TXID = 64 HEX
    final regex = RegExp(r'^[A-Fa-f0-9]{64}$');

    if (!regex.hasMatch(txid)) {
      return loc.invalidTronHash;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      /// ---------------------------------------------------
      /// BOOKING
      /// ---------------------------------------------------
      booking = await _repository.getShuttleBooking(widget.bookingId);

      /// ---------------------------------------------------
      /// WALLET
      /// ---------------------------------------------------

      final walletSnap = await FirebaseFirestore.instance
          .collection('misc')
          .doc('wallet')
          .get();

      wallet = WalletModel.fromSnapshot(walletSnap);

      /// ---------------------------------------------------
      /// AUTO FILL EXISTING TXID
      /// ---------------------------------------------------

      if (booking?.payment.crypto?.transactionId != null) {
        txid.text = booking!.payment.crypto!.transactionId!;
      }

      /// ---------------------------------------------------
      /// START TIMER
      /// ---------------------------------------------------

      startExpiryTimer();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void startExpiryTimer() {
    timer?.cancel();

    if (booking?.payment.expiresAt == null) return;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final expiresAt = booking!.payment.expiresAt!;

      final diff = expiresAt.difference(DateTime.now());

      if (diff.isNegative) {
        timer?.cancel();

        setState(() {
          remaining = Duration.zero;
        });

        expireBooking();

        return;
      }

      setState(() {
        remaining = diff;
      });
    });
  }

  Future<void> expireBooking() async {
    if (booking == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('shuttleBookings')
          .doc(booking!.id)
          .update({
            "status": ShuttleBookingStatus.expired.value,
            "expiredAt": FieldValue.serverTimestamp(),
            "payment.expiresAt": null,
            "payment.status": ShuttlePaymentStatus.expired.value,
          });

      if (mounted) {
        ReusableToast.error(
          context,
          loc.paymentExpired,
          loc.cryptoPaymentSessionExpired,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> submitTxid() async {
    if (!cryptoFormKey.currentState!.validate()) return;

    if (booking == null) return;

    if (remaining != null && remaining!.inSeconds <= 0) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(loc.expired),
        description: Text(loc.thisPaymentSessionHasExpired),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await _repository.submitCryptoPayment(
        bookingId: booking!.id,
        txid: txid.text.trim(),
      );

      if (mounted) {
        ReusableToast.success(
          context,
          loc.paymentSubmitted,
          loc.paymentSubmittedSuccessfully,
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const ShuttleBottomNavigation(initialIndex: 1),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ReusableToast.error(context, loc.failed, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    timer?.cancel();

    txid.dispose();

    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final crypto = booking?.payment.crypto;
    return Scaffold(
      appBar: AppBarWidget(title: loc.checkout),
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : booking == null
            ? Center(child: Text(loc.bookingNotFound))
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      /// ---------------------------------------------------
                      /// TIMER
                      /// ---------------------------------------------------
                      if (remaining != null)
                        Container(
                          width: double.maxFinite,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: remaining!.inMinutes < 5
                                ? Colors.red.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(loc.paymentExpiresIn),

                              const SizedBox(height: 4),

                              Text(
                                formatDuration(remaining!),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                      /// ---------------------------------------------------
                      /// TOTAL
                      /// ---------------------------------------------------
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : AppColors.lightAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              loc.totalAmount,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            Text(
                              formatCurrency(
                                amount: booking!.total,
                                currencyCode: booking!.currency,
                                context: context,
                              ),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),

                            Text(
                              '${crypto?.amount.toStringAsFixed(2) ?? '0'} USDT',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              loc.includesUSDTFee(crypto?.networkFee ?? 0),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ---------------------------------------------------
                      /// QR
                      /// ---------------------------------------------------
                      QrImageView(
                        data: wallet.wallet,
                        version: QrVersions.auto,
                        size: 200,
                        gapless: false,
                        embeddedImage: const AssetImage(
                          'assets/images/splash12.png',
                        ),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(60, 60),
                        ),
                        eyeStyle: QrEyeStyle(
                          color: isDark ? Colors.white : Colors.black,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ---------------------------------------------------
                      /// COPY ADDRESS
                      /// ---------------------------------------------------
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: wallet.wallet),
                          );

                          if (context.mounted) {
                            toastification.show(
                              context: context,
                              title: Text(loc.copied),
                              description: Text(loc.walletAddressCopied),
                              type: ToastificationType.success,
                              autoCloseDuration: const Duration(seconds: 3),
                            );
                          }
                        },
                        label: Text(loc.clickToCopyAddress),
                        icon: const Icon(Icons.copy),
                        iconAlignment: IconAlignment.end,
                      ),

                      const SizedBox(height: 8),

                      Text(loc.scanQRCode),

                      const SizedBox(height: 8),

                      Text(
                        loc.onlySendUSDT,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const SizedBox(height: 12),

                      /// ---------------------------------------------------
                      /// TXID
                      /// ---------------------------------------------------
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : AppColors.lightAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.enterTransactionHash,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: Form(
                                    key: cryptoFormKey,
                                    autovalidateMode:
                                        AutovalidateMode.onUnfocus,
                                    child: TextFormField(
                                      controller: txid,
                                      validator: validateTxid,
                                      decoration: inputDecoration(
                                        context: context,
                                        hint: loc.pasteTransactionHash,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[A-Fa-f0-9]'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed: () async {
                                    ClipboardData? data =
                                        await Clipboard.getData(
                                          Clipboard.kTextPlain,
                                        );

                                    if (data?.text != null) {
                                      txid.text = data!.text!;
                                    }
                                  },
                                  icon: const Icon(Icons.paste),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ---------------------------------------------------
                      /// BUTTON
                      /// ---------------------------------------------------
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSubmitting ? null : submitTxid,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(loc.iveSentThePayment),
                      ),
                      const SizedBox(height: 20),
                      if (!Navigator.canPop(context))
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShuttleBottomNavigation(
                                  initialIndex: 0,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(loc.backHome),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// class _ShuttleCryptoPaymentScreenState
//     extends State<ShuttleCryptoPaymentScreen> {
//   final _repository = ShuttleBookingRepository();

//   final _txidController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();

//   late AppLocalizations loc;

//   ShuttleBooking? booking;

//   Timer? _timer;

//   Duration _remaining = Duration.zero;

//   DateTime? _lastExpiry;

//   bool _submitting = false;

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _txidController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     loc = AppLocalizations.of(context)!;
//     super.didChangeDependencies();
//   }

//   void _startCountdown(DateTime? expiresAt) {
//     _timer?.cancel();

//     if (expiresAt == null) {
//       return;
//     }

//     void update() {
//       final difference = expiresAt.difference(DateTime.now());

//       if (!mounted) return;

//       setState(() {
//         _remaining = difference.isNegative ? Duration.zero : difference;
//       });
//     }

//     if (_remaining == Duration.zero) {
//       _timer?.cancel();
//     }

//     update();

//     _timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
//   }

//   String get formattedTime {
//     final minutes = _remaining.inMinutes
//         .remainder(60)
//         .toString()
//         .padLeft(2, '0');

//     final seconds = _remaining.inSeconds
//         .remainder(60)
//         .toString()
//         .padLeft(2, '0');

//     return "$minutes:$seconds";
//   }

//   Color get timerColor {
//     if (_remaining.inMinutes <= 1) {
//       return Colors.red;
//     }

//     if (_remaining.inMinutes <= 5) {
//       return Colors.orange;
//     }

//     return Colors.green;
//   }

//   String getButtonText(ShuttleBooking booking) {
//     switch (booking.payment.status) {
//       case ShuttlePaymentStatus.pending:
//         return loc.iveSentThePayment;

//       case ShuttlePaymentStatus.awaitingVerification:
//         return loc.waitingForVerification;

//       case ShuttlePaymentStatus.paid:
//         return loc.paymentVerified;

//       default:
//         return loc.continueAction;
//     }
//   }

//   void _handleExpiry(DateTime? expiresAt) {
//     if (_lastExpiry == expiresAt) {
//       return;
//     }

//     _lastExpiry = expiresAt;

//     _startCountdown(expiresAt);
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
//     return Scaffold(
//       appBar: AppBarWidget(title: loc.cryptoPayment),
//       backgroundColor: AppColors.primary,
//       body: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         child: StreamBuilder<ShuttleBooking>(
//           stream: _repository.watchBooking(widget.bookingId),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.data == null) {
//               return Center(child: Text(loc.bookingNotFound));
//             }

//             final booking = snapshot.data!;

//             final locked =
//                 booking.payment.status ==
//                     ShuttlePaymentStatus.awaitingVerification ||
//                 booking.payment.status == ShuttlePaymentStatus.paid;

//             if (booking.payment.status == ShuttlePaymentStatus.expired) {
//               return Center(
//                 child: Text(
//                   loc.thisPaymentRequestHasExpired,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               );
//             }

//             if (booking.payment.status == ShuttlePaymentStatus.paid) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         const ShuttleBottomNavigation(initialIndex: 1),
//                   ),
//                   (route) => false,
//                 );
//               });
//             }

//             // if (booking.payment.status ==
//             //     ShuttlePaymentStatus.awaitingVerification)

//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (!mounted) return;

//               _handleExpiry(booking.payment.expiresAt);
//             });

//             return SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildHero(isDark),

//                     const SizedBox(height: 24),

//                     _buildSummaryCard(booking),

//                     const SizedBox(height: 18),

//                     _buildWalletCard(booking),

//                     const SizedBox(height: 18),

//                     _buildCountdownCard(),

//                     const SizedBox(height: 18),

//                     _buildTxidCard(booking, isDark),

//                     const SizedBox(height: 18),

//                     _buildNotesCard(isDark),

//                     const SizedBox(height: 30),

//                     SizedBox(
//                       height: 56,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: locked
//                             ? null
//                             : _submitting
//                             ? null
//                             : () => _submit(booking),
//                         child: _submitting
//                             ? const SizedBox(
//                                 width: 22,
//                                 height: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(getButtonText(booking)),
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                     if (!Navigator.canPop(context))
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.tertiary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const ShuttleBottomNavigation(
//                                 initialIndex: 0,
//                               ),
//                             ),
//                             (route) => false,
//                           );
//                         },
//                         child: Text(loc.backHome),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHero(bool isDark) {
//     return Column(
//       children: [
//         Container(
//           width: 90,
//           height: 90,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//           ),
//           child: Iconify(Cryptocurrency.usdt, size: 48, color: AppColors.tron),
//         ),
//         const SizedBox(height: 20),
//         Text(
//           loc.completeCryptoPayment,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           loc.completeWithiMinutes,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: isDark ? Colors.white70 : Colors.grey,
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard(ShuttleBooking booking) {
//     final crypto = booking.payment.crypto!;

//     return InfoCard(
//       title: loc.paymentSummary,
//       trailing: PaymentStatusChip(payment: booking.payment),
//       child: Column(
//         children: [
//           InfoRow(label: loc.booking, value: booking.bookingNumber),
//           InfoRow(
//             label: loc.amount,
//             value: "${crypto.amount.toStringAsFixed(2)} ${crypto.currency}",
//             bold: true,
//           ),
//           InfoRow(label: loc.network, value: crypto.network),
//         ],
//       ),
//     );
//   }

//   Widget _buildWalletCard(ShuttleBooking booking) {
//     final crypto = booking.payment.crypto!;

//     return InfoCard(
//       title: loc.walletAddress,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SelectableText(
//             crypto.walletAddress,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               letterSpacing: .3,
//             ),
//           ),

//           const SizedBox(height: 18),

//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               icon: const Icon(Icons.copy),
//               label: Text(loc.copyWalletAddress),
//               onPressed: () async {
//                 await Clipboard.setData(
//                   ClipboardData(text: crypto.walletAddress),
//                 );

//                 if (!mounted) return;
//                 ReusableToast.success(
//                   context,
//                   loc.info,
//                   loc.walletAddressCopied,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCountdownCard() {
//     return InfoCard(
//       title: loc.timeRemaining,
//       child: Column(
//         children: [
//           Icon(Icons.timer_outlined, color: timerColor, size: 42),

//           const SizedBox(height: 12),

//           Text(
//             formattedTime,
//             style: TextStyle(
//               fontSize: 36,
//               fontWeight: FontWeight.bold,
//               color: timerColor,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(loc.paymentExpiresAutomatically, textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }

//   Widget _buildTxidCard(ShuttleBooking booking, bool isDark) {
//     return InfoCard(
//       title: loc.transactionHash,
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _txidController,
//               textInputAction: TextInputAction.done,
//               decoration: InputDecoration(
//                 hintText: loc.pasteYourTransactionHash,
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return loc.transactionHashRequired;
//                 }

//                 if (value.trim().length < 10) {
//                   return loc.pleaseEnterAValidHash;
//                 }

//                 return null;
//               },
//             ),

//             const SizedBox(height: 12),

//             Text(
//               loc.weWillVerifyYourPayment,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotesCard(bool isDark) {
//     return InfoCard(
//       title: loc.important,
//       child: Column(
//         children: [
//           _PaymentNote(
//             icon: Icons.check_circle_outline,
//             text: loc.sendTheExactAmount,
//           ),

//           SizedBox(height: 12),

//           _PaymentNote(
//             icon: Icons.account_tree_outlined,
//             text: loc.onlyUseTheDisplayedBlockchain,
//           ),

//           SizedBox(height: 12),

//           _PaymentNote(
//             icon: Icons.access_time,
//             text: loc.paymentsSubmittedAfterExpiry,
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _submit(ShuttleBooking booking) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _submitting = true;
//     });

//     try {
//       await _repository.submitCryptoPayment(
//         bookingId: booking.id,
//         txid: _txidController.text.trim(),
//       );

//       if (!mounted) return;

//       ReusableToast.success(
//         context,
//         loc.success,
//         loc.paymentSubmittedSuccessfully,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ReusableToast.error(context, loc.error, e.toString());
//     }

//     if (mounted) {
//       setState(() {
//         _submitting = false;
//       });
//     }
//   }
// }

// class _PaymentNote extends StatelessWidget {
//   final IconData icon;

//   final String text;

//   const _PaymentNote({required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: isDark ? AppColors.lightLayer : AppColors.primary,
//         ),

//         const SizedBox(width: 12),

//         Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
//       ],
//     );
//   }
// }
