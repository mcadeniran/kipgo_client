import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
import 'package:kipgo/screens/widgets/ride_location_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;
  const NewTripScreen({super.key, this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen>
    with WidgetsBindingObserver {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newTripGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.133428350758344, 33.923606022529256),
    zoom: 14.4746,
  );

  // UI state
  late String buttonTitle;
  String rideRequestStatus = 'accepted';
  String durationFromOriginToDestination = '';

  // Map data
  final Set<Marker> markersSet = <Marker>{};
  final Set<Circle> circlesSet = <Circle>{};
  final Set<Polyline> polylinesSet = <Polyline>{};
  final List<LatLng> polylinePositionCoordinates = [];

  BitmapDescriptor? iconAnimateMarker;
  Position? onlineDriverCurrentPosition;

  // Subscriptions / timers
  StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
  DatabaseReference? rideStatusRef;
  StreamSubscription<DatabaseEvent>? rideStatusSubscription;

  final double _rerouteThresholdMeters = 60.0;
  LatLng? _lastReroutePosition;

  // Optimization / smoothing state
  LatLng? _lastDriverLatLng;
  final double _lastRotation = 0.0;

  final bool _cameraFollow = true;

  String? _mapStyle;

  bool _hasActiveRoute = false;
  LatLng? _routeEnd;

  Timer? _lerpTimer;

  static const int _lerpSteps = 12;
  static const Duration _lerpTick = Duration(milliseconds: 16);

  late BitmapDescriptor arrowIcon;

  List<LatLng> _activeRoutePoints = [];

  Future<void> _loadArrowIcon() async {
    try {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(20, 20),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/arrow.png',
      ).then((value) => arrowIcon = value);
    } catch (e) {
      debugPrint('Failed to load arrow icon: $e');
    }
  }

  LatLng _snapToPolyline(LatLng pos) {
    double minDist = double.infinity;
    LatLng closest = pos;

    for (final p in _activeRoutePoints) {
      final d = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        p.latitude,
        p.longitude,
      );

      if (d < minDist) {
        minDist = d;
        closest = p;
      }
    }

    return closest;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    buttonTitle = 'Arrived';

    _loadMapStyle();
    _createDriverIconMarker();
    _loadArrowIcon();
    WakelockPlus.enable();

    // safe initial location fetch (your helper getLocationSetting expected)
    Geolocator.getCurrentPosition(locationSettings: getLocationSetting())
        .then((position) {
          driverCurrentPosition = position;
          onlineDriverCurrentPosition = position;
          setState(() {});
        })
        .catchError((_) {});

    // save assigned driver details to request
    saveAssignedDriverDetailsToUserRideRequest();

    // listen for ride cancellation changes
    _setupRideStatusListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscriptionDriverLivePosition?.cancel();
    rideStatusSubscription?.cancel();
    newTripGoogleMapController?.dispose();
    _lerpTimer?.cancel();
    // _firebaseUploadDebounce?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _addArrowMarkers(List<LatLng> route) {
    markersSet.removeWhere((m) => m.markerId.value.startsWith('arrow_'));

    for (int i = 0; i < route.length - 1; i += 3) {
      final from = route[i];
      final to = route[i + 1];
      final bearing = _computeBearing(from, to);

      markersSet.add(
        Marker(
          markerId: MarkerId('arrow_$i'),
          position: from,
          rotation: bearing,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: arrowIcon,
          zIndexInt: 5,
        ),
      );
    }
  }

  LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  void _animateDriverSmoothly(LatLng newTarget) {
    if (_lastDriverLatLng != null &&
        Geolocator.distanceBetween(
              _lastDriverLatLng!.latitude,
              _lastDriverLatLng!.longitude,
              newTarget.latitude,
              newTarget.longitude,
            ) <
            1.5) {
      return; // ignore tiny jitter
    }

    _lerpTimer?.cancel();

    final start = _lastDriverLatLng ?? newTarget;
    _lastDriverLatLng = newTarget;

    int step = 0;

    _lerpTimer = Timer.periodic(_lerpTick, (timer) {
      step++;
      final t = step / _lerpSteps;

      if (t >= 1) {
        timer.cancel();
      }

      final pos = _lerpLatLng(start, newTarget, t.clamp(0, 1));
      final bearing = _computeBearing(start, newTarget);

      markersSet.removeWhere((m) => m.markerId.value == 'driver');
      markersSet.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          rotation: bearing,
          flat: false,
          anchor: const Offset(0.5, 0.7),
          zIndexInt: 10,
          icon: iconAnimateMarker!,
        ),
      );

      setState(() {});
    });
  }

  // -------------------------
  // MAP & ICON LOADING
  // -------------------------
  Future<void> _createDriverIconMarker() async {
    if (iconAnimateMarker != null) return;
    try {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(35, 35),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/car.png',
      ).then((value) => iconAnimateMarker = value);
    } catch (e) {
      // fallback to default marker if asset fails
      iconAnimateMarker = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      );
      debugPrint('Failed to load car icon: $e');
    }
    setState(() {});
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString('map_themes/dark_style.json');
      _mapStyle = style;
    } catch (e) {
      // ignore if missing
    }
  }

  // -------------------------
  // RIDE STATUS LISTENER
  // -------------------------
  void _setupRideStatusListener() {
    final rideId = widget.userRideRequestDetails?.rideRequestId;
    if (rideId == null) return;

    rideStatusRef = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(rideId)
        .child('status');
    rideStatusSubscription = rideStatusRef!.onValue.listen((event) async {
      final status = event.snapshot.value?.toString();
      if (status == 'cancelled') {
        Provider.of<DriverStatusProvider>(
          context,
          listen: false,
        ).toggleStatus(true, context);
        _cleanupAndExitDriverHome();
      }
    });
  }

  void _cleanupAndExitDriverHome() async {
    streamSubscriptionDriverLivePosition?.cancel();
    rideStatusSubscription?.cancel();

    streamSubscriptionDriverLivePosition?.cancel();
    streamSubscriptionDriverLivePosition = null;

    // remove driver's newRide link
    final driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    await FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .remove();

    if (!mounted) return;
    cleanupResources();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverHome()),
      (r) => false,
    );
  }

  void cleanupResources() {
    streamSubscriptionDriverLivePosition?.cancel();
    newTripGoogleMapController?.dispose();
  }

  double _distanceInMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  void _maybeReroutePolylineOptimized(LatLng driverLatLng) {
    if (!_hasActiveRoute || _routeEnd == null) return;

    if (_lastReroutePosition == null) {
      _lastReroutePosition = driverLatLng;
      return;
    }

    final moved = _distanceInMeters(_lastReroutePosition!, driverLatLng);

    // 🔒 Only reroute if driver moved significantly
    if (moved < _rerouteThresholdMeters) return;

    _lastReroutePosition = driverLatLng;

    // 🔥 Redraw route from current position
    _drawPolylineFromOriginToDestination(
      driverLatLng,
      _routeEnd!,
      force: true,
      showLoading: false,
    );
  }

  // -------------------------
  // POLYLINE & ETA (throttled)
  // -------------------------
  Future<void> _drawPolylineFromOriginToDestination(
    LatLng origin,
    LatLng destination, {
    bool force = false,
    bool showLoading = true,
  }) async {
    _routeEnd = destination;
    _hasActiveRoute = true;

    if (!mounted) return;
    if (showLoading) {
      showDialog(
        context: context,
        builder: (ctx) =>
            ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
      );
    }

    final directionDetails =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          origin,
          destination,
        );

    if (showLoading && mounted) Navigator.pop(context);

    if (directionDetails == null) return;

    final pPoints = PolylinePoints();
    final decoded = pPoints.decodePolyline(directionDetails.ePoints ?? '');

    polylinePositionCoordinates.clear();
    for (var p in decoded) {
      polylinePositionCoordinates.add(LatLng(p.latitude, p.longitude));
    }

    _activeRoutePoints = polylinePositionCoordinates;

    polylinesSet
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePositionCoordinates,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          color: AppColors.tertiary,
        ),
      );
    // if (arrowIcon == null) return;
    _addArrowMarkers(_activeRoutePoints);

    // markers for origin/destination
    markersSet.removeWhere(
      (m) => m.markerId.value == 'origin' || m.markerId.value == 'destination',
    );
    markersSet.addAll([
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        visible: false,
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    ]);

    circlesSet.removeWhere(
      (c) => c.circleId.value == 'origin' || c.circleId.value == 'destination',
    );
    circlesSet.addAll([
      Circle(
        circleId: const CircleId('destination'),
        center: destination,
        radius: 12,
        fillColor: Colors.red,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
    ]);

    setState(() {});
  }

  LatLngBounds _computeBounds(LatLng a, LatLng b) {
    final southWest = LatLng(
      min(a.latitude, b.latitude),
      min(a.longitude, b.longitude),
    );
    final northEast = LatLng(
      max(a.latitude, b.latitude),
      max(a.longitude, b.longitude),
    );
    return LatLngBounds(southwest: southWest, northeast: northEast);
  }

  // -------------------------
  // DRIVER LOCATION STREAM & HANDLING
  // -------------------------
  void getDriverLocationUpdatesAtRealTime() {
    // avoid multiple subscriptions
    streamSubscriptionDriverLivePosition?.cancel();

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream(
          locationSettings: getLocationSetting(),
        ).listen((pos) {
          if (!mounted) return;

          final raw = LatLng(pos.latitude, pos.longitude);
          final snapped = _activeRoutePoints.isNotEmpty
              ? _snapToPolyline(raw)
              : raw;

          _animateDriverSmoothly(snapped);

          if (_cameraFollow) {
            _smartAutoZoomAndFollow(snapped);
          }

          _maybeReroutePolylineOptimized(snapped);
          _uploadDriverLocationThrottled(pos);
        });
  }

  double _computeBearing(LatLng start, LatLng end) {
    // Haversine bearing
    final lat1 = _degToRad(start.latitude);
    final lon1 = _degToRad(start.longitude);
    final lat2 = _degToRad(end.latitude);
    final lon2 = _degToRad(end.longitude);
    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x);
    return (_radToDeg(bearing) + 360) % 360;
  }

  double _degToRad(double deg) => deg * pi / 180;
  double _radToDeg(double rad) => rad * 180 / pi;

  void _uploadDriverLocationThrottled(Position pos) {
    final rideId = widget.userRideRequestDetails?.rideRequestId;
    if (rideId == null) return;

    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(rideId)
        .child('driverLocation')
        .update({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'updatedAt': ServerValue.timestamp,
        });
  }

  void _smartAutoZoomAndFollow(LatLng driver) {
    if (newTripGoogleMapController == null) return;

    newTripGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: driver,
          zoom: 18, // 🔒 LOCK zoom
          bearing: _lastRotation,
          // tilt: 0,
          tilt: 65,
        ),
      ),
    );
  }

  Future<void> _zoomToRouteBounds(LatLng a, LatLng b) async {
    if (newTripGoogleMapController == null) return;

    final bounds = _computeBounds(a, b);
    await newTripGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  // -------------------------
  // SAVE ASSIGNED DRIVER
  // -------------------------
  void saveAssignedDriverDetailsToUserRideRequest() {
    final onlineDriverData = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;
    final rideId = widget.userRideRequestDetails?.rideRequestId;
    if (rideId == null) return;

    final databaseReference = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(rideId);

    final driverLocationDataMap = {
      'latitude': driverCurrentPosition?.latitude.toString() ?? '0',
      'longitude': driverCurrentPosition?.longitude.toString() ?? '0',
    };

    // Write driver info and status
    databaseReference.child('driverLocation').set(driverLocationDataMap);
    databaseReference.child('status').set('accepted');
    databaseReference.child('driverId').set(onlineDriverData.id);
    databaseReference.child('driverName').set(onlineDriverData.username);
    databaseReference.child('driverPhone').set(onlineDriverData.personal.phone);
    databaseReference.child('ratings').set(onlineDriverData.personal.rating);
    databaseReference.child('model').set(onlineDriverData.vehicle.model);
    databaseReference.child('colour').set(onlineDriverData.vehicle.colour);
    databaseReference
        .child('numberPlate')
        .set(onlineDriverData.vehicle.numberPlate);
    databaseReference
        .child('driverPhotoUrl')
        .set(onlineDriverData.personal.photoUrl);

    FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(onlineDriverData.id)
        .child('newRide')
        .set(rideId);
  }

  // -------------------------
  // END TRIP
  // -------------------------
  Future<void> endTripNow() async {
    showDialog(
      context: context,
      builder: (c) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
    );
    cleanupResources();

    streamSubscriptionDriverLivePosition?.cancel();
    streamSubscriptionDriverLivePosition = null;

    if (!mounted) return;
    Provider.of<DriverStatusProvider>(
      context,
      listen: false,
    ).toggleStatus(true, context);

    final rideId = widget.userRideRequestDetails?.rideRequestId;
    if (rideId != null) {
      await FirebaseDatabase.instance
          .ref()
          .child('All Ride Requests')
          .child(rideId)
          .child('status')
          .set('ended');
    }

    final driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(driverId)
        .update({'newRideStatus': 'idle'});
    await FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .remove();

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DriverHome()),
      (r) => false,
    );
  }

  // -------------------------
  // MAP UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final ride = widget.userRideRequestDetails;
    if (ride == null) return const SizedBox.shrink();

    final driverPhone = ride.userPhone ?? '';

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: 100),
              mapType: MapType.normal,
              myLocationEnabled: false,
              initialCameraPosition: _kGooglePlex,
              markers: markersSet,
              circles: circlesSet,
              polylines: polylinesSet,
              onMapCreated: (controller) {
                if (!_controllerGoogleMap.isCompleted) {
                  _controllerGoogleMap.complete(controller);
                }
                newTripGoogleMapController = controller;
                if (isDark && _mapStyle != null) {
                  newTripGoogleMapController!.setMapStyle(_mapStyle);
                }

                // once map ready:
                mapOnReadyActions();
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
            ),
          ),

          // Bottom panel (kept your original UI)
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              MediaQuery.of(context).padding.bottom + 6,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                RideLocationCard(
                  currentLocation:
                      widget.userRideRequestDetails!.originAddress!,
                  destinationAddress:
                      widget.userRideRequestDetails!.destinationAddress!,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                  child: Column(
                    children: [
                      Text(
                        rideRequestStatus == 'arrived'
                            ? AppLocalizations.of(context)!.waitingForRider
                            : rideRequestStatus == 'accepted'
                            ? "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toPickup}"
                            : "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toDropoff}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 5),
                      Divider(color: AppColors.border, thickness: 0.5),
                      const SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: onPrimaryButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.directions_car, size: 25),
                        label: Text(buttonTitle),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _makePhoneCall(context, driverPhone),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.call, size: 28),
                            const SizedBox(width: 12),
                            Text(widget.userRideRequestDetails!.username!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Called when map created
  void mapOnReadyActions() {
    // add initial driver marker if we have position
    if (driverCurrentPosition != null) {
      final driverLatLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );
      markersSet.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLatLng,
          icon: iconAnimateMarker ?? BitmapDescriptor.defaultMarker,
        ),
      );
      setState(() {});
    }

    // draw initial polyline to pickup
    final pickup = widget.userRideRequestDetails?.originLatLng;
    if (driverCurrentPosition != null && pickup != null) {
      final driverLatLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      _drawPolylineFromOriginToDestination(driverLatLng, pickup);

      _zoomToRouteBounds(driverLatLng, pickup);
    }

    // start listening to device location
    getDriverLocationUpdatesAtRealTime();
  }

  void onPrimaryButtonPressed() async {
    if (rideRequestStatus == 'accepted') {
      rideRequestStatus = 'arrived';
      setState(() => buttonTitle = AppLocalizations.of(context)!.startTrip);

      final rideId = widget.userRideRequestDetails!.rideRequestId;
      if (rideId != null) {
        FirebaseDatabase.instance
            .ref()
            .child('All Ride Requests')
            .child(rideId)
            .child('status')
            .set(rideRequestStatus);
      }

      // Draw route from pickup to dropoff
      final origin = widget.userRideRequestDetails!.originLatLng!;
      final dest = widget.userRideRequestDetails!.destinationLatLng!;
      await _drawPolylineFromOriginToDestination(origin, dest);
      await _zoomToRouteBounds(origin, dest);
    } else if (rideRequestStatus == 'arrived') {
      rideRequestStatus = 'ontrip';
      AppMethods.sendDriverArrivalNotification(
        widget.userRideRequestDetails!.userId!,
        widget.userRideRequestDetails!.originAddress!,
        context,
      );
      setState(() => buttonTitle = AppLocalizations.of(context)!.endTrip);

      final rideId = widget.userRideRequestDetails!.rideRequestId;
      if (rideId != null) {
        FirebaseDatabase.instance
            .ref()
            .child('All Ride Requests')
            .child(rideId)
            .child('status')
            .set(rideRequestStatus);
      }
    } else if (rideRequestStatus == 'ontrip') {
      await endTripNow();
    }
  }
}
