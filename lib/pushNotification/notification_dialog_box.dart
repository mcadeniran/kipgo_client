import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/ringtone_service.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/fare_status_listener.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/screens/rides/drivers/new_trip_screen.dart';
import 'package:kipgo/utils/colors.dart';

class _RideRequestSheetContent extends StatefulWidget {
  final UserRideRequestInformation ride;
  final GlobalKey<FormState> priceKey;
  final TextEditingController priceController;
  final VoidCallback? onDialogClosed;

  const _RideRequestSheetContent({
    required this.ride,
    required this.priceKey,
    required this.priceController,
    required this.onDialogClosed,
  });

  @override
  State<_RideRequestSheetContent> createState() =>
      _RideRequestSheetContentState();
}

class _RideRequestSheetContentState extends State<_RideRequestSheetContent> {
  final AudioPlayer player = AudioPlayer();

  StreamSubscription? fareSubscription;

  bool _isShowingSingleDialog = false;

  bool _isAcceptingRide = false;
  bool _isNewTripNavigating = false;

  BuildContext get safeContext {
    if (mounted) return context;

    if (navigatorKey.currentContext != null) {
      return navigatorKey.currentContext!;
    }

    throw Exception("No valid context available");
  }

  Future<void> _resetDriverToIdle() async {
    try {
      final driverId = Provider.of<ProfileProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).profile!.id;

      await FirebaseDatabase.instance.ref("drivers/$driverId").update({
        "status": "idle",
        "currentRideId": null,
        "pendingSince": null,
      });

      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(driverId)
          .update({"newRideStatus": "idle"});

      debugPrint("✅ Driver reset to idle");
    } catch (e) {
      debugPrint("❌ Failed to reset driver: $e");
    }
  }

  Future<bool> _isRideStillAvailable() async {
    final ref = FirebaseDatabase.instance.ref(
      "All Ride Requests/${widget.ride.rideRequestId}",
    );

    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await releaseDriverRideLock();
      return false;
    }

    return true;
  }

  Future<bool> _guardRideAvailability() async {
    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return false;
    }

    return true;
  }

  Future<void> _showRideCancelledDialog() async {
    await _resetDriverToIdle();

    await _showSingleDialog(
      title: AppLocalizations.of(safeContext)!.rideCancelled,
      message: AppLocalizations.of(safeContext)!.riderHasCancelledTheRequest,
      onOk: () {
        Navigator.of(navigatorKey.currentContext!).pop();
      },
    );
  }

  Future<void> proposeFare(double enteredFare) async {
    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _resetDriverToIdle();
      await _showRideCancelledDialog();
      return;
    }

    final driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;

    await FirebaseDatabase.instance
        .ref('All Ride Requests/${widget.ride.rideRequestId}')
        .update({
          "proposedFare": enteredFare,
          "fareStatus": "waiting_for_rider",
        });

    await FirebaseDatabase.instance.ref("drivers/$driverId").update({
      "status": "fare_proposed",
    });
  }

  Future<void> releaseDriverRideLock() async {
    final driverId = Provider.of<ProfileProvider>(
      navigatorKey.currentContext!,
      listen: false,
    ).profile!.id;

    final rideRequestId = widget.ride.rideRequestId;

    try {
      debugPrint('════════════════════════════════');
      debugPrint('🔓 REQUESTING DRIVER LOCK RELEASE');
      debugPrint('👤 Driver: $driverId');
      debugPrint('🆔 Ride: $rideRequestId');

      final callable = FirebaseFunctions.instance.httpsCallable(
        'releaseDriverRideLock',
      );

      final response = await callable.call({
        'driverId': driverId,
        'rideRequestId': rideRequestId,
      });

      debugPrint('📨 RELEASE RESPONSE: ${response.data}');
      debugPrint('════════════════════════════════');
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '❌ RELEASE LOCK FAILED: '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ RELEASE LOCK ERROR: $e');
    }
  }

  Future<void> _showSingleDialog({
    required String title,
    required String message,
    required VoidCallback onOk,
    // String okLabel = "OK",
  }) async {
    if (_isShowingSingleDialog) return;

    _isShowingSingleDialog = true;

    BuildContext dialogCtx;

    try {
      dialogCtx = safeContext;
    } catch (_) {
      _isShowingSingleDialog = false;
      return;
    }

    if (!mounted) {
      _isShowingSingleDialog = false;
      return;
    }

    await showDialog<void>(
      context: dialogCtx,
      barrierDismissible: false,
      builder: (c) {
        final theme = Theme.of(c);
        final isDark = Provider.of<ThemeProvider>(c, listen: false).isDarkMode;

        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkAccent : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(c)) {
                  Navigator.pop(c);
                }

                onOk();
              },
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _isShowingSingleDialog = false;
    });
  }

  void _closeProgressDialogSafely() {
    final ctx = navigatorKey.currentState?.overlay?.context;

    if (ctx == null) return;

    if (Navigator.of(ctx).canPop()) {
      Navigator.of(ctx).pop();
    }
  }

  // ───────────
  // ACCEPT RIDE
  // ───────────
  Future<void> acceptRide() async {
    if (_isAcceptingRide || _isNewTripNavigating) {
      debugPrint('⚠️ Accept ride ignored: already processing/navigation.');
      return;
    }

    _isAcceptingRide = true;

    widget.onDialogClosed?.call();

    try {
      final isAvailable = await _isRideStillAvailable();

      if (!isAvailable) {
        if (mounted) {
          await _showRideCancelledDialog();
        }
        return;
      }

      final driverProfile = Provider.of<ProfileProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).profile;

      if (driverProfile == null) {
        debugPrint('❌ Driver profile is null.');
        return;
      }

      final driverId = driverProfile.id;
      final rideRequestId = widget.ride.rideRequestId;

      if (rideRequestId == null || rideRequestId.isEmpty) {
        debugPrint('❌ Ride request ID is missing.');
        return;
      }

      final rideSnapshot = await FirebaseDatabase.instance
          .ref('All Ride Requests/$rideRequestId')
          .get();

      if (!rideSnapshot.exists) {
        debugPrint('❌ Ride request no longer exists.');
        await _resetDriverToIdle();
        return;
      }

      await Provider.of<DriverStatusProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).forceOfflineForTrip(driverId);

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(driverId)
          .update({'newRideStatus': 'accepted'});

      await releaseDriverRideLock();

      // ----------------------------------------------------------
      // 🔒 Prevent duplicate navigation
      // ----------------------------------------------------------
      if (_isNewTripNavigating) {
        debugPrint('⚠️ NewTripScreen navigation already started.');
        return;
      }

      _isNewTripNavigating = true;

      final navigationContext = navigatorKey.currentContext;

      if (navigationContext == null) {
        debugPrint('❌ Navigation context is null.');
        _isNewTripNavigating = false;
        return;
      }

      debugPrint('🚗 Navigating to NewTripScreen ONCE');

      await Navigator.of(navigationContext).push(
        MaterialPageRoute(
          builder: (_) => NewTripScreen(userRideRequestDetails: widget.ride),
        ),
      );

      // This executes when NewTripScreen is popped.
      _isNewTripNavigating = false;
    } catch (e, stackTrace) {
      debugPrint('❌ Accept error: $e');
      debugPrint('$stackTrace');

      _isNewTripNavigating = false;
    } finally {
      _isAcceptingRide = false;
    }
  }

  // ───────────
  // REJECT RIDE
  // ───────────
  void rejectRide() async {
    widget.onDialogClosed?.call();

    final isAvailable = await _isRideStillAvailable();

    if (!isAvailable) {
      await _showRideCancelledDialog();
      return;
    }

    final driverId = Provider.of<ProfileProvider>(
      navigatorKey.currentContext!,
      listen: false,
    ).profile!.id;

    try {
      await FirebaseDatabase.instance
          .ref("All Ride Requests/${widget.ride.rideRequestId}")
          .update({"status": "rejected"});

      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(driverId)
          .update({'newRideStatus': 'idle'});

      await FirebaseDatabase.instance.ref("drivers/$driverId").update({
        "status": "idle",
        "currentRideId": null,
        "pendingSince": null,
      });

      // 🔓 RELEASE NOTIFICATION LOCK
      // await AppMethods.releaseDriverRideLock(rideRequestId ?? '');
      await releaseDriverRideLock();

      Navigator.of(navigatorKey.currentContext!).pop();
    } catch (e) {
      debugPrint("Reject error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    PushNotificationSystem().registerRideCallbacks(
      onAccept: () {
        acceptRide();
      },
      onReject: () {},
    );
  }

  @override
  void dispose() {
    fareSubscription?.cancel();
    RingtoneService().stop();
    player.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // PREMIUM UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final backgroundColor = isDark
        ? const Color(0xFF10101C)
        : const Color(0xFFF7F7FB);

    final cardColor = isDark ? const Color(0xFF191929) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF16162A);

    final secondaryText = isDark ? Colors.white70 : const Color(0xFF707080);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: .08)
        : const Color(0xFFE9E9EF);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─────────────────────────────
          // DRAG HANDLE
          // ─────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // ─────────────────────────────
          // HEADER
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: .72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .22),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/taksi.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newRideRequest,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                          letterSpacing: -.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.estimatedDetailsToPickup,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.newLabel,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─────────────────────────────
          // ROUTE CARD
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .035),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                children: [
                  _routePoint(
                    context: context,
                    iconAsset: 'assets/images/origin.png',
                    iconColor: isDark ? Colors.tealAccent : AppColors.primary,
                    title: loc.pickupCap,
                    address: widget.ride.originAddress ?? "-",
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 13, top: 3, bottom: 3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  _routePoint(
                    context: context,
                    iconAsset: 'assets/images/destination.png',
                    iconColor: AppColors.tertiary,
                    title: loc.destinationCap,
                    address: widget.ride.destinationAddress ?? "-",
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ─────────────────────────────
          // PICKUP METRICS
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _sectionLabel(
                  context,
                  AppLocalizations.of(context)!.estimatedDetailsToPickup,
                  primaryText,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        context: context,
                        icon: Icons.near_me_rounded,
                        value: loc.distanceKM(
                          widget.ride.driverDistanceKm?.toStringAsFixed(1) ??
                              '0.0',
                        ),
                        label: loc.distanceCap,
                        iconColor: isDark
                            ? Colors.tealAccent
                            : AppColors.primary,
                        cardColor: cardColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        borderColor: borderColor,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricCard(
                        context: context,
                        icon: Icons.schedule_rounded,
                        value: loc.mins(widget.ride.driverEtaMin ?? 0),
                        label: loc.eta,
                        iconColor: AppColors.secondary,
                        cardColor: cardColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        borderColor: borderColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ─────────────────────────────
          // TRIP METRICS
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _sectionLabel(
                  context,
                  AppLocalizations.of(context)!.estimatedDetailsToDropoff,
                  primaryText,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        context: context,
                        icon: Icons.route_rounded,
                        value: loc.distanceKM(
                          widget.ride.tripDistanceKm?.toStringAsFixed(1) ??
                              '0.0',
                        ),
                        label: loc.tripCap,
                        iconColor: AppColors.tertiary,
                        cardColor: cardColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        borderColor: borderColor,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricCard(
                        context: context,
                        icon: Icons.timer_outlined,
                        value: loc.mins(widget.ride.tripDurationMin ?? 0),
                        label: loc.durationCap,
                        iconColor: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                        cardColor: cardColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        borderColor: borderColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─────────────────────────────
          // FARE SECTION
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? .08 : .05,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: widget.priceKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.lightLayer.withValues(alpha: .08)
                                : AppColors.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.payments_rounded,
                            color: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.enterFare,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.enterPrice,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: widget.priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                      cursorColor: isDark
                          ? AppColors.lightLayer
                          : AppColors.primary,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        hintStyle: TextStyle(
                          color: secondaryText.withValues(alpha: .45),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 12, right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.lightLayer.withValues(alpha: .08)
                                : AppColors.primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "₺",
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: .035)
                            : const Color(0xFFF8F8FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.priceCannotBeEmpty;
                        }

                        final cleaned = value.replaceAll(",", "").trim();

                        final amount = double.tryParse(cleaned);

                        if (amount == null) {
                          return AppLocalizations.of(context)!.invalidFare;
                        }

                        if (amount < 1) {
                          return AppLocalizations.of(
                            context,
                          )!.fareCannotBeLessThan;
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ─────────────────────────────
          // ACTION BUTTONS
          // ─────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context: context,
                    label: AppLocalizations.of(context)!.reject,
                    icon: Icons.close_rounded,
                    backgroundColor: AppColors.tertiary.withValues(alpha: .10),
                    foregroundColor: AppColors.tertiary,
                    onPressed: rejectRide,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: _actionButton(
                    context: context,
                    label: AppLocalizations.of(context)!.accept,
                    icon: Icons.check_rounded,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevated: true,
                    onPressed: () async {
                      if (!widget.priceKey.currentState!.validate()) {
                        return;
                      }

                      final canProceed = await _guardRideAvailability();

                      if (!canProceed) return;

                      if (!mounted) return;

                      Navigator.of(context).pop();

                      showDialog(
                        context: navigatorKey.currentContext!,
                        barrierDismissible: false,
                        builder: (_) => ProgressDialog(
                          message: AppLocalizations.of(
                            context,
                          )!.waitingForRiderResponse,
                        ),
                      );

                      await proposeFare(
                        double.parse(
                          widget.priceController.text.replaceAll(",", ""),
                        ),
                      );

                      FareStatusListener.start(
                        rideRequestId: widget.ride.rideRequestId!,
                        onAccepted: () {
                          _closeProgressDialogSafely();

                          FareStatusListener.stop();

                          PushNotificationSystem().showFareAcceptedDialog(
                            widget.ride,
                          );
                        },
                        onRejected: () async {
                          _closeProgressDialogSafely();

                          FareStatusListener.stop();

                          await _resetDriverToIdle();

                          PushNotificationSystem().showFareRejectedDialog();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ROUTE POINT
  // ─────────────────────────────────────────────

  Widget _routePoint({
    required BuildContext context,
    required String iconAsset,
    required Color iconColor,
    required String title,
    required String address,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(iconAsset, color: iconColor),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: .15,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // METRIC CARD
  // ─────────────────────────────────────────────

  Widget _metricCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTION BUTTON
  // ─────────────────────────────────────────────

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
    bool elevated = false,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevated ? 5 : 0,
          shadowColor: elevated
              ? AppColors.primary.withValues(alpha: .28)
              : Colors.transparent,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showRideRequestBottomSheet({
  required BuildContext context,
  required UserRideRequestInformation ride,
  required VoidCallback? onDialogClosed,
  required GlobalKey<FormState> priceKey,
  required TextEditingController priceController,
}) async {
  final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: isDark ? .68 : .45),
    builder: (sheetContext) {
      final keyboard = MediaQuery.of(sheetContext).viewInsets.bottom;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboard),
        child: SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * .92,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10101C) : const Color(0xFFF7F7FB),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: _RideRequestSheetContent(
                ride: ride,
                priceKey: priceKey,
                priceController: priceController,
                onDialogClosed: onDialogClosed,
              ),
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {
    onDialogClosed?.call();
  });
}
