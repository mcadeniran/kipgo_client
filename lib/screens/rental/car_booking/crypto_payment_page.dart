import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/statuses.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/wallet.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toastification/toastification.dart';

class CryptoPaymentPage extends StatefulWidget {
  final String bookingId;
  const CryptoPaymentPage({super.key, required this.bookingId});

  @override
  State<CryptoPaymentPage> createState() => _CryptoPaymentPageState();
}

class _CryptoPaymentPageState extends State<CryptoPaymentPage> {
  late WalletModel wallet;
  BookingModel? booking;

  final cryptoFormKey = GlobalKey<FormState>();

  final ScrollController scrollController = ScrollController();

  final TextEditingController txid = TextEditingController();

  late AppLocalizations loc;

  bool isLoading = true;

  bool isSubmitting = false;

  Duration? remaining;

  Timer? timer;

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

      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (!snap.exists) {
        booking = null;
        return;
      }

      booking = BookingModel.fromFirestore(snap);

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

      if (booking?.payment?.crypto?.txid != null) {
        txid.text = booking!.payment!.crypto!.txid!;
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

    if (booking?.payment?.expiresAt == null) return;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final expiresAt = booking!.payment!.expiresAt!;

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
          .collection('bookings')
          .doc(booking!.id)
          .update({
            "status": "expired",
            "expiredAt": FieldValue.serverTimestamp(),
            "payment.expiresAt": null,
            "payment.status": PaymentStatuses.expired,
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
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
            "status": BookingStatuses.paymentSubmitted,

            "payment.crypto.txid": txid.text.trim(),

            "payment.crypto.status": PaymentStatuses.awaitingVerification,

            "payment.crypto.txidSubmittedAt": FieldValue.serverTimestamp(),

            "payment.crypto.submittedAt": FieldValue.serverTimestamp(),

            "payment.expiresAt": null,

            "payment.status": PaymentStatuses.awaitingVerification,
          });

      if (mounted) {
        ReusableToast.success(
          context,
          loc.paymentSubmitted,
          "Your transaction hash has been submitted successfully.",
        );

        Navigator.pop(context);
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

    final crypto = booking?.payment?.crypto;

    return Scaffold(
      appBar: AppBarWidget(title: loc.checkout),
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.all(12),
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
                                amount: booking!.totalPrice,
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
                            : Text('I HAVE PAID'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
