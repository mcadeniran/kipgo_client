import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

class _ActiveRideWidgetState extends State<ActiveRideWidget>
    with TickerProviderStateMixin {
  // --- DRIVER MARKER ANIMATION --- //
  BitmapDescriptor? _driverIcon;
  LatLng? _lastDriverPosition;
  double _lastRotation = 0.0;
  AnimationController? _driverAnimController;

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

  // Track which rideId we are currently subscribed to for driverLocation
  String? _subscribedRideId;

  // bool _endDialogShown = false;

  @override
  void initState() {
    super.initState();

    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (isDark) {
      _loadMapStyle();
    }

    _loadDriverMarker();
  }

  Future<void> _loadDriverMarker() async {
    // _driverIcon = await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(size: Size(0.1, 0.1)),
    //   "assets/images/car.png", // <-- your icon
    // );

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

  void _animateDriverMovement(LatLng newPos) {
    if (_driverIcon == null) return;

    if (_lastDriverPosition == null) {
      _lastDriverPosition = newPos;
      _updateDriverMarker(newPos, _lastRotation);
      return;
    }

    final latTween = Tween<double>(
      begin: _lastDriverPosition!.latitude,
      end: newPos.latitude,
    );

    final lngTween = Tween<double>(
      begin: _lastDriverPosition!.longitude,
      end: newPos.longitude,
    );

    final rotationTween = Tween<double>(
      begin: _lastRotation,
      end: _calculateBearing(_lastDriverPosition!, newPos),
    );

    _driverAnimController?.dispose();
    _driverAnimController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    final animation = CurvedAnimation(
      parent: _driverAnimController!,
      curve: Curves.easeInOut,
    );

    _driverAnimController!.addListener(() {
      final animatedLat = latTween.evaluate(animation);
      final animatedLng = lngTween.evaluate(animation);
      final animatedRotation = rotationTween.evaluate(animation);

      _updateDriverMarker(LatLng(animatedLat, animatedLng), animatedRotation);
    });

    _driverAnimController!.forward();

    _lastDriverPosition = newPos;
    _lastRotation = rotationTween.end!;
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

  @override
  void dispose() {
    _driverLocationSub?.cancel();
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

            // --- UPDATE MINI MAP MARKERS --- //
            if (_driverLatLng != null) {
              // _miniMarkers.removeWhere((m) => m.markerId.value == 'driver');
              // _miniMarkers.add(
              //   Marker(
              //     markerId: const MarkerId('driver'),
              //     position: _driverLatLng!,
              //     icon: BitmapDescriptor.defaultMarkerWithHue(
              //       BitmapDescriptor.hueAzure,
              //     ),
              //   ),
              // );
              if (_driverLatLng != null) {
                _animateDriverMovement(_driverLatLng!);
              }
            }

            // Pickup and destination markers
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

            // --- DRAW ROUTE BASED ON STATUS --- //
            if (statusNow == 'accepted') {
              _drawMiniMapPolyline(_driverLatLng!, originLatLng);
            } else if (statusNow == 'ontrip') {
              _drawMiniMapPolyline(originLatLng, destinationLatLng);
            }

            // Update camera position once map is ready
            if (_mapReady &&
                _miniMapController != null &&
                _driverLatLng != null) {
              _miniMapController!.animateCamera(
                CameraUpdate.newLatLng(_driverLatLng!),
              );
            }

            setState(() {});

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
          padding: EdgeInsets.all(0),
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
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 220, // Mini map height
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
                          ), // fallback (Lagos)
                      zoom: 16,
                    ),
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    liteModeEnabled:
                        true, // ⚡ If supported, makes it super lightweight
                  ),
                ),
              ),
              SizedBox(height: 3),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
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
              ),
              SizedBox(height: 5),
              Divider(thickness: 0.3),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
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
                            title: Text(
                              AppLocalizations.of(context)!.cancelRide,
                            ),
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.areYouSureCancelRide,
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
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
