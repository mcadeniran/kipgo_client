import 'dart:async';

import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart' as gf;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/screens/homes/customer_home.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
import 'package:kipgo/screens/rides/riders/search_origin_screen.dart';
import 'package:kipgo/utils/direction_service.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/active_nearby_available_driver.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rides/riders/search_places_screen.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/geofire_assistant.dart';
import 'package:kipgo/utils/methods.dart';

class RequestRide extends StatefulWidget {
  const RequestRide({super.key});

  @override
  State<RequestRide> createState() => _RequestRideState();
}

class _RequestRideState extends State<RequestRide> {
  StreamSubscription? driverQuerySubscription;
  StreamSubscription<dynamic>? _geoQuerySubscription;
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  LatLng? pickLocation;
  Position? userCurrentPosition;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.133428350758344, 33.923606022529256),
    zoom: 14.4746,
  );

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchingForDriversContainerHeight = 0;
  bool showSearchingContainer = false;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  BitmapDescriptor? activeNearbyIcon;

  String username = "";
  String userRideRequestStatus = '';

  bool activateNearbyDriverKeysLoaded = false;
  List<ActiveNearbyAvailableDriver> onlineNearbyAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = 'Driver is coming';

  String? _mapStyle;

  bool isProgrammaticClose = false;

  // ID used for the single user marker
  static const String _userMarkerId = 'user_marker';

  bool showDriverListsModel = false;

  final AudioPlayer player = AudioPlayer();

  Timer? _distanceTimer;

  bool _isRejectDialogShowing = false;

  static const int _requestTimeoutSeconds = 60; // you can change this
  Timer? _requestTimer;
  int _remainingSeconds = _requestTimeoutSeconds;
  bool _requestExpired = false;
  String _remainingSecondsText = '00.00';

  @override
  void initState() {
    super.initState();
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    if (isDark) _loadMapStyle();
    checkIfLocationPermissionAllowed();
    createActiveNearbyDriverIconMarker();
  }

  // ───────────────────────────────────────────
  // Helpers: distance, map-style, permissions
  // ───────────────────────────────────────────
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void checkIfLocationPermissionAllowed() async {
    await Geolocator.requestPermission();
  }

  Future<void> _loadMapStyle() async {
    final s = await DefaultAssetBundle.of(
      context,
    ).loadString('map_themes/dark_style.json');
    if (!mounted) return;
    setState(() => _mapStyle = s);
  }

  void createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = const ImageConfiguration(
        size: Size(30, 30),
      );
      BitmapDescriptor.asset(imageConfiguration, 'assets/images/car.png').then((
        value,
      ) {
        if (!mounted) return;
        activeNearbyIcon = value;
      });
    }
  }

  void scheduleDistanceUpdate() {
    _distanceTimer?.cancel();
    _distanceTimer = Timer(const Duration(seconds: 8), () {
      debugPrint("Scheduling Timer");
      updateDriversRoadDistance();
    });
  }

  // ───────────────────────────────────────────
  // User marker management
  // ───────────────────────────────────────────
  void _addOrUpdateUserMarker(LatLng pos) {
    if (!mounted) return;
    final marker = Marker(
      markerId: const MarkerId(_userMarkerId),
      position: pos,
      infoWindow: const InfoWindow(title: 'Pickup'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    // If there's a drawn polyline, we remove the user marker (origin marker will show)
    if (polylineSet.isNotEmpty) {
      markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
    } else {
      markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
      markersSet.add(marker);
    }

    setState(() {});
  }

  void _removeUserMarker() {
    if (!mounted) return;
    markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
    setState(() {});
  }

  // ───────────────────────────────────────────
  // Locate user position (initial)
  // ───────────────────────────────────────────
  Future<void> locateUserPosition() async {
    try {
      final cPosition = await Geolocator.getCurrentPosition();
      userCurrentPosition = cPosition;
      final latLngPosition = LatLng(cPosition.latitude, cPosition.longitude);

      // Move camera to user
      final controller = await _controllerGoogleMap.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLngPosition, zoom: 15),
        ),
      );

      // Update pickup in provider (so other logic uses it)
      if (!mounted) return;
      final humanReadableAddress =
          await AppMethods.searchAddressFromGeographicalCoordinates(
            cPosition,
            context,
          );
      debugPrint("Address: $humanReadableAddress");

      // Update provider pick up location (existing method)
      final userPickup = Direction()
        ..locationLatitude = latLngPosition.latitude
        ..locationLongitude = latLngPosition.longitude
        ..locationName = humanReadableAddress;
      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(userPickup);

      // Add user marker and initialize drivers query with this center
      _addOrUpdateUserMarker(latLngPosition);
      initializeNearbyDriverListener(
        centerLat: latLngPosition.latitude,
        centerLng: latLngPosition.longitude,
      );
      scheduleDistanceUpdate();
    } catch (e) {
      debugPrint("locateUserPosition error: $e");
    }
  }

  // ───────────────────────────────────────────
  // Initialize nearby driver listener — explicit center (pickup)
  // Cancels previous driver query safely.
  // ───────────────────────────────────────────
  void initializeNearbyDriverListener({
    required double centerLat,
    required double centerLng,
    double radiusKm = 5.0,
  }) {
    // cancel previous
    driverQuerySubscription?.cancel();
    driverQuerySubscription = null;

    final geo = gf.GeoFlutterFire();
    final driversCollection = FirebaseFirestore.instance.collection(
      'activeDrivers',
    );

    final center = geo.point(latitude: centerLat, longitude: centerLng);

    driverQuerySubscription = geo
        .collection(collectionRef: driversCollection)
        .within(center: center, radius: radiusKm, field: 'position')
        .listen((List<DocumentSnapshot> documentList) {
          if (!mounted) return;

          GeofireAssistant.activeNearbyAvailableDriversList.clear();

          for (var doc in documentList) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null || data['position'] == null) continue;
            final GeoPoint point = data['position']['geopoint'];

            final distance = calculateDistance(
              centerLat,
              centerLng,
              point.latitude,
              point.longitude,
            );
            if (distance <= radiusKm) {
              final driver = ActiveNearbyAvailableDriver()
                ..driverId = doc.id
                ..locationLatitude = point.latitude
                ..locationLongitude = point.longitude
                ..distanceToPickupKm = distance;
              GeofireAssistant.activeNearbyAvailableDriversList.add(driver);
            }
          }

          GeofireAssistant.activeNearbyAvailableDriversList.sort(
            (a, b) => (a.distanceToPickupKm ?? 0).compareTo(
              b.distanceToPickupKm ?? 0,
            ),
          );

          // After updating list, refresh markers
          displayActiveDriversOnUserMap();
          updateDriversRoadDistance();
          scheduleDistanceUpdate();
        });
  }

  Future<void> updateDriversRoadDistance() async {
    final pickup = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );

    if (GeofireAssistant.activeNearbyAvailableDriversList.isNotEmpty) {
      for (final driver in GeofireAssistant.activeNearbyAvailableDriversList) {
        final driverPos = LatLng(
          driver.locationLatitude!,
          driver.locationLongitude!,
        );

        final result = await DirectionsService.getRouteInfo(
          origin: driverPos,
          destination: pickup,
        );

        if (result != null) {
          driver.roadDistanceKm = result.distanceKm;
          driver.etaMinutes = result.durationMin;
        }
      }
    }

    if (!mounted) return;

    // rebuild parent
    setState(() {});

    // 🔥 FORCE bottom sheet rebuild
    if (isBottomSheetOpen && _bottomSheetSetState != null) {
      _bottomSheetSetState!(() {});
    }
  }

  double? getDistanceForDriver(String driverId) {
    try {
      return GeofireAssistant.activeNearbyAvailableDriversList
          .firstWhere((d) => d.driverId == driverId)
          .distanceToPickupKm;
    } catch (_) {
      return null;
    }
  }

  void Function(void Function())? _bottomSheetSetState;

  void displayActiveDriversOnUserMap() {
    if (!mounted) return;
    // keep origin/destination markers and circle set intact
    // Build set with drivers + existing non-driver markers (origin/destination)
    final nonDriverMarkers = markersSet.where((m) {
      final id = m.markerId.value;
      return id != _userMarkerId &&
          id != 'driver_marker_' &&
          !id.startsWith('driver_');
    }).toSet();

    final Set<Marker> driversMarkerSet = <Marker>{};
    for (ActiveNearbyAvailableDriver eachDriver
        in GeofireAssistant.activeNearbyAvailableDriversList) {
      final LatLng pos = LatLng(
        eachDriver.locationLatitude!,
        eachDriver.locationLongitude!,
      );
      final marker = Marker(
        markerId: MarkerId('driver_${eachDriver.driverId}'),
        position: pos,
        icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarker,
        rotation: 360,
      );
      driversMarkerSet.add(marker);
    }

    markersSet = {...nonDriverMarkers, ...driversMarkerSet};

    // ensure user marker is present if no polyline
    if (polylineSet.isEmpty && userCurrentPosition != null) {
      _addOrUpdateUserMarker(
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
      );
    } else {
      // remove user marker when polyline exists
      markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
    }

    setState(() {});
  }

  // ───────────────────────────────────────────
  // Draw polyline origin -> destination (you already had this)
  // When polyline exists, remove the simple user marker (we keep origin marker)
  // ───────────────────────────────────────────
  Future<void> drawPolyLineFromOriginToDestination(bool isDark) async {
    final originPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    final destinationPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userDropOffLocation;

    if (destinationPosition == null) return;

    final originLatLng = LatLng(
      originPosition!.locationLatitude!,
      originPosition.locationLongitude!,
    );
    final destinationLatLng = LatLng(
      destinationPosition.locationLatitude!,
      destinationPosition.locationLongitude!,
    );

    // show progress
    if (mounted) {
      showDialog(
        context: context,
        builder: (c) =>
            ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
      );
    }

    final directionDetailsInfo =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    if (!mounted) return;
    Navigator.pop(context); // remove progress dialog

    if (directionDetailsInfo == null) return;

    tripDirectionDetailsInfo = directionDetailsInfo;

    final PolylinePoints pPoints = PolylinePoints();
    final List<PointLatLng> decoded = pPoints.decodePolyline(
      directionDetailsInfo.ePoints!,
    );

    pLineCoordinateList.clear();
    for (var pt in decoded) {
      pLineCoordinateList.add(LatLng(pt.latitude, pt.longitude));
    }

    // create polyline
    final polyline = Polyline(
      color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
      polylineId: const PolylineId('route'),
      points: pLineCoordinateList,
      width: 5,
    );

    polylineSet.clear();
    polylineSet.add(polyline);

    // remove user marker (we'll add origin/dest markers)
    _removeUserMarker();

    // add origin/destination markers
    final originMarker = Marker(
      markerId: const MarkerId('originId'),
      position: originLatLng,
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: AppLocalizations.of(context)!.from,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    final destMarker = Marker(
      markerId: const MarkerId('destinationId'),
      position: destinationLatLng,
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: AppLocalizations.of(context)!.to,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
    markersSet.add(originMarker);
    markersSet.add(destMarker);

    // add circles
    circlesSet.clear();
    circlesSet.add(
      Circle(
        circleId: const CircleId('originId'),
        center: originLatLng,
        radius: 12,
        fillColor: Colors.green,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
    );
    circlesSet.add(
      Circle(
        circleId: const CircleId('destinationId'),
        center: destinationLatLng,
        radius: 12,
        fillColor: Colors.red,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
    );

    // move camera to show route
    final controller = await _controllerGoogleMap.future;
    LatLngBounds bounds;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));

    setState(() {});
  }

  // ───────────────────────────────────────────
  // Save ride request (keeps most of your logic, but uses pickup from provider)
  // ───────────────────────────────────────────
  Future<void> saveRideRequestInformation() async {
    referenceRideRequest = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .push();
    final rideId = referenceRideRequest!.key!;
    debugPrint("NEW RIDE REQUEST ID: $rideId");

    final originLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    final destinationLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userDropOffLocation;
    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    final userInformationMap = {
      'origin': {
        "latitude": originLocation!.locationLatitude.toString(),
        "longitude": originLocation.locationLongitude.toString(),
      },
      'destination': {
        "latitude": destinationLocation!.locationLatitude.toString(),
        "longitude": destinationLocation.locationLongitude.toString(),
      },
      'time': DateTime.now().toString(),
      'userId': profile.id,
      'username': profile.username,
      'userPhone': profile.personal.phone,
      'originAddress': originLocation.locationName,
      'destinationAddress': destinationLocation.locationName,
      'driverId': 'waiting',
      'proposedFare': null,
      'fareStatus': 'waiting_driver',
    };

    await referenceRideRequest!.set(userInformationMap);

    Provider.of<AppInfo>(context, listen: false).setActiveRideId(rideId);

    // subscribe for ride changes
    tripRideRequestInfoStreamSubscription?.cancel();
    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((
      eventSnap,
    ) async {
      if (eventSnap.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(eventSnap.snapshot.value as Map);

      if (!mounted) return;
      setState(() {
        driverCarModel = data['model'] ?? driverCarModel;
        driverCarColour = data['colour'] ?? driverCarColour;
        driverNumberPlate = data['numberPlate'] ?? driverNumberPlate;
        driverPhone = data['driverPhone'] ?? driverPhone;
        driverName = data['driverName'] ?? driverName;
        driverPhotoUrl = data['driverPhotoUrl'] ?? driverPhotoUrl;
        userRideRequestStatus = data['status'] ?? userRideRequestStatus;
      });

      if (userRideRequestStatus == 'rejected') {
        setState(() {
          // assignedDriverInfoContainerHeight = 0;
          userRideRequestStatus = '';
        });
        // showBottomDriversListModel();
        hideSearchingForDriversContainer();
        if (referenceRideRequest != null) {
          referenceRideRequest!.remove();
          referenceRideRequest = null;
          // Provider.of<AppInfo>(context, listen: false).setActiveRideId('');
        }
        // WITHOUT CLEANUP
        // cleanupRideResources();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.yourRideWasRejected,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.tertiary,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );

          _showRideRejectedDialog();
          // Optionally re-open driver list modal
          // showDriverListsModel = true;
          // showBottomDriversListModel();
        }
        return; // stop here since rejected
      }

      // fare negotiation (kept)
      if (data.containsKey("fareStatus")) {
        final fareStatus = data["fareStatus"];
        final fare = data["proposedFare"];
        debugPrint("PROPOSED FARE ₺$fare");
        if (fareStatus == "waiting_for_rider" && fare != null) {
          // notify user
          // play sound, show popup
          if (!mounted) return;
          await player.play(AssetSource('sounds/notification.mp3'));
          if (!mounted) return;
          _requestTimer?.cancel();
          hideSearchingForDriversContainer();
          showFareProposalPopup(fare);
        }
        if (fareStatus == "rejected") {
          _requestTimer?.cancel();
          if (mounted) {
            await player.play(AssetSource('sounds/notification.mp3'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("You rejected the fare. Ride cancelled.")),
            );
          }
          referenceRideRequest?.remove();
          cleanupRideResources();
          return;
        }
      }

      // driver location update leading to accepted status (your previous logic)
      if (data['driverLocation'] != null) {
        switch (userRideRequestStatus) {
          case 'accepted':
            _requestTimer?.cancel();
            cleanupRideResources();
            if (mounted) {
              Profile profile = Provider.of<ProfileProvider>(
                context,
                listen: false,
              ).profile!;
              Provider.of<AppInfo>(
                context,
                listen: false,
              ).updateActiveRideStatus(true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      profile.role == 'rider' ? CustomerHome() : DriverHome(),
                ),
                (route) => false,
              );
            }
            break;
          default:
            break;
        }
      }
    });

    // start searching drivers based on the current pickup (important)
    if (userCurrentPosition != null) {
      initializeNearbyDriverListener(
        centerLat: userCurrentPosition!.latitude,
        centerLng: userCurrentPosition!.longitude,
      );

      scheduleDistanceUpdate();
    } else if (Provider.of<AppInfo>(
          context,
          listen: false,
        ).userPickUpLocation !=
        null) {
      final pick = Provider.of<AppInfo>(
        context,
        listen: false,
      ).userPickUpLocation!;
      initializeNearbyDriverListener(
        centerLat: pick.locationLatitude!,
        centerLng: pick.locationLongitude!,
      );
      scheduleDistanceUpdate();
    } else {
      // fallback - locate user
      await locateUserPosition();
    }

    // start the UI searching state
    setState(() {
      showSearchingContainer = true;
      searchingForDriversContainerHeight = 280;
    });

    // fetch driver info for list
    onlineNearbyAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);
    showBottomDriversListModel();
  }

  void _startRequestTimer() {
    _requestTimer?.cancel();
    _remainingSeconds = _requestTimeoutSeconds;
    _requestExpired = false;

    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onRequestTimedOut();
      } else {
        setState(() {
          int minutes = _remainingSeconds ~/ 60;
          int seconds = _remainingSeconds % 60;
          _remainingSecondsText =
              "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _onRequestTimedOut() async {
    if (_requestExpired) return;
    _requestExpired = true;

    debugPrint("⏰ Ride request timed out");

    // Stop listening
    _requestTimer?.cancel();
    tripRideRequestInfoStreamSubscription?.cancel();
    tripRideRequestInfoStreamSubscription = null;

    // Remove request from DB
    if (referenceRideRequest != null) {
      await referenceRideRequest!.remove();
      referenceRideRequest = null;
      // Provider.of<AppInfo>(context, listen: false).setActiveRideId('');
    }

    hideSearchingForDriversContainer();

    if (!mounted) return;

    // UI feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Request timeout'),
        content: Text('Driver did not accept request'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showRideRejectedDialog() {
    if (_isRejectDialogShowing) return;

    _isRejectDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.rideCancelled),
        content: Text(AppLocalizations.of(ctx)!.yourRideWasRejected),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _isRejectDialogShowing = false;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    ).whenComplete(() {
      _isRejectDialogShowing = false;
    });
  }

  // ────────────────────────
  // Fare popup & other methods
  // ────────────────────────
  void showFareProposalPopup(num fare) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.driverProposedFare,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "₺${fare.toString()}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await referenceRideRequest!.update({
                    "fareStatus": "accepted",
                  });
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  AppLocalizations.of(context)!.acceptFare,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  await referenceRideRequest!.update({
                    "fareStatus": "rejected",
                  });
                  if (mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(AppLocalizations.of(context)!.rejectFare),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> retrieveOnlineDriversInformation(
    List onlineNearestDriverList,
  ) async {
    driversList.clear();
    for (int i = 0; i < onlineNearestDriverList.length; i++) {
      final snap = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(onlineNearestDriverList[i].driverId)
          .get();
      driversList.add(Profile.fromFirestore(snap));
    }
  }

  bool isBottomSheetOpen = false;

  void showBottomDriversListModel() {
    if (!mounted) return;
    isProgrammaticClose = false;
    isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            _bottomSheetSetState = modalSetState;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.selectDriver,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  driversList.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.noAvailableDriverNearby,
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => Divider(
                              thickness: 0.4,
                              color: AppColors.border,
                            ),
                            itemCount: driversList.length,
                            itemBuilder: (context, index) {
                              final ride = driversList[index];
                              final driverDistance = GeofireAssistant
                                  .activeNearbyAvailableDriversList
                                  .firstWhere(
                                    (d) => d.driverId == ride.id,
                                    orElse: () => ActiveNearbyAvailableDriver(),
                                  );
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: AppColors.primary,
                                          backgroundImage: NetworkImage(
                                            ride.personal.photoUrl,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ride.username,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            if (driverDistance.roadDistanceKm !=
                                                null)
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 400,
                                                ),
                                                transitionBuilder:
                                                    (child, animation) =>
                                                        FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        ),
                                                child: Text(
                                                  "${driverDistance.roadDistanceKm!.toStringAsFixed(1)} km • "
                                                  "${driverDistance.etaMinutes!.round()} min away",
                                                  key: ValueKey(
                                                    "${driverDistance.roadDistanceKm}-${driverDistance.etaMinutes}",
                                                  ),
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                              )
                                            else
                                              const Text(
                                                "Calculating distance...",
                                              ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Text(ride.vehicle.model),
                                                // Text("${ride['model']}"),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.circle,
                                                  size: 6,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(ride.vehicle.colour),
                                                // Text("${ride['colour']}"),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppColors.border,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    // ride['registration'] as String,
                                                    ride.vehicle.numberPlate,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                StarRating(
                                                  rating: ride.personal.rating,
                                                  // rating: ride['rating'] as double,
                                                  allowHalfRating: true,
                                                  color: Colors.amber,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        AppMethods.sendNotificationToDriverNow(
                                          ride.token,
                                          referenceRideRequest!.key!,
                                          context,
                                        );
                                        setState(() {
                                          showDriverListsModel = false;
                                        });

                                        isProgrammaticClose =
                                            true; // <- important
                                        Navigator.pop(
                                          context,
                                        ); // Close bottom sheet safely
                                        // MIGHT REMOVE
                                        // showBottomDriversListModel();
                                        _startRequestTimer();
                                        showSearchingForDriversContainer();
                                      },
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.requestRide,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      isBottomSheetOpen = false;
      _bottomSheetSetState = null;
      // If user dismissed manually -> delete request
      if (!isProgrammaticClose) {
        if (referenceRideRequest != null) {
          referenceRideRequest!.remove();
          referenceRideRequest = null;
          hideSearchingForDriversContainer();
        }
      }
    });
  }

  void showSearchingForDriversContainer() {
    if (!mounted) return;
    setState(() {
      showSearchingContainer = true;
      searchingForDriversContainerHeight = 280;
    });
  }

  void hideSearchingForDriversContainer() {
    if (!mounted) return;
    setState(() {
      showSearchingContainer = false;
      searchingForDriversContainerHeight = 0;
    });
  }

  // ───────────────────────────────────────────
  // Cleanup
  // ───────────────────────────────────────────
  void cleanupRideResources() async {
    _requestTimer?.cancel();
    tripRideRequestInfoStreamSubscription?.cancel();
    tripRideRequestInfoStreamSubscription = null;

    driverQuerySubscription?.cancel();
    driverQuerySubscription = null;

    _geoQuerySubscription?.cancel();
    _geoQuerySubscription = null;

    referenceRideRequest?.onDisconnect();

    newGoogleMapController?.dispose();
    newGoogleMapController = null;

    markersSet.clear();
    circlesSet.clear();
    polylineSet.clear();
    pLineCoordinateList.clear();
    userRideRequestStatus = '';
    // setState(() {});
  }

  @override
  void dispose() {
    cleanupRideResources();
    super.dispose();
  }

  // ───────────────────────────────────────────
  // Map tap handling — change pickup to tapped location
  // ───────────────────────────────────────────
  Future<void> _onMapTap(LatLng latlng) async {
    // get address from latlng using your helper
    final humanAddress = await AppMethods.getAddressFromLatLng(latlng, context);
    debugPrint(humanAddress);

    // update provider's pickup
    final userPickup = Direction()
      ..locationLatitude = latlng.latitude
      ..locationLongitude = latlng.longitude
      ..locationName = humanAddress;
    if (!mounted) return;
    Provider.of<AppInfo>(
      context,
      listen: false,
    ).updatePickUpLocationAddress(userPickup);

    // update local userCurrentPosition and user marker
    userCurrentPosition = Position(
      latitude: latlng.latitude,
      longitude: latlng.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    _addOrUpdateUserMarker(latlng);

    // re-run driver query centered on new pickup
    initializeNearbyDriverListener(
      centerLat: latlng.latitude,
      centerLng: latlng.longitude,
    );

    Future.delayed(const Duration(seconds: 1), () {
      updateDriversRoadDistance();
    });
  }

  Future<void> openPickupSearch() async {
    final Direction? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchOriginScreen()),
    );

    if (pickedLocation != null) {
      // update provider's pickup
      final userPickup = Direction()
        ..locationLatitude = pickedLocation.locationLatitude
        ..locationLongitude = pickedLocation.locationLongitude
        ..locationName = pickedLocation.locationName;
      if (!mounted) return;
      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(userPickup);

      // update local userCurrentPosition and user marker
      userCurrentPosition = Position(
        latitude: pickedLocation.locationLatitude!,
        longitude: pickedLocation.locationLongitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      _addOrUpdateUserMarker(
        LatLng(
          pickedLocation.locationLatitude!,
          pickedLocation.locationLongitude!,
        ),
      );

      final controller = await _controllerGoogleMap.future;

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              pickedLocation.locationLatitude!,
              pickedLocation.locationLongitude!,
            ),
            zoom: 15,
          ),
        ),
      );

      // re-run driver query centered on new pickup
      initializeNearbyDriverListener(
        centerLat: pickedLocation.locationLatitude!,
        centerLng: pickedLocation.locationLongitude!,
      );

      scheduleDistanceUpdate();

      await drawPolyLineFromOriginToDestination(
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
      );
    }
  }

  // ───────────────────────────────────────────
  // UI
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldState,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              style: isDark ? _mapStyle : null,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              circles: circlesSet,
              markers: markersSet,
              onMapCreated: (controller) {
                if (!_controllerGoogleMap.isCompleted) {
                  _controllerGoogleMap.complete(controller);
                }
                newGoogleMapController = controller;
                setState(() => bottomPaddingOfMap = 200);
                locateUserPosition();
              },
              onTap: (argument) async {
                await _onMapTap(LatLng(argument.latitude, argument.longitude));
              },
            ),

            // Top UI (pickup/destination + request button) — kept your existing layout outline
            Positioned(
              left: 0,
              right: 0,
              top: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                              // color: Colors.red,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: openPickupSearch,
                                    child: Row(
                                      children: [
                                        Iconify(
                                          Ic.my_location,
                                          color: isDark
                                              ? AppColors.darkLayer
                                              : AppColors.primary,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.from,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppColors.darkLayer
                                                      : AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                Provider.of<AppInfo>(
                                                          context,
                                                        ).userPickUpLocation !=
                                                        null
                                                    ? (Provider.of<AppInfo>(
                                                            context,
                                                          )
                                                          .userPickUpLocation!
                                                          .locationName!)
                                                    : AppLocalizations.of(
                                                        context,
                                                      )!.unknownAddress,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: InkWell(
                                    onTap: () async {
                                      var responseFromSearchScreen =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  SearchPlacesScreen(),
                                            ),
                                          );

                                      if (responseFromSearchScreen ==
                                          'obtainedDropOff') {
                                        setState(() {
                                          // do something
                                        });
                                      }

                                      await drawPolyLineFromOriginToDestination(
                                        isDark,
                                      );
                                    },

                                    child: Row(
                                      children: [
                                        Iconify(
                                          Ic.location_on,
                                          color: isDark
                                              ? AppColors.darkLayer
                                              : AppColors.primary,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.to,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppColors.darkLayer
                                                      : AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                Provider.of<AppInfo>(
                                                          context,
                                                        ).userDropOffLocation !=
                                                        null
                                                    ? (Provider.of<AppInfo>(
                                                            context,
                                                          )
                                                          .userDropOffLocation!
                                                          .locationName!)
                                                    : AppLocalizations.of(
                                                        context,
                                                      )!.enterDestination,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              if (Provider.of<AppInfo>(
                                        context,
                                        listen: false,
                                      ).userDropOffLocation !=
                                      null &&
                                  Provider.of<AppInfo>(
                                        context,
                                        listen: false,
                                      ).userPickUpLocation !=
                                      null) {
                                debugPrint("SHOULD CREATE RIDEREQUEST");
                                saveRideRequestInformation();
                              } else {
                                final snackBarPickup = SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterPickupAddress,
                                  ),
                                  duration: const Duration(seconds: 3),
                                );
                                final snackBarDestination = SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterDestination,
                                  ),
                                  duration: const Duration(seconds: 3),
                                );

                                if (Provider.of<AppInfo>(
                                      context,
                                      listen: false,
                                    ).userPickUpLocation ==
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(snackBarPickup);
                                } else if (Provider.of<AppInfo>(
                                      context,
                                      listen: false,
                                    ).userDropOffLocation ==
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(snackBarDestination);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkLayer
                                  : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  4.0,
                                ), // Adjust the radius as needed
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.requestARide,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Searching container (bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                clipBehavior: Clip.hardEdge,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: searchingForDriversContainerHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showSearchingContainer ? 1.0 : 0.0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      _remainingSeconds /
                                      _requestTimeoutSeconds,
                                  strokeWidth: 8,
                                  valueColor: AlwaysStoppedAnimation(
                                    isDark
                                        ? AppColors.darkLayer
                                        : AppColors.lightLayer,
                                  ),
                                  backgroundColor: AppColors.tertiary,
                                ),
                                Center(
                                  child: Text(
                                    _remainingSecondsText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.waitingForDriver,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          //
                          // const LinearProgressIndicator(),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              hideSearchingForDriversContainer();
                              _requestTimer?.cancel();
                              if (referenceRideRequest != null) {
                                referenceRideRequest!.remove();
                                referenceRideRequest = null;
                                Provider.of<AppInfo>(
                                  context,
                                  listen: false,
                                ).setActiveRideId('');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
