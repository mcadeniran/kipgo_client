import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

class ActiveRideWidget extends StatefulWidget {
  const ActiveRideWidget({super.key});

  @override
  State<ActiveRideWidget> createState() => _ActiveRideWidgetState();
}

class _ActiveRideWidgetState extends State<ActiveRideWidget>
    with TickerProviderStateMixin {
  // --- DRIVER MARKER ANIMATION --- //
  BitmapDescriptor? _driverIcon;
  LatLng? _lastDriverPosition;
  double _lastRotation = 0.0;

  // AnimationController? _driverAnimController;
  late final AnimationController _driverAnimController;

  // Animation<double>? _driverAnimation;

  LatLng? _animationStartPosition;
  LatLng? _animationEndPosition;

  double _animationStartRotation = 0.0;
  double _animationEndRotation = 0.0;

  GoogleMapController? _miniMapController;
  Set<Polyline> _miniPolylines = {};
  final Set<Marker> _miniMarkers = {};
  final List<LatLng> _miniRoutePoints = [];

  bool _mapReady = false;

  String _etaText = "Fetching ETA...";
  LatLng? _driverLatLng;
  StreamSubscription? _driverLocationSub;
  bool requestPositionInfo = true;

  String? _mapStyle;

  // Track which rideId currently subscribed to for driverLocation
  String? _subscribedRideId;

  // bool _endDialogShown = false;

  // @override
  // void initState() {
  //   super.initState();

  //   WakelockPlus.enable();

  //   bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  //   if (isDark) {
  //     _loadMapStyle();
  //   }

  //   _loadDriverMarker();
  // }

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();

    _driverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _driverAnimController.addListener(_handleDriverAnimation);

    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDark) {
      _loadMapStyle();
    }

    _loadDriverMarker();
  }

  void _handleDriverAnimation() {
    if (!mounted) return;

    if (_animationStartPosition == null || _animationEndPosition == null) {
      return;
    }

    final t = Curves.easeInOut.transform(_driverAnimController.value);

    final latitude =
        _animationStartPosition!.latitude +
        (_animationEndPosition!.latitude - _animationStartPosition!.latitude) *
            t;

    final longitude =
        _animationStartPosition!.longitude +
        (_animationEndPosition!.longitude -
                _animationStartPosition!.longitude) *
            t;

    final rotation = _interpolateRotation(
      _animationStartRotation,
      _animationEndRotation,
      t,
    );

    _updateDriverMarker(LatLng(latitude, longitude), rotation);
  }

  double _normalizeRotation(double rotation) {
    return rotation % 360;
  }

  double _interpolateRotation(double start, double end, double t) {
    start = _normalizeRotation(start);
    end = _normalizeRotation(end);

    double difference = end - start;

    if (difference > 180) {
      difference -= 360;
    } else if (difference < -180) {
      difference += 360;
    }

    return _normalizeRotation(start + difference * t);
  }

  Future<void> _loadDriverMarker() async {
    ImageConfiguration imageConfiguration = ImageConfiguration(
      size: Size(30, 30),
    );

    BitmapDescriptor.asset(
      imageConfiguration,
      'assets/images/car.png',
    ).then((value) => _driverIcon = value);
  }

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x);
    bearing = bearing * 180 / pi;
    return (bearing + 360) % 360;
  }

  // void _animateDriverMovement(LatLng newPos) {
  //   if (_driverIcon == null) return;

  //   if (_lastDriverPosition == null) {
  //     _lastDriverPosition = newPos;
  //     _updateDriverMarker(newPos, _lastRotation);
  //     return;
  //   }

  //   final latTween = Tween<double>(
  //     begin: _lastDriverPosition!.latitude,
  //     end: newPos.latitude,
  //   );

  //   final lngTween = Tween<double>(
  //     begin: _lastDriverPosition!.longitude,
  //     end: newPos.longitude,
  //   );

  //   final rotationTween = Tween<double>(
  //     begin: _lastRotation,
  //     end: _calculateBearing(_lastDriverPosition!, newPos),
  //   );

  //   _driverAnimController?.dispose();
  //   _driverAnimController = AnimationController(
  //     duration: const Duration(milliseconds: 900),
  //     vsync: this,
  //   );

  //   final animation = CurvedAnimation(
  //     parent: _driverAnimController!,
  //     curve: Curves.easeInOut,
  //   );

  //   _driverAnimController!.addListener(() {
  //     final animatedLat = latTween.evaluate(animation);
  //     final animatedLng = lngTween.evaluate(animation);
  //     final animatedRotation = rotationTween.evaluate(animation);

  //     _updateDriverMarker(LatLng(animatedLat, animatedLng), animatedRotation);
  //   });

  //   _driverAnimController!.forward();

  //   _lastDriverPosition = newPos;
  //   _lastRotation = rotationTween.end!;
  // }

  void _animateDriverMovement(LatLng newPosition) {
    if (_driverIcon == null) return;

    // First location received.
    if (_lastDriverPosition == null) {
      _lastDriverPosition = newPosition;

      _animationStartPosition = newPosition;
      _animationEndPosition = newPosition;

      _animationStartRotation = _lastRotation;
      _animationEndRotation = _lastRotation;

      _updateDriverMarker(newPosition, _lastRotation);

      return;
    }

    final newRotation = _calculateBearing(_lastDriverPosition!, newPosition);

    _animationStartPosition = _lastDriverPosition;
    _animationEndPosition = newPosition;

    _animationStartRotation = _lastRotation;
    _animationEndRotation = newRotation;

    _lastDriverPosition = newPosition;
    _lastRotation = newRotation;

    // Restart the same persistent controller.
    _driverAnimController
      ..stop()
      ..value = 0.0
      ..forward();
  }

  void _updateDriverMarker(LatLng pos, double rotation) {
    if (_driverIcon == null) return;

    _miniMarkers.removeWhere((m) => m.markerId.value == 'driver');

    _miniMarkers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: pos,
        icon: _driverIcon!,
        flat: true,
        rotation: rotation,
        anchor: const Offset(0.5, 0.5),
      ),
    );

    if (mounted) setState(() {});
  }

  // @override
  // void dispose() {
  //   _driverLocationSub?.cancel();
  //   WakelockPlus.disable();
  //   super.dispose();
  // }

  @override
  void dispose() {
    _driverLocationSub?.cancel();

    _driverAnimController.removeListener(_handleDriverAnimation);

    _driverAnimController.dispose();

    WakelockPlus.disable();

    super.dispose();
  }

  Future<void> _drawMiniMapPolyline(LatLng origin, LatLng destination) async {
    final details = await AppMethods.obtainOriginToDestinationDirectionDetails(
      origin,
      destination,
    );

    if (details == null) return;

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(
      details.ePoints!,
    );

    _miniRoutePoints.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var point in decodedPolylinePointsResultList) {
        _miniRoutePoints.add(LatLng(point.latitude, point.longitude));
      }
    }

    _miniPolylines = {
      Polyline(
        polylineId: const PolylineId("mini_route"),
        points: _miniRoutePoints,
        color: AppColors.tertiary,
        width: 4,
      ),
    };

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
        final driverRating = (ride['ratings'] ?? 0.0) * 1.0;
        final driverPhotoUrl = ride['driverPhotoUrl'] ?? '';
        final rideId = appInfo.rideId;
        final driverPhone = ride['driverPhone'] ?? '';

        // ------------------------------------------------------------
        // LIVE DRIVER LOCATION
        // ------------------------------------------------------------

        final driverLocationPath = rideId != null
            ? 'All Ride Requests/$rideId/driverLocation'
            : null;

        if (driverLocationPath != null && _subscribedRideId != rideId) {
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

            // ----------------------------------------------------------
            // DRIVER MARKER
            // ----------------------------------------------------------

            if (_driverLatLng != null) {
              _animateDriverMovement(_driverLatLng!);
            }

            // ----------------------------------------------------------
            // PICKUP + DESTINATION MARKERS
            // ----------------------------------------------------------

            final originLatLng = LatLng(
              double.parse(origin['latitude'].toString()),
              double.parse(origin['longitude'].toString()),
            );

            final destinationLatLng = LatLng(
              double.parse(destination['latitude'].toString()),
              double.parse(destination['longitude'].toString()),
            );

            _miniMarkers.removeWhere((m) => m.markerId.value == 'pickup');

            _miniMarkers.removeWhere((m) => m.markerId.value == 'destination');

            _miniMarkers.add(
              Marker(
                markerId: const MarkerId('pickup'),
                position: originLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            );

            _miniMarkers.add(
              Marker(
                markerId: const MarkerId('destination'),
                position: destinationLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );

            // ----------------------------------------------------------
            // ROUTE
            // ----------------------------------------------------------

            if (statusNow == 'accepted') {
              _drawMiniMapPolyline(_driverLatLng!, originLatLng);
            } else if (statusNow == 'ontrip') {
              _drawMiniMapPolyline(originLatLng, destinationLatLng);
            }

            // ----------------------------------------------------------
            // CAMERA
            // ----------------------------------------------------------

            if (_mapReady &&
                _miniMapController != null &&
                _driverLatLng != null) {
              _miniMapController!.animateCamera(
                CameraUpdate.newLatLng(_driverLatLng!),
              );
            }

            if (mounted) {
              setState(() {});
            }

            // ----------------------------------------------------------
            // ETA
            // ----------------------------------------------------------

            if (statusNow == '') {
              if (mounted) {
                setState(() {
                  _etaText = AppLocalizations.of(context)!.driverIsWaiting;
                });
              }
              return;
            }

            if (statusNow == 'accepted') {
              targetLatLng = originLatLng;
            } else if (statusNow == 'ontrip') {
              targetLatLng = destinationLatLng;
            } else if (statusNow == 'arrived') {
              if (mounted) {
                setState(() {
                  _etaText = AppLocalizations.of(context)!.driverIsWaiting;
                });
              }
              return;
            } else if (statusNow == 'ended') {
              if (mounted) {
                setState(() {
                  _etaText = '';
                });
              }
              return;
            }

            if (targetLatLng == null) return;

            await _updateETAAndProgress(
              targetLatLng: targetLatLng,
              status: statusNow,
            );

            if (mounted) {
              setState(() {});
            }
          });
        }

        // --------------------------------------------------------------
        // STATUS CONFIGURATION
        // --------------------------------------------------------------

        late String statusTitle;
        late String statusSubtitle;
        late IconData statusIcon;

        if (status == 'accepted') {
          statusTitle = AppLocalizations.of(context)!.driverIsComing;
          statusSubtitle = _etaText;
          statusIcon = Icons.directions_car_filled_rounded;
        } else if (status == 'arrived') {
          statusTitle = AppLocalizations.of(context)!.driverHasArrived;
          statusSubtitle = AppLocalizations.of(context)!.driverIsWaiting;
          statusIcon = Icons.location_on_rounded;
        } else {
          statusTitle = AppLocalizations.of(context)!.onTrip;
          statusSubtitle = _etaText;
          statusIcon = Icons.navigation_rounded;
        }

        return Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // ========================================================
              // MAP
              // ========================================================
              Stack(
                children: [
                  SizedBox(
                    height: 235,
                    width: double.infinity,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _miniMapController = controller;
                        _mapReady = true;
                      },
                      style: isDark ? _mapStyle : null,
                      markers: _miniMarkers,
                      polylines: _miniPolylines,
                      initialCameraPosition: CameraPosition(
                        target:
                            _driverLatLng ??
                            const LatLng(
                              35.133428350758344,
                              33.923606022529256,
                            ),
                        zoom: 16,
                      ),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      liteModeEnabled: true,
                    ),
                  ),

                  // ----------------------------------------------------
                  // MAP GRADIENT
                  // ----------------------------------------------------
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ----------------------------------------------------
                  // LIVE BADGE
                  // ----------------------------------------------------
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkAccent.withValues(alpha: 0.94)
                            : Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Live',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ----------------------------------------------------
                  // STATUS BADGE
                  // ----------------------------------------------------
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            statusTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ========================================================
              // ETA / STATUS
              // ========================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lightLayer.withValues(alpha: .08)
                            : AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            statusSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.5,
                  color: isDark ? Colors.white12 : AppColors.border,
                ),
              ),

              // ========================================================
              // DRIVER
              // ========================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    // Driver avatar
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.lightLayer
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                        backgroundImage: driverPhotoUrl.isNotEmpty
                            ? NetworkImage(driverPhotoUrl)
                            : null,
                        child: driverPhotoUrl.isEmpty
                            ? Text(
                                driverName.isNotEmpty
                                    ? driverName[0].toUpperCase()
                                    : 'D',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Driver details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 17,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                driverRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  '$model${colour.isNotEmpty ? ' • $colour' : ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Number plate
                    if (numberPlate.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isDark ? Colors.white24 : AppColors.border,
                          ),
                        ),
                        child: Text(
                          numberPlate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.5,
                  color: isDark ? Colors.white12 : AppColors.border,
                ),
              ),

              // ========================================================
              // ACTIONS
              // ========================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: driverPhone.isEmpty
                            ? null
                            : () => _makePhoneCall(context, driverPhone),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.35,
                          ),
                          disabledForegroundColor: Colors.white54,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.phone_rounded, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.callDriver,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // CANCEL — ONLY WHILE DRIVER IS COMING
                    // --------------------------------------------------
                    if (status == 'accepted') ...[
                      const SizedBox(width: 10),

                      SizedBox(
                        height: 52,
                        width: 52,
                        child: IconButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black.withValues(
                                alpha: 0.55,
                              ),
                              builder: (dialogContext) {
                                final isDark = Provider.of<ThemeProvider>(
                                  dialogContext,
                                  listen: false,
                                ).isDarkMode;

                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      28,
                                      24,
                                      20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkAccent
                                          : Theme.of(
                                              dialogContext,
                                            ).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.45 : 0.18,
                                          ),
                                          blurRadius: 30,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // ─────────────────────────────
                                        // Cancellation Icon
                                        // ─────────────────────────────
                                        Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            color: AppColors.tertiary
                                                .withValues(
                                                  alpha: isDark ? 0.14 : 0.08,
                                                ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(9),
                                            decoration: BoxDecoration(
                                              color: AppColors.tertiary
                                                  .withValues(
                                                    alpha: isDark ? 0.20 : 0.12,
                                                  ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              size: 32,
                                              color: AppColors.tertiary,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        // ─────────────────────────────
                                        // Title
                                        // ─────────────────────────────
                                        Text(
                                          AppLocalizations.of(
                                            dialogContext,
                                          )!.cancelRide,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(dialogContext)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.3,
                                              ),
                                        ),

                                        const SizedBox(height: 10),

                                        // ─────────────────────────────
                                        // Confirmation message
                                        // ─────────────────────────────
                                        Text(
                                          AppLocalizations.of(
                                            dialogContext,
                                          )!.areYouSureCancelRide,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(dialogContext)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                height: 1.5,
                                                color: Theme.of(dialogContext)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.62),
                                              ),
                                        ),

                                        const SizedBox(height: 24),

                                        Divider(
                                          height: 1,
                                          color: Theme.of(dialogContext)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.08),
                                        ),

                                        const SizedBox(height: 18),

                                        // ─────────────────────────────
                                        // Actions
                                        // ─────────────────────────────
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 52,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    );
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Theme.of(dialogContext)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.75,
                                                            ),
                                                    side: BorderSide(
                                                      color:
                                                          Theme.of(
                                                                dialogContext,
                                                              )
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.12,
                                                              ),
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      dialogContext,
                                                    )!.no,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: SizedBox(
                                                height: 52,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.tertiary,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      dialogContext,
                                                    )!.yesCancel,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (confirmed == true) {
                              if (!context.mounted) return;

                              await appInfo.cancelRide(context);
                            }
                          },
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.tertiary,
                            backgroundColor: AppColors.tertiary.withValues(
                              alpha: 0.10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: AppLocalizations.of(context)!.cancelRide,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
  //   return Consumer<AppInfo>(
  //     builder: (context, appInfo, _) {
  //       final ride = appInfo.activeRideData;
  //       if (ride == null) {
  //         return const SizedBox.shrink();
  //       }

  //       final status = ride['status'] ?? '';
  //       final driverName = ride['driverName'] ?? 'Your driver';
  //       final model = ride['model'] ?? '';
  //       final numberPlate = ride['numberPlate'] ?? '';
  //       final colour = ride['colour'] ?? '';
  //       final driverRating = ride['ratings'] ?? 0.0;
  //       final driverPhotoUrl = ride['driverPhotoUrl'] ?? '';
  //       final rideId = appInfo.rideId;
  //       final driverPhone = ride['driverPhone'] ?? '';

  //       // Live driver location listener
  //       final driverLocationPath = rideId != null
  //           ? 'All Ride Requests/$rideId/driverLocation'
  //           : null;

  //       // If rideId changed, cancel previous sub so we can subscribe to new one
  //       if (driverLocationPath != null && _subscribedRideId != rideId) {
  //         // cancel old
  //         _driverLocationSub?.cancel();
  //         _driverLocationSub = null;
  //         _subscribedRideId = rideId;

  //         final driverLocationRef = FirebaseDatabase.instance.ref().child(
  //           driverLocationPath,
  //         );

  //         _driverLocationSub = driverLocationRef.onValue.listen((event) async {
  //           final data = event.snapshot.value;
  //           if (data == null) return;
  //           final driverLatLng = parseLatLng(data);
  //           if (driverLatLng == null) return;

  //           _driverLatLng = LatLng(
  //             driverLatLng.latitude,
  //             driverLatLng.longitude,
  //           );

  //           // 🔥 Get live status from Provider instead of stale variable
  //           if (!context.mounted) return;
  //           final statusNow =
  //               Provider.of<AppInfo>(
  //                 context,
  //                 listen: false,
  //               ).activeRideData?['status'] ??
  //               '';

  //           final origin = ride['origin'];
  //           final destination = ride['destination'];

  //           LatLng? targetLatLng;

  //           // --- UPDATE MINI MAP MARKERS --- //
  //           if (_driverLatLng != null) {
  //             if (_driverLatLng != null) {
  //               _animateDriverMovement(_driverLatLng!);
  //             }
  //           }

  //           // Pickup and destination markers
  //           final originLatLng = LatLng(
  //             double.parse(origin['latitude'].toString()),
  //             double.parse(origin['longitude'].toString()),
  //           );

  //           final destinationLatLng = LatLng(
  //             double.parse(destination['latitude'].toString()),
  //             double.parse(destination['longitude'].toString()),
  //           );

  //           _miniMarkers.removeWhere((m) => m.markerId.value == 'pickup');
  //           _miniMarkers.removeWhere((m) => m.markerId.value == 'destination');

  //           _miniMarkers.add(
  //             Marker(
  //               markerId: const MarkerId('pickup'),
  //               position: originLatLng,
  //               icon: BitmapDescriptor.defaultMarkerWithHue(
  //                 BitmapDescriptor.hueGreen,
  //               ),
  //             ),
  //           );

  //           _miniMarkers.add(
  //             Marker(
  //               markerId: const MarkerId('destination'),
  //               position: destinationLatLng,
  //               icon: BitmapDescriptor.defaultMarkerWithHue(
  //                 BitmapDescriptor.hueRed,
  //               ),
  //             ),
  //           );

  //           // --- DRAW ROUTE BASED ON STATUS --- //
  //           if (statusNow == 'accepted') {
  //             _drawMiniMapPolyline(_driverLatLng!, originLatLng);
  //           } else if (statusNow == 'ontrip') {
  //             _drawMiniMapPolyline(originLatLng, destinationLatLng);
  //           }

  //           // Update camera position once map is ready
  //           if (_mapReady &&
  //               _miniMapController != null &&
  //               _driverLatLng != null) {
  //             _miniMapController!.animateCamera(
  //               CameraUpdate.newLatLng(_driverLatLng!),
  //             );
  //           }

  //           setState(() {});

  //           if (statusNow == '') {
  //             setState(() {
  //               _etaText = AppLocalizations.of(context)!.driverIsWaiting;
  //             });
  //             return;
  //           } else if (statusNow == 'accepted') {
  //             targetLatLng = LatLng(
  //               double.parse(origin['latitude'].toString()),
  //               double.parse(origin['longitude'].toString()),
  //             );
  //           } else if (statusNow == 'ontrip') {
  //             targetLatLng = LatLng(
  //               double.parse(destination['latitude'].toString()),
  //               double.parse(destination['longitude'].toString()),
  //             );
  //           } else if (statusNow == 'arrived') {
  //             setState(() {
  //               _etaText = AppLocalizations.of(context)!.driverIsWaiting;
  //             });
  //             return;
  //           } else if (statusNow == 'ended') {
  //             setState(() {
  //               _etaText = '';
  //             });
  //             return;
  //           }

  //           if (targetLatLng == null) return;

  //           await _updateETAAndProgress(
  //             targetLatLng: targetLatLng,
  //             status: statusNow,
  //           );

  //           if (mounted) setState(() {});
  //         });
  //       }

  //       return Container(
  //         padding: EdgeInsets.all(0),
  //         clipBehavior: Clip.hardEdge,
  //         decoration: BoxDecoration(
  //           color: isDark ? AppColors.darkLayer : AppColors.lightAccent,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: const [
  //             BoxShadow(
  //               color: Colors.black12,
  //               blurRadius: 6,
  //               offset: Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.max,
  //           children: [
  //             ClipRRect(
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(12),
  //                 topRight: Radius.circular(12),
  //               ),
  //               child: SizedBox(
  //                 height: 220, // Mini map height
  //                 child: GoogleMap(
  //                   onMapCreated: (controller) {
  //                     _miniMapController = controller;
  //                     _mapReady = true;
  //                   },
  //                   style: isDark ? _mapStyle : null,
  //                   markers: _miniMarkers,
  //                   polylines: _miniPolylines,
  //                   initialCameraPosition: CameraPosition(
  //                     target:
  //                         _driverLatLng ??
  //                         const LatLng(
  //                           35.133428350758344,
  //                           33.923606022529256,
  //                         ), // fallback (Lagos)
  //                     zoom: 16,
  //                   ),
  //                   zoomControlsEnabled: true,
  //                   myLocationButtonEnabled: false,
  //                   compassEnabled: false,
  //                   tiltGesturesEnabled: false,
  //                   rotateGesturesEnabled: true,
  //                   scrollGesturesEnabled: true,
  //                   zoomGesturesEnabled: true,
  //                   liteModeEnabled:
  //                       true, // ⚡ If supported, makes it super lightweight
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 3),
  //             Text(
  //               status == 'ontrip'
  //                   ? AppLocalizations.of(context)!.onTrip
  //                   : status == 'accepted'
  //                   ? AppLocalizations.of(context)!.driverIsComing
  //                   : AppLocalizations.of(context)!.driverHasArrived,
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 3),
  //             Text(_etaText),
  //             SizedBox(height: 5),
  //             Divider(thickness: 0.3),
  //             SizedBox(height: 5),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   driverPhotoUrl != ''
  //                       ? CircleAvatar(
  //                           radius: 30,
  //                           backgroundColor: AppColors.primary,
  //                           backgroundImage: NetworkImage(driverPhotoUrl),
  //                         )
  //                       : CircleAvatar(
  //                           radius: 30,
  //                           backgroundColor: AppColors.primary,
  //                           child: Text(
  //                             driverName[0],
  //                             style: TextStyle(
  //                               fontSize: 28,
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                   SizedBox(width: 8),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         driverName,
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                       StarRating(rating: (driverRating * 1.0), size: 16),
  //                       const SizedBox(height: 10),
  //                       Row(
  //                         children: [
  //                           Text(model),
  //                           const SizedBox(width: 4),
  //                           const Icon(Icons.circle, size: 6),
  //                           const SizedBox(width: 4),
  //                           Text(colour),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 10),
  //                       Row(
  //                         children: [
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(
  //                               vertical: 2,
  //                               horizontal: 4,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: AppColors.border),
  //                             ),
  //                             child: Text(
  //                               numberPlate,
  //                               style: Theme.of(context).textTheme.bodySmall,
  //                             ),
  //                           ),
  //                           const SizedBox(width: 5),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 5),
  //             Divider(thickness: 0.3),
  //             SizedBox(height: 5),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: driverPhone.isEmpty
  //                           ? null
  //                           : () => _makePhoneCall(context, driverPhone),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primary,
  //                         foregroundColor: Colors.white,
  //                         disabledBackgroundColor: AppColors.primary.withValues(
  //                           alpha: 0.5,
  //                         ),
  //                         disabledForegroundColor: Colors.white54,
  //                         padding: const EdgeInsets.all(16),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const Icon(Icons.call),
  //                           const SizedBox(width: 10),
  //                           Text(AppLocalizations.of(context)!.callDriver),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                   // Cancellation is only available while the driver
  //                   // is still on the way to the pickup location.
  //                   if (status == 'accepted') ...[
  //                     const SizedBox(width: 12),
  //                     IconButton(
  //                       iconSize: 32,
  //                       onPressed: () async {
  //                         final confirmed = await showDialog<bool>(
  //                           context: context,
  //                           builder: (context) => AlertDialog(
  //                             title: Text(
  //                               AppLocalizations.of(context)!.cancelRide,
  //                             ),
  //                             content: Text(
  //                               AppLocalizations.of(
  //                                 context,
  //                               )!.areYouSureCancelRide,
  //                             ),
  //                             actions: [
  //                               TextButton(
  //                                 onPressed: () =>
  //                                     Navigator.pop(context, false),
  //                                 child: Text(AppLocalizations.of(context)!.no),
  //                               ),
  //                               ElevatedButton(
  //                                 style: ElevatedButton.styleFrom(
  //                                   backgroundColor: AppColors.tertiary,
  //                                   foregroundColor: Colors.white,
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(12),
  //                                   ),
  //                                 ),
  //                                 onPressed: () => Navigator.pop(context, true),
  //                                 child: Text(
  //                                   AppLocalizations.of(context)!.yesCancel,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );

  //                         if (confirmed == true) {
  //                           if (!context.mounted) return;
  //                           await appInfo.cancelRide(context);
  //                         }
  //                       },
  //                       style: IconButton.styleFrom(
  //                         foregroundColor: Colors.white,
  //                         backgroundColor: AppColors.tertiary,
  //                       ),
  //                       icon: const Icon(Icons.cancel),
  //                       tooltip: AppLocalizations.of(context)!.cancelRide,
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
