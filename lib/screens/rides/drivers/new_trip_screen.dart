import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
// import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/widgets/ride_location_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/l10n/app_localizations.dart';
// import 'package:kipgo/models/profile.dart';
import 'package:kipgo/models/user_ride_request_information.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
// import 'package:kipgo/screens/rides/drivers/available_rides_screen.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Timer? _firebaseUploadDebounce;

  // Optimization / smoothing state
  LatLng? _lastDriverLatLng;
  double _lastRotation = 0.0;
  LatLng? _lastReroutePosition;
  DateTime _lastDirectionCall = DateTime.now().subtract(
    const Duration(seconds: 10),
  );
  final double _rerouteThresholdMeters = 60.0;
  final bool _cameraFollow = true;

  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    buttonTitle = 'Arrived';

    _loadMapStyle();
    _createDriverIconMarker();

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
    _firebaseUploadDebounce?.cancel();
    super.dispose();
  }

  // -------------------------
  // MAP & ICON LOADING
  // -------------------------
  Future<void> _createDriverIconMarker() async {
    if (iconAnimateMarker != null) return;
    try {
      // final config = const ImageConfiguration(size: Size(24, 24));
      // iconAnimateMarker = await BitmapDescriptor.fromAssetImage(
      //   config,
      //   'assets/images/car.png',
      // );
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(30, 30),
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
        _cleanupAndExitDriverHome();
      }
    });
  }

  void _cleanupAndExitDriverHome() async {
    streamSubscriptionDriverLivePosition?.cancel();
    rideStatusSubscription?.cancel();

    // remove driver's newRide link
    final driverId = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.id;
    await FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .child('newRide')
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

  // -------------------------
  // POLYLINE & ETA (throttled)
  // -------------------------
  Future<void> _drawPolylineFromOriginToDestination(
    LatLng origin,
    LatLng destination, {
    bool showLoading = true,
  }) async {
    // throttle calls
    if (DateTime.now().difference(_lastDirectionCall).inSeconds < 6) return;
    _lastDirectionCall = DateTime.now();

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

    // markers for origin/destination
    markersSet.removeWhere(
      (m) => m.markerId.value == 'origin' || m.markerId.value == 'destination',
    );
    markersSet.addAll([
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
        circleId: const CircleId('origin'),
        center: origin,
        radius: 12,
        fillColor: Colors.green,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
      Circle(
        circleId: const CircleId('destination'),
        center: destination,
        radius: 12,
        fillColor: Colors.red,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
    ]);

    // adjust camera to bounds
    try {
      final bounds = _computeBounds(origin, destination);
      await newTripGoogleMapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (_) {}

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

  Future<void> _updateEtaAndSetState(LatLng from, LatLng to) async {
    final details = await AppMethods.obtainOriginToDestinationDirectionDetails(
      from,
      to,
    );
    if (details != null && mounted) {
      setState(() {
        durationFromOriginToDestination = details.durationText ?? '';
      });
    }
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
          final newLatLng = LatLng(pos.latitude, pos.longitude);
          onlineDriverCurrentPosition = pos;

          // set or animate marker
          _animateOrUpdateDriverMarker(newLatLng);

          // follow camera
          if (_cameraFollow) _smartAutoZoomAndFollow(newLatLng);

          // throttled polyline reroute
          _maybeReroutePolylineOptimized(newLatLng);

          // throttled ETA update
          _updateEtaThrottled(newLatLng);

          // debounced upload to Firebase to avoid flooding
          _uploadDriverLocationDebounced(pos);
        });
  }

  void _animateOrUpdateDriverMarker(LatLng newLatLng) {
    final LatLng old = _lastDriverLatLng ?? newLatLng;

    // compute bearing
    final bearing = _computeBearing(old, newLatLng);
    _lastRotation = bearing;
    _lastDriverLatLng = newLatLng;

    final marker = Marker(
      markerId: const MarkerId('driver'),
      position: newLatLng,
      rotation: bearing,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      icon: iconAnimateMarker ?? BitmapDescriptor.defaultMarker,
    );

    // replace driver marker
    markersSet.removeWhere((m) => m.markerId.value == 'driver');
    markersSet.add(marker);
    setState(() {});
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

  void _uploadDriverLocationDebounced(Position pos) {
    _firebaseUploadDebounce?.cancel();
    _firebaseUploadDebounce = Timer(const Duration(milliseconds: 800), () {
      final rideId = widget.userRideRequestDetails?.rideRequestId;
      if (rideId == null) return;
      FirebaseDatabase.instance
          .ref()
          .child('All Ride Requests')
          .child(rideId)
          .child('driverLocation')
          .update({'latitude': pos.latitude, 'longitude': pos.longitude});
    });
  }

  void _maybeReroutePolylineOptimized(LatLng newPos) async {
    if (_lastReroutePosition != null) {
      final moved = Geolocator.distanceBetween(
        _lastReroutePosition!.latitude,
        _lastReroutePosition!.longitude,
        newPos.latitude,
        newPos.longitude,
      );
      if (moved < _rerouteThresholdMeters) return;
    }

    _lastReroutePosition = newPos;

    final target = rideRequestStatus == 'accepted'
        ? widget.userRideRequestDetails!.originLatLng!
        : widget.userRideRequestDetails!.destinationLatLng!;

    await _drawPolylineFromOriginToDestination(
      newPos,
      target,
      showLoading: false,
    );
  }

  void _updateEtaThrottled(LatLng driverPos) {
    final dest = rideRequestStatus == 'accepted'
        ? widget.userRideRequestDetails!.originLatLng!
        : widget.userRideRequestDetails!.destinationLatLng!;
    // throttle already handled in _drawPolylineFromOriginToDestination via _lastDirectionCall
    _updateEtaAndSetState(driverPos, dest);
  }

  void _smartAutoZoomAndFollow(LatLng driver) {
    if (newTripGoogleMapController == null) return;
    final target = rideRequestStatus == 'accepted'
        ? widget.userRideRequestDetails!.originLatLng!
        : widget.userRideRequestDetails!.destinationLatLng!;
    final dist = Geolocator.distanceBetween(
      driver.latitude,
      driver.longitude,
      target.latitude,
      target.longitude,
    );

    final zoom = dist > 3000
        ? 12.0
        : dist > 1500
        ? 14.0
        : dist > 600
        ? 15.5
        : 17.0;

    newTripGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: driver,
          zoom: zoom,
          tilt: 58,
          bearing: _lastRotation,
        ),
      ),
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
        .child('newRide')
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
              padding: EdgeInsets.only(bottom: 350),
              mapType: MapType.normal,
              myLocationEnabled: true,
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
      _drawPolylineFromOriginToDestination(
        LatLng(
          driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude,
        ),
        pickup,
      );
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

// Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   await launchUrl(launchUri);
// }

// class NewTripScreen extends StatefulWidget {
//   final UserRideRequestInformation? userRideRequestDetails;
//   const NewTripScreen({super.key, this.userRideRequestDetails});

//   @override
//   State<NewTripScreen> createState() => _NewTripScreenState();
// }

// class _NewTripScreenState extends State<NewTripScreen> {
//   final Completer<GoogleMapController> _controllerGoogleMap =
//       Completer<GoogleMapController>();
//   GoogleMapController? newTripGoogleMapController;

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(35.133428350758344, 33.923606022529256),
//     zoom: 14.4746,
//   );

//   late String buttonTitle;

//   Set<Marker> markersSet = <Marker>{};
//   Set<Circle> circlesSet = <Circle>{};
//   Set<Polyline> polylinesSet = <Polyline>{};
//   List<LatLng> polylinePositionCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();

//   double mapPadding = 0;
//   BitmapDescriptor? iconAnimateMarker;
//   Geolocator geoLocator = Geolocator();
//   Position? onlineDriverCurrentPosition;

//   String rideRequestStatus = 'accepted';

//   String durationFromOriginToDestination = '';

//   String? _mapStyle;

//   bool isRequestDirectionDetails = false;

//   DatabaseReference? rideStatusRef;
//   StreamSubscription<DatabaseEvent>? rideStatusSubscription;

//   LatLng? previousDriverLatLng;
//   double previousRotation = 0;

//   LatLng? _lastDriverLatLng;
//   double _lastRotation = 0;

//   LatLng? _lastReroutePosition;
//   final double rerouteThresholdMeters = 50;

//   final ValueNotifier<Set<Marker>> markerNotifier = ValueNotifier({});
//   final ValueNotifier<Set<Circle>> circleNotifier = ValueNotifier({});
//   final ValueNotifier<Set<Polyline>> polylineNotifier = ValueNotifier({});

//   DateTime lastDirectionCall = DateTime.now().subtract(Duration(seconds: 10));
//   bool cameraFollow = true;

//   LatLng? lastDirectionOrigin;
//   LatLng? lastDirectionDestination;
//   double lastRerouteDistance = 0;

//   Timer? firebaseUploadDebounce;

//   double getBearing(LatLng start, LatLng end) {
//     double lat1 = start.latitude * (pi / 180);
//     double lon1 = start.longitude * (pi / 180);
//     double lat2 = end.latitude * (pi / 180);
//     double lon2 = end.longitude * (pi / 180);

//     double dLon = lon2 - lon1;

//     double y = sin(dLon) * cos(lat2);
//     double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

//     double bearing = atan2(y, x);

//     return (bearing * 180 / pi + 360) % 360;
//   }

//   void animateDriverMarker(LatLng newPosition) {
//     final LatLng old = _lastDriverLatLng ?? newPosition;

//     double rotation = getBearing(old, newPosition);
//     _lastRotation = rotation;
//     _lastDriverLatLng = newPosition;

//     Marker animatedMarker = Marker(
//       markerId: const MarkerId("AnimatedMarker"),
//       position: newPosition,
//       icon: iconAnimateMarker!,
//       rotation: rotation,
//       flat: true,
//       anchor: const Offset(0.5, 0.5),
//     );

//     setState(() {
//       markersSet.removeWhere((m) => m.markerId.value == "AnimatedMarker");
//       markersSet.add(animatedMarker);
//     });
//   }

//   void maybeReroutePolyline(LatLng newDriverPosition) async {
//     // Prevent excessive API calls
//     if (_lastReroutePosition != null) {
//       double distance = Geolocator.distanceBetween(
//         _lastReroutePosition!.latitude,
//         _lastReroutePosition!.longitude,
//         newDriverPosition.latitude,
//         newDriverPosition.longitude,
//       );

//       if (distance < rerouteThresholdMeters) return;
//     }

//     _lastReroutePosition = newDriverPosition;

//     LatLng destination = rideRequestStatus == "accepted"
//         ? widget.userRideRequestDetails!.originLatLng!
//         : widget.userRideRequestDetails!.destinationLatLng!;

//     await drawPolylineFromOriginToDestination(
//       newDriverPosition,
//       destination,
//       Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
//     );
//   }

//   // Step 1:When driver accepts user's request
//   // Origin addres is the driver's current address and destination address is the passanger's pickup address
//   //
//   // Step 2: When driver reaches the user's location
//   // Origin location is user's current location and destination location is the dropoff location

//   Future<void> drawPolylineFromOriginToDestination(
//     LatLng originLatLng,
//     LatLng destinationLatLng,
//     bool isDark,
//   ) async {
//     showDialog(
//       context: context,
//       builder: ((BuildContext context) =>
//           ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait)),
//     );

//     var directionDetailsInfo =
//         await AppMethods.obtainOriginToDestinationDirectionDetails(
//           originLatLng,
//           destinationLatLng,
//         );

//     if (!mounted) return;

//     Navigator.pop(context);

//     PolylinePoints pPoints = PolylinePoints();
//     List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(
//       directionDetailsInfo!.ePoints!,
//     );

//     polylinePositionCoordinates.clear();

//     if (decodedPolylinePointsResultList.isNotEmpty) {
//       for (var pointLatLng in decodedPolylinePointsResultList) {
//         polylinePositionCoordinates.add(
//           LatLng(pointLatLng.latitude, pointLatLng.longitude),
//         );
//       }
//     }

//     polylinesSet.clear();

//     setState(() {
//       Polyline polyline = Polyline(
//         color: AppColors.tertiary,
//         polylineId: PolylineId('PolylineID'),
//         jointType: JointType.round,
//         points: polylinePositionCoordinates,
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//         geodesic: true,
//         width: 5,
//       );

//       polylinesSet.add(polyline);
//     });

//     LatLngBounds boundsLatLng;

//     if (originLatLng.longitude > destinationLatLng.longitude &&
//         originLatLng.latitude > destinationLatLng.latitude) {
//       boundsLatLng = LatLngBounds(
//         southwest: destinationLatLng,
//         northeast: originLatLng,
//       );
//     } else if (originLatLng.longitude > destinationLatLng.longitude) {
//       boundsLatLng = LatLngBounds(
//         southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
//         northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
//       );
//     } else if (originLatLng.latitude > destinationLatLng.latitude) {
//       boundsLatLng = LatLngBounds(
//         southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
//         northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
//       );
//     } else {
//       boundsLatLng = LatLngBounds(
//         southwest: originLatLng,
//         northeast: destinationLatLng,
//       );
//     }

//     newTripGoogleMapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(boundsLatLng, 65),
//     );

//     Marker originMarker = Marker(
//       markerId: MarkerId('originId'),
//       position: originLatLng,
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//     );

//     Marker destinationMarker = Marker(
//       markerId: MarkerId('destinationId'),
//       position: destinationLatLng,
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//     );

//     setState(() {
//       markersSet.add(originMarker);
//       markersSet.add(destinationMarker);
//     });

//     Circle originCircle = Circle(
//       circleId: CircleId('originId'),
//       fillColor: Colors.green,
//       radius: 12,
//       strokeWidth: 3,
//       strokeColor: Colors.white,
//       center: originLatLng,
//     );

//     Circle destinationCircle = Circle(
//       circleId: CircleId('destinationId'),
//       fillColor: Colors.red,
//       radius: 12,
//       strokeWidth: 3,
//       strokeColor: Colors.white,
//       center: destinationLatLng,
//     );

//     setState(() {
//       circlesSet.add(originCircle);
//       circlesSet.add(destinationCircle);
//     });
//   }

//   void createDriverIconMarker() {
//     if (iconAnimateMarker == null) {
//       ImageConfiguration imageConfiguration = ImageConfiguration(
//         size: Size(24, 24),
//       );

//       BitmapDescriptor.asset(
//         imageConfiguration,
//         'assets/images/car.png',
//       ).then((value) => iconAnimateMarker = value);
//     }
//   }

//   void saveAssignedDriverDetailsToUserRideRequest() {
//     Profile onlineDriverData = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!;
//     DatabaseReference databaseReference = FirebaseDatabase.instance
//         .ref()
//         .child('All Ride Requests')
//         .child(widget.userRideRequestDetails!.rideRequestId!);

//     Map driverLocationDataMap = {
//       'latitude': driverCurrentPosition!.latitude.toString(),
//       'longitude': driverCurrentPosition!.longitude.toString(),
//     };

//     if (databaseReference.child('driverId') != 'waiting') {
//       databaseReference.child('driverLocation').set(driverLocationDataMap);

//       databaseReference.child('status').set('accepted');
//       databaseReference.child('driverId').set(onlineDriverData.id);
//       databaseReference.child('driverName').set(onlineDriverData.username);
//       databaseReference
//           .child('driverPhone')
//           .set(onlineDriverData.personal.phone);
//       databaseReference.child('ratings').set(onlineDriverData.personal.rating);
//       databaseReference.child('model').set(onlineDriverData.vehicle.model);
//       databaseReference.child('colour').set(onlineDriverData.vehicle.colour);
//       databaseReference
//           .child('numberPlate')
//           .set(onlineDriverData.vehicle.numberPlate);
//       databaseReference
//           .child('driverPhotoUrl')
//           .set(onlineDriverData.personal.photoUrl);

//       FirebaseDatabase.instance
//           .ref()
//           .child('drivers')
//           .child(onlineDriverData.id)
//           .child('newRide')
//           .set(widget.userRideRequestDetails!.rideRequestId!);
//       // saveRideRequestIdToDriverHistory();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocalizations.of(context)!.thisRideHasBeenAccepted),
//         ),
//       );
//       Navigator.pop(context);
//     }
//   }

//   void updateDriverMarker(LatLng newLatLng) {
//     previousDriverLatLng ??= newLatLng;

//     // Calculate heading (bearing)
//     final double newRotation = Geolocator.bearingBetween(
//       previousDriverLatLng!.latitude,
//       previousDriverLatLng!.longitude,
//       newLatLng.latitude,
//       newLatLng.longitude,
//     );

//     // Smooth rotation
//     double smoothedRotation =
//         previousRotation + (newRotation - previousRotation) * 0.3;

//     previousRotation = smoothedRotation;

//     final Marker updatedMarker = Marker(
//       markerId: const MarkerId("driver"),
//       position: newLatLng,
//       rotation: smoothedRotation,
//       anchor: const Offset(0.5, 0.5),
//       flat: true,
//       icon: iconAnimateMarker!,
//     );

//     setState(() {
//       markersSet.removeWhere((m) => m.markerId.value == "driver");
//       markersSet.add(updatedMarker);
//     });

//     previousDriverLatLng = newLatLng;
//   }

//   // void getDriverLocationUpdatesAtRealTime() {
//   //   // LatLng oldLatLng = LatLng(0, 0);
//   //   streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
//   //       .listen((Position position) {
//   //         driverCurrentPosition = position;
//   //         onlineDriverCurrentPosition = position;

//   //         LatLng latLngLiveDriverPosition = LatLng(
//   //           onlineDriverCurrentPosition!.latitude,
//   //           onlineDriverCurrentPosition!.longitude,
//   //         );

//   //         Marker animatingMarker = Marker(
//   //           markerId: MarkerId('AnimatedMarker'),
//   //           position: latLngLiveDriverPosition,
//   //           icon: iconAnimateMarker!,
//   //           infoWindow: InfoWindow(title: 'Your current position'),
//   //         );

//   //         setState(() {
//   //           CameraPosition cameraPosition = CameraPosition(
//   //             target: latLngLiveDriverPosition,
//   //             zoom: 18,
//   //           );
//   //           newTripGoogleMapController!.animateCamera(
//   //             CameraUpdate.newCameraPosition(cameraPosition),
//   //           );

//   //           markersSet.removeWhere(
//   //             (element) => element.markerId.value == 'AnimatedMarker',
//   //           );
//   //           markersSet.add(animatingMarker);
//   //         });

//   //         // oldLatLng = latLngLiveDriverPosition;

//   //         updateDurationInRealTime();

//   //         // Updating driver location in real time in database
//   //         Map driverLatLngMap = {
//   //           'latitude': onlineDriverCurrentPosition!.latitude.toString(),
//   //           'longitude': onlineDriverCurrentPosition!.longitude.toString(),
//   //         };

//   //         FirebaseDatabase.instance
//   //             .ref()
//   //             .child('All Ride Requests')
//   //             .child(widget.userRideRequestDetails!.rideRequestId!)
//   //             .child('driverLocation')
//   //             .set(driverLatLngMap);
//   //       });
//   // }

//   // void getDriverLocationUpdatesAtRealTime() {
//   //   streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
//   //       .listen((Position position) async {
//   //         onlineDriverCurrentPosition = position;

//   //         LatLng newDriverLatLng = LatLng(
//   //           position.latitude,
//   //           position.longitude,
//   //         );

//   //         animateDriverMarker(newDriverLatLng);

//   //         // 2️⃣ Zoom camera while driving
//   //         newTripGoogleMapController!.animateCamera(
//   //           CameraUpdate.newCameraPosition(
//   //             CameraPosition(
//   //               target: newDriverLatLng,
//   //               zoom: rideRequestStatus == "ontrip" ? 17 : 16,
//   //               tilt: 65,
//   //               bearing: _lastRotation,
//   //             ),
//   //           ),
//   //         );

//   //         // updateDurationInRealTime();

//   //         maybeReroutePolyline(newDriverLatLng);

//   //         // 🚗 Update driver marker on map
//   //         // updateDriverMarker(newDriverLatLng);

//   //         // 📍 Update database location
//   //         FirebaseDatabase.instance
//   //             .ref()
//   //             .child("All Ride Requests")
//   //             .child(widget.userRideRequestDetails!.rideRequestId!)
//   //             .child("driverLocation")
//   //             .set({
//   //               "latitude": position.latitude,
//   //               "longitude": position.longitude,
//   //             });

//   //         // 📏 Smart dynamic zoom like Uber
//   //         smartAutoZoom(newDriverLatLng);

//   //         // 🔄 Update ETA in real time
//   //         updateDurationInRealTime();
//   //       });
//   // }

//   void getDriverLocationUpdatesAtRealTime() {
//     streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
//         .listen((Position position) async {
//           if (!mounted) return;

//           final newLatLng = LatLng(position.latitude, position.longitude);
//           onlineDriverCurrentPosition = position;

//           animateDriverMarker(newLatLng);

//           if (cameraFollow) {
//             smartAutoZoomOptimized(newLatLng);
//           }

//           maybeReroutePolylineOptimized(newLatLng);

//           updateDurationInRealTimeOptimized(newLatLng);

//           uploadDriverLocationDebounced(position);
//         });
//   }

//   void uploadDriverLocationDebounced(Position pos) {
//     firebaseUploadDebounce?.cancel();
//     firebaseUploadDebounce = Timer(const Duration(milliseconds: 800), () {
//       FirebaseDatabase.instance
//           .ref()
//           .child("All Ride Requests")
//           .child(widget.userRideRequestDetails!.rideRequestId!)
//           .child("driverLocation")
//           .update({"latitude": pos.latitude, "longitude": pos.longitude});
//     });
//   }

//   void maybeReroutePolylineOptimized(LatLng newPos) async {
//     if (lastRerouteDistance == 0) {
//       lastRerouteDistance = 1;
//     }

//     double moved = Geolocator.distanceBetween(
//       _lastDriverLatLng?.latitude ?? newPos.latitude,
//       _lastDriverLatLng?.longitude ?? newPos.longitude,
//       newPos.latitude,
//       newPos.longitude,
//     );

//     if (moved < 60) return; // reroute threshold

//     lastRerouteDistance = moved;

//     LatLng target = rideRequestStatus == "accepted"
//         ? widget.userRideRequestDetails!.originLatLng!
//         : widget.userRideRequestDetails!.destinationLatLng!;

//     await drawPolylineThrottled(newPos, target);
//   }

//   Future<void> drawPolylineThrottled(LatLng origin, LatLng destination) async {
//     if (DateTime.now().difference(lastDirectionCall).inSeconds < 8) {
//       return;
//     }

//     lastDirectionCall = DateTime.now();

//     await drawPolylineFromOriginToDestination(
//       origin,
//       destination,
//       Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
//     );
//   }

//   void smartAutoZoomOptimized(LatLng driver) async {
//     if (newTripGoogleMapController == null) return;

//     LatLng target = rideRequestStatus == "accepted"
//         ? widget.userRideRequestDetails!.originLatLng!
//         : widget.userRideRequestDetails!.destinationLatLng!;

//     double dist = Geolocator.distanceBetween(
//       driver.latitude,
//       driver.longitude,
//       target.latitude,
//       target.longitude,
//     );

//     double zoom = dist > 3000
//         ? 12
//         : dist > 1500
//         ? 14
//         : dist > 600
//         ? 15.5
//         : 17;

//     newTripGoogleMapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: driver,
//           zoom: zoom,
//           tilt: 58,
//           bearing: _lastRotation,
//         ),
//       ),
//     );
//   }

//   Future<void> updateDurationInRealTimeOptimized(LatLng driver) async {
//     if (!mounted) return;

//     if (DateTime.now().difference(lastDirectionCall).inSeconds < 8) {
//       return; // throttle ETA calls
//     }

//     lastDirectionCall = DateTime.now();

//     LatLng dest = rideRequestStatus == "accepted"
//         ? widget.userRideRequestDetails!.originLatLng!
//         : widget.userRideRequestDetails!.destinationLatLng!;

//     var info = await AppMethods.obtainOriginToDestinationDirectionDetails(
//       driver,
//       dest,
//     );

//     if (info != null && mounted) {
//       setState(() {
//         durationFromOriginToDestination = info.durationText!;
//       });
//     }
//   }

//   void smartAutoZoom(LatLng driverLatLng) async {
//     if (newTripGoogleMapController == null) return;

//     LatLng destinationLatLng;

//     if (rideRequestStatus == "accepted") {
//       destinationLatLng = widget.userRideRequestDetails!.originLatLng!;
//     } else {
//       destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;
//     }

//     double distance = Geolocator.distanceBetween(
//       driverLatLng.latitude,
//       driverLatLng.longitude,
//       destinationLatLng.latitude,
//       destinationLatLng.longitude,
//     );

//     double zoomLevel;

//     if (distance > 3000) {
//       zoomLevel = 12.5; // far — zoom out
//     } else if (distance > 1500) {
//       zoomLevel = 14;
//     } else if (distance > 500) {
//       zoomLevel = 15.5;
//     } else {
//       zoomLevel = 17.5; // very close — zoom in
//     }

//     newTripGoogleMapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: driverLatLng, zoom: zoomLevel),
//       ),
//     );
//   }

//   Future<void> animateMarkerMovement(
//     LatLng from,
//     LatLng to,
//     Function(LatLng) update,
//   ) async {
//     final double latDiff = to.latitude - from.latitude;
//     final double lngDiff = to.longitude - from.longitude;

//     const int steps = 25;
//     const int ms = 15;

//     for (int i = 1; i <= steps; i++) {
//       final newLat = from.latitude + (latDiff * (i / steps));
//       final newLng = from.longitude + (lngDiff * (i / steps));

//       update(LatLng(newLat, newLng));

//       await Future.delayed(const Duration(milliseconds: ms));
//     }
//   }

//   Future<void> updateDurationInRealTime() async {
//     if (isRequestDirectionDetails == false) {
//       isRequestDirectionDetails = true;

//       if (onlineDriverCurrentPosition == null) {
//         return;
//       }

//       LatLng originLatLng = LatLng(
//         onlineDriverCurrentPosition!.latitude,
//         onlineDriverCurrentPosition!.longitude,
//       );

//       LatLng destinationLatLng;

//       if (rideRequestStatus == 'accepted') {
//         destinationLatLng = widget.userRideRequestDetails!.originLatLng!;
//       } else {
//         destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;
//       }

//       var directionInformation =
//           await AppMethods.obtainOriginToDestinationDirectionDetails(
//             originLatLng,
//             destinationLatLng,
//           );

//       if (directionInformation != null) {
//         setState(() {
//           durationFromOriginToDestination = directionInformation.durationText!;
//         });
//       }

//       isRequestDirectionDetails = false;
//     }
//   }

//   Future<void> endTripNow() async {
//     showDialog(
//       context: context,
//       builder: ((BuildContext context) =>
//           ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait)),
//     );

//     cleanupResources();

//     FirebaseDatabase.instance
//         .ref()
//         .child('All Ride Requests')
//         .child(widget.userRideRequestDetails!.rideRequestId!)
//         .child('status')
//         .set('ended');

//     String driverId = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).profile!.id;

//     await FirebaseFirestore.instance
//         .collection('profiles')
//         .doc(driverId)
//         .update({'newRideStatus': 'idle'});

//     await FirebaseDatabase.instance
//         .ref()
//         .child('drivers')
//         .child(driverId)
//         .child('newRide')
//         .remove();

//     if (!mounted) return;
//     Navigator.pop(context);
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (c) => const DriverHome()),
//       (route) => false,
//     );
//   }

//   Future<void> _loadMapStyle() async {
//     String style = await rootBundle.loadString('map_themes/dark_style.json');
//     setState(() {
//       _mapStyle = style;
//     });
//   }

//   void cleanupResources() {
//     streamSubscriptionDriverLivePosition?.cancel();
//     newTripGoogleMapController?.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadMapStyle();
//     createDriverIconMarker();
//     buttonTitle = 'Arrived';
//     // Get driver's initial location safely
//     Geolocator.getCurrentPosition(
//       // desiredAccuracy: LocationAccuracy.high,
//       locationSettings: getLocationSetting(),
//     ).then((position) {
//       driverCurrentPosition = position;
//       onlineDriverCurrentPosition = position;

//       setState(() {}); // trigger rebuild once we have location
//     });

//     // Save ride details
//     saveAssignedDriverDetailsToUserRideRequest();

//     // ✅ Listen for ride cancellation in real-time
//     rideStatusRef = FirebaseDatabase.instance
//         .ref()
//         .child('All Ride Requests')
//         .child(widget.userRideRequestDetails!.rideRequestId!)
//         .child('status');

//     rideStatusSubscription = rideStatusRef!.onValue.listen((event) async {
//       final status = event.snapshot.value?.toString();

//       if (status == 'cancelled') {
//         // Stop location and cleanup
//         cleanupResources();
//         rideStatusSubscription?.cancel();

//         if (!mounted) return;

//         await FirebaseDatabase.instance
//             .ref()
//             .child('drivers')
//             .child(
//               Provider.of<ProfileProvider>(context, listen: false).profile!.id,
//             )
//             .child('newRide')
//             .remove();

//         if (!mounted) return;

//         // 🏠 Step 3: Redirect driver back home
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (c) => const DriverHome()),
//           (route) => false,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // Cancel live location updates
//     streamSubscriptionDriverLivePosition?.cancel();
//     rideStatusSubscription?.cancel();
//     // Dispose Google Map controller
//     newTripGoogleMapController?.dispose();

//     PushNotificationSystem().resetRideFlags();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     return Scaffold(
//       body: Column(
//         children: [
//           // Google Maps
//           Expanded(
//             child: GoogleMap(
//               padding: EdgeInsets.only(bottom: mapPadding),
//               mapType: MapType.normal,
//               myLocationEnabled: false,
//               initialCameraPosition: _kGooglePlex,
//               markers: markersSet,
//               circles: circlesSet,
//               polylines: polylinesSet,

//               style: isDark ? _mapStyle : null,
//               onMapCreated: (GoogleMapController controller) {
//                 _controllerGoogleMap.complete(controller);
//                 newTripGoogleMapController = controller;

//                 setState(() {
//                   mapPadding = 350;
//                 });

//                 var driverCurrentLatLng = LatLng(
//                   driverCurrentPosition!.latitude,
//                   driverCurrentPosition!.longitude,
//                 );

//                 var userPickupLatLng =
//                     widget.userRideRequestDetails!.originLatLng;

//                 drawPolylineFromOriginToDestination(
//                   driverCurrentLatLng,
//                   userPickupLatLng!,
//                   isDark,
//                 );

//                 getDriverLocationUpdatesAtRealTime();
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.fromLTRB(
//               12,
//               12,
//               12,
//               MediaQuery.of(context).padding.bottom + 5,
//             ),
//             color: Theme.of(context).scaffoldBackgroundColor,
//             child: Column(
//               children: [
//                 RideLocationCard(
//                   currentLocation:
//                       widget.userRideRequestDetails!.originAddress!,
//                   destinationAddress:
//                       widget.userRideRequestDetails!.destinationAddress!,
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: isDark
//                         ? AppColors.darkAccent
//                         : AppColors.lightAccent,
//                   ),
//                   child: Column(
//                     children: [
//                       rideRequestStatus == 'arrived'
//                           ? Text(
//                               AppLocalizations.of(context)!.waitingForRider,
//                               style: Theme.of(context).textTheme.labelMedium,
//                             )
//                           : rideRequestStatus == 'accepted'
//                           ? Text(
//                               "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toPickup}",
//                               style: Theme.of(context).textTheme.labelMedium,
//                             )
//                           : Text(
//                               "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toDropoff}",
//                               style: Theme.of(context).textTheme.labelMedium,
//                             ),
//                       SizedBox(height: 5),
//                       Divider(color: AppColors.border, thickness: 0.5),
//                       SizedBox(height: 5),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           // Driver arrives at pickup station - Arrived Button

//                           if (rideRequestStatus == 'accepted') {
//                             rideRequestStatus = 'arrived';
//                             setState(() {
//                               // print("Should print start trip");
//                               buttonTitle = AppLocalizations.of(
//                                 context,
//                               )!.startTrip;
//                             });

//                             FirebaseDatabase.instance
//                                 .ref()
//                                 .child('All Ride Requests')
//                                 .child(
//                                   widget.userRideRequestDetails!.rideRequestId!,
//                                 )
//                                 .child('status')
//                                 .set(rideRequestStatus);

//                             showDialog(
//                               context: context,
//                               barrierDismissible: false,
//                               builder: ((BuildContext context) =>
//                                   ProgressDialog(
//                                     message: AppLocalizations.of(
//                                       context,
//                                     )!.pleaseWait,
//                                   )),
//                             );

//                             await drawPolylineFromOriginToDestination(
//                               widget.userRideRequestDetails!.originLatLng!,
//                               widget.userRideRequestDetails!.destinationLatLng!,
//                               isDark,
//                             );
//                             if (!context.mounted) return;
//                             Navigator.pop(context);
//                           }
//                           // User is onboard - Trip Started Button
//                           else if (rideRequestStatus == 'arrived') {
//                             rideRequestStatus = 'ontrip';
//                             AppMethods.sendDriverArrivalNotification(
//                               widget.userRideRequestDetails!.userId!,
//                               widget.userRideRequestDetails!.originAddress!,
//                               context,
//                             );

//                             setState(() {
//                               // print('Button should be end trip');
//                               buttonTitle = AppLocalizations.of(
//                                 context,
//                               )!.endTrip;
//                             });

//                             FirebaseDatabase.instance
//                                 .ref()
//                                 .child('All Ride Requests')
//                                 .child(
//                                   widget.userRideRequestDetails!.rideRequestId!,
//                                 )
//                                 .child('status')
//                                 .set(rideRequestStatus);
//                           }
//                           // User reached dropoff location
//                           else if (rideRequestStatus == 'ontrip') {
//                             endTripNow();
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: Colors.white,
//                           disabledBackgroundColor: AppColors.primary.withValues(
//                             alpha: 0.5,
//                           ),
//                           disabledForegroundColor: Colors.white54,
//                           padding: EdgeInsets.all(16),
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         icon: Icon(Icons.directions_car, size: 25),
//                         label: Text(buttonTitle),
//                       ),
//                       SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: () => _makePhoneCall(
//                           context,
//                           widget.userRideRequestDetails!.userPhone!,
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: AppColors.primary,
//                           backgroundColor: Colors.white,
//                           disabledBackgroundColor: AppColors.primary.withValues(
//                             alpha: 0.5,
//                           ),
//                           disabledForegroundColor: Colors.white54,
//                           padding: EdgeInsets.all(8),
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.call, size: 28),
//                             SizedBox(width: 12),
//                             Text(widget.userRideRequestDetails!.username!),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
