import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

class ActiveRideWidget extends StatefulWidget {
  const ActiveRideWidget({super.key});

  @override
  State<ActiveRideWidget> createState() => _ActiveRideWidgetState();
}

class _ActiveRideWidgetState extends State<ActiveRideWidget> {
  String _etaText = "Fetching ETA...";
  LatLng? _driverLatLng;
  StreamSubscription? _driverLocationSub;
  bool requestPositionInfo = true;

  // Track which rideId we are currently subscribed to for driverLocation
  String? _subscribedRideId;

  // bool _endDialogShown = false;

  @override
  void dispose() {
    _driverLocationSub?.cancel();
    super.dispose();
  }

  Future<void> _updateETAAndProgress({
    LatLng? targetLatLng,
    required String status,
  }) async {
    if (_driverLatLng == null || targetLatLng == null) return;

    final directionDetails =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          _driverLatLng!,
          targetLatLng,
        );

    if (directionDetails != null && mounted) {
      final durationText = directionDetails.durationText;

      setState(() {
        if (status == 'accepted') {
          _etaText =
              "${AppLocalizations.of(context)!.arrivingIn} $durationText";
        } else if (status == 'ontrip') {
          _etaText =
              "${AppLocalizations.of(context)!.reachingDestinationIn} $durationText";
        }
      });
    }
  }

  LatLng? parseLatLng(dynamic data) {
    if (data is Map) {
      return LatLng(
        double.tryParse(data['latitude'].toString()) ?? 0.0,
        double.tryParse(data['longitude'].toString()) ?? 0.0,
      );
    } else if (data is String) {
      final decoded = jsonDecode(data);
      return LatLng(
        double.tryParse(decoded['latitude'].toString()) ?? 0.0,
        double.tryParse(decoded['longitude'].toString()) ?? 0.0,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Consumer<AppInfo>(
      builder: (context, appInfo, _) {
        final ride = appInfo.activeRideData;
        if (ride == null) {
          return const SizedBox.shrink();
        }

        final status = ride['status'] ?? '';
        final driverName = ride['driverName'] ?? 'Your driver';
        final model = ride['model'] ?? '';
        final numberPlate = ride['numberPlate'] ?? '';
        final colour = ride['colour'] ?? '';
        final driverRating = ride['ratings'] ?? 0.0;
        final driverPhotoUrl = ride['driverPhotoUrl'] ?? '';
        final rideId = appInfo.rideId;
        final driverPhone = ride['driverPhone'] ?? '';

        // Live driver location listener
        final driverLocationPath = rideId != null
            ? 'All Ride Requests/$rideId/driverLocation'
            : null;

        // If rideId changed, cancel previous sub so we can subscribe to new one
        if (driverLocationPath != null && _subscribedRideId != rideId) {
          // cancel old
          _driverLocationSub?.cancel();
          _driverLocationSub = null;
          _subscribedRideId = rideId;

          final driverLocationRef = FirebaseDatabase.instance.ref().child(
            driverLocationPath,
          );

          _driverLocationSub = driverLocationRef.onValue.listen((event) async {
            final data = event.snapshot.value;
            if (data == null) return;
            final driverLatLng = parseLatLng(data);
            if (driverLatLng == null) return;

            _driverLatLng = LatLng(
              driverLatLng.latitude,
              driverLatLng.longitude,
            );

            // 🔥 Get live status from Provider instead of stale variable
            if (!context.mounted) return;
            final statusNow =
                Provider.of<AppInfo>(
                  context,
                  listen: false,
                ).activeRideData?['status'] ??
                '';

            final origin = ride['origin'];
            final destination = ride['destination'];

            LatLng? targetLatLng;

            if (statusNow == '') {
              setState(() {
                _etaText = AppLocalizations.of(context)!.driverIsWaiting;
              });
              return;
            } else if (statusNow == 'accepted') {
              targetLatLng = LatLng(
                double.parse(origin['latitude'].toString()),
                double.parse(origin['longitude'].toString()),
              );
            } else if (statusNow == 'ontrip') {
              targetLatLng = LatLng(
                double.parse(destination['latitude'].toString()),
                double.parse(destination['longitude'].toString()),
              );
            } else if (statusNow == 'arrived') {
              setState(() {
                _etaText = AppLocalizations.of(context)!.driverIsWaiting;
              });
              return;
            } else if (statusNow == 'ended') {
              setState(() {
                _etaText = '';
              });
              return;
            }

            if (targetLatLng == null) return;

            await _updateETAAndProgress(
              targetLatLng: targetLatLng,
              status: statusNow,
            );

            if (mounted) setState(() {});
          });
        }

        return Container(
          padding: EdgeInsets.all(8),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkLayer : AppColors.lightAccent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                status == 'ontrip'
                    ? AppLocalizations.of(context)!.onTrip
                    : status == 'accepted'
                    ? AppLocalizations.of(context)!.driverIsComing
                    : AppLocalizations.of(context)!.driverHasArrived,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3),
              Text(_etaText),
              SizedBox(height: 5),
              Divider(thickness: 0.3),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  driverPhotoUrl != ''
                      ? CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          backgroundImage: NetworkImage(driverPhotoUrl),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            driverName[0],
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      StarRating(rating: (driverRating * 1.0), size: 16),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(model),
                          const SizedBox(width: 4),
                          const Icon(Icons.circle, size: 6),
                          const SizedBox(width: 4),
                          Text(colour),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              numberPlate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(thickness: 0.3),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(context, driverPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor: Colors.white54,
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call),
                          SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.callDriver),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    iconSize: 32,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.cancelRide),
                          content: Text(
                            AppLocalizations.of(context)!.areYouSureCancelRide,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLocalizations.of(context)!.no),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                AppLocalizations.of(context)!.yesCancel,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        if (!context.mounted) return;
                        await appInfo.cancelRide(context);
                      }
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.tertiary,
                    ),
                    icon: Icon(Icons.cancel),
                    tooltip: AppLocalizations.of(context)!.cancelRide,
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
