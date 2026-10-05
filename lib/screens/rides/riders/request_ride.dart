import 'dart:async';
import 'dart:io';

import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart' as gf;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/models/predicted_places.dart';
import 'package:kipgo/utils/direction_service.dart';
import 'package:kipgo/utils/request_assistant.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/active_nearby_available_driver.dart';
import 'package:kipgo/models/profile.dart';
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

  Marker? _pickupMarker;
  Marker? _destinationMarker;
  Set<Marker> _driverMarkers = {};

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
  // static const String _userMarkerId = 'user_marker';

  bool showDriverListsModel = false;

  final AudioPlayer player = AudioPlayer();

  Timer? _distanceTimer;

  bool _isRejectDialogShowing = false;

  static const int _requestTimeoutSeconds = 60; // you can change this
  Timer? _requestTimer;
  int _remainingSeconds = _requestTimeoutSeconds;
  bool _requestExpired = false;
  String _remainingSecondsText = '00.00';

  double _currentSearchRadiusKm = 5.0;
  bool _expandedSearchAccepted = false;
  bool _noDriversFound = false;

  bool _isRequestingRide = false;

  static const double _defaultRadiusKm = 5.0;
  static const double _expandedRadiusKm = 15.0;
  static const int _maxDriversAfterExpand = 5;
  bool _isExpandingSearch = false;

  bool get shouldShowExpandSearchCTA =>
      _noDriversFound && !_expandedSearchAccepted;

  final Map<String, Profile> _driverProfileCache = {};

  final GlobalKey<AnimatedListState> _driverListKey =
      GlobalKey<AnimatedListState>();

  final List<String> _shownDriverIds = [];

  // Overlay state
  bool _showSearchOverlay = false;
  bool _isPickupSearch = true;

  bool _hasReturnedToHome = false;

  // Search controller & results
  final TextEditingController _searchController = TextEditingController();
  List<PredictedPlaces> _searchResults = [];

  // API key
  final String? apiKey = dotenv.env['GOOGLE_API_KEY'];

  bool _isMapLoading = false;

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
      updateDriversRoadDistance();
    });
  }

  void _rebuildMarkers() {
    final newMarkers = <Marker>{};

    if (_pickupMarker != null) {
      newMarkers.add(_pickupMarker!);
    }

    if (_destinationMarker != null) {
      newMarkers.add(_destinationMarker!);
    }

    newMarkers.addAll(_driverMarkers);
    if (!mounted) return;
    setState(() {
      markersSet = newMarkers;
    });
  }

  void _addOrUpdateUserMarker(LatLng latlng) {
    _pickupMarker = Marker(
      markerId: const MarkerId("pickupId"),
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _rebuildMarkers();
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

  void initializeNearbyDriverListener({
    required double centerLat,
    required double centerLng,
    double? radiusKm,
  }) {
    driverQuerySubscription?.cancel();

    final geo = gf.GeoFlutterFire();
    final driversCollection = FirebaseFirestore.instance.collection(
      'activeDrivers',
    );

    final center = geo.point(latitude: centerLat, longitude: centerLng);
    final effectiveRadius = radiusKm ?? _currentSearchRadiusKm;

    driverQuerySubscription = geo
        .collection(collectionRef: driversCollection)
        .within(center: center, radius: effectiveRadius, field: 'position')
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

            if (distance <= effectiveRadius) {
              GeofireAssistant.activeNearbyAvailableDriversList.add(
                ActiveNearbyAvailableDriver()
                  ..driverId = doc.id
                  ..locationLatitude = point.latitude
                  ..locationLongitude = point.longitude
                  ..distanceToPickupKm = distance,
              );
            }
          }

          GeofireAssistant.activeNearbyAvailableDriversList.sort(
            (a, b) => (a.distanceToPickupKm ?? 0).compareTo(
              b.distanceToPickupKm ?? 0,
            ),
          );

          // LIMIT to 5 drivers after expansion
          if (_expandedSearchAccepted &&
              GeofireAssistant.activeNearbyAvailableDriversList.length >
                  _maxDriversAfterExpand) {
            GeofireAssistant.activeNearbyAvailableDriversList = GeofireAssistant
                .activeNearbyAvailableDriversList
                .take(_maxDriversAfterExpand)
                .toList();
          }

          unawaited(refreshDriverList());

          _noDriversFound =
              GeofireAssistant.activeNearbyAvailableDriversList.isEmpty;

          displayActiveDriversOnUserMap();
          updateDriversRoadDistance();
          scheduleDistanceUpdate();

          if (_bottomSheetSetState != null) {
            _bottomSheetSetState!(() {});
          }
          setState(() {});
        });
  }

  Future<void> updateDriversRoadDistance() async {
    if (!mounted) return;

    final pickupDetails = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;

    if (pickupDetails == null) return;

    final pickup = LatLng(
      pickupDetails.locationLatitude!,
      pickupDetails.locationLongitude!,
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

    // markersSet = {...nonDriverMarkers, ...driversMarkerSet};
    _driverMarkers = driversMarkerSet;
    _rebuildMarkers();

    Direction? pickupLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;

    if (polylineSet.isEmpty && pickupLocation != null) {
      _addOrUpdateUserMarker(
        LatLng(
          pickupLocation.locationLatitude!,
          pickupLocation.locationLongitude!,
        ),
      );
    } else {
      // remove user marker when polyline exists
      // markersSet.removeWhere((m) => m.markerId.value == _userMarkerId);
    }

    setState(() {});
  }

  // ───────────────────────────────────────────
  // Draw polyline origin -> destination
  // When polyline exists, remove the simple user marker
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

    _pickupMarker = Marker(
      markerId: const MarkerId('pickupId'),
      position: originLatLng,
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: AppLocalizations.of(context)!.from,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _destinationMarker = Marker(
      markerId: const MarkerId('destinationId'),
      position: destinationLatLng,
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: AppLocalizations.of(context)!.to,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _rebuildMarkers();

    // add circles
    circlesSet.clear();
    circlesSet.add(
      Circle(
        circleId: const CircleId('originId'),
        center: originLatLng,
        radius: 0,
        fillColor: Colors.green,
        strokeWidth: 3,
        strokeColor: Colors.white,
      ),
    );
    circlesSet.add(
      Circle(
        circleId: const CircleId('destinationId'),
        center: destinationLatLng,
        radius: 0,
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

  // ─────────────────
  // Save ride request
  // ─────────────────
  Future<void> saveRideRequestInformation() async {
    referenceRideRequest = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .push();
    final rideId = referenceRideRequest!.key!;

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

    final estimate = await DirectionsService.getRouteInfo(
      origin: LatLng(
        originLocation!.locationLatitude!,
        originLocation.locationLongitude!,
      ),
      destination: LatLng(
        destinationLocation!.locationLatitude!,
        destinationLocation.locationLongitude!,
      ),
    );

    debugPrint('DESTINATION: ${destinationLocation.locationName}');

    final userInformationMap = {
      'origin': {
        'latitude': originLocation.locationLatitude,
        'longitude': originLocation.locationLongitude,
      },
      'destination': {
        'latitude': destinationLocation.locationLatitude,
        'longitude': destinationLocation.locationLongitude,
      },
      'tripEstimates': {
        'distanceKm': estimate!.distanceKm,
        'durationMin': estimate.durationMin,
      },
      'time': DateTime.now().toIso8601String(),
      'userId': profile.id,
      'username': profile.username,
      'userPhone': profile.personal.phone,
      'originAddress': originLocation.locationName,
      'destinationAddress': destinationLocation.locationName,
      'driverId': 'waiting',
      'proposedFare': null,
      'fareStatus': 'waiting_driver',
      'status': 'searching',
    };

    await referenceRideRequest!.set(userInformationMap);

    Provider.of<AppInfo>(context, listen: false).setActiveRideId(rideId);

    // subscribe for ride changes
    tripRideRequestInfoStreamSubscription?.cancel();
    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen(
      (eventSnap) async {
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
          _requestTimer?.cancel();
          resetDriverSearch();
          hideSearchingForDriversContainer();
          if (referenceRideRequest != null) {
            referenceRideRequest!.remove();
            referenceRideRequest = null;
            // Provider.of<AppInfo>(context, listen: false).setActiveRideId('');
          }

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
          }
          return; // stop here since rejected
        }

        // fare negotiation (kept)
        if (data.containsKey("fareStatus")) {
          final fareStatus = data["fareStatus"];
          final fare = data["proposedFare"];
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
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.youRejectedTheFare,
                  ),
                ),
              );
            }
            referenceRideRequest?.remove();
            cleanupRideResources();
            return;
          }
        }

        // driver location update leading to accepted status
        if (data['driverLocation'] != null) {
          switch (userRideRequestStatus) {
            case 'accepted':
              if (_hasReturnedToHome) {
                break;
              }

              _hasReturnedToHome = true;
              _requestTimer?.cancel();
              resetDriverSearch();
              cleanupRideResources();
              if (mounted) {
                // Profile profile = Provider.of<ProfileProvider>(
                //   context,
                //   listen: false,
                // ).profile!;
                Provider.of<AppInfo>(
                  context,
                  listen: false,
                ).updateActiveRideStatus(true);
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => profile.role == 'rider'
                //         ? CustomerTaxiBottomNavigation()
                //         : DriverTaxiBottomNavigation(),
                //   ),
                // );
                Navigator.pop(context);
              }
              break;
            default:
              break;
          }
        }
      },
    );

    // start searching drivers based on the current pickup (important)
    final pickup = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;

    if (pickup != null) {
      initializeNearbyDriverListener(
        centerLat: pickup.locationLatitude!,
        centerLng: pickup.locationLongitude!,
      );
      scheduleDistanceUpdate();
    } else {
      await locateUserPosition();
    }

    // start the UI searching state
    setState(() {
      showSearchingContainer = true;
      searchingForDriversContainerHeight = 280;
    });

    // fetch driver info for list
    _noDriversFound = GeofireAssistant.activeNearbyAvailableDriversList.isEmpty;

    onlineNearbyAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    showBottomDriversListModel();
  }

  Future<void> refreshDriverList() async {
    onlineNearbyAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;

    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    for (int i = 0; i < onlineNearbyAvailableDriversList.length; i++) {
      final driver = onlineNearbyAvailableDriversList[i];
      final id = driver.driverId;

      if (_shownDriverIds.contains(id)) continue;

      _shownDriverIds.add(id!);
      _driverListKey.currentState?.insertItem(
        _shownDriverIds.length - 1,
        duration: const Duration(milliseconds: 300),
      );
    }

    if (_bottomSheetSetState != null) {
      _bottomSheetSetState!(() {});
    }

    setState(() {});
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

    resetDriverSearch();
    hideSearchingForDriversContainer();
    if (!mounted) return;

    // UI feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.requestTimeout),
        content: Text(AppLocalizations.of(context)!.driverDidnotAcceptRequest),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.ok),
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
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) {
        final isDark = Provider.of<ThemeProvider>(
          ctx,
          listen: false,
        ).isDarkMode;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkAccent
                  : Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─────────────────────────────
                // Status Icon
                // ─────────────────────────────
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(
                      alpha: isDark ? 0.16 : 0.08,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(
                        alpha: isDark ? 0.22 : 0.12,
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
                  AppLocalizations.of(ctx)!.rideCancelled,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ─────────────────────────────
                // Description
                // ─────────────────────────────
                Text(
                  AppLocalizations.of(ctx)!.yourRideWasRejected,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Theme.of(
                      ctx,
                    ).colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),

                const SizedBox(height: 24),

                // ─────────────────────────────
                // Divider
                // ─────────────────────────────
                Divider(
                  height: 1,
                  color: Theme.of(
                    ctx,
                  ).colorScheme.onSurface.withValues(alpha: 0.08),
                ),

                const SizedBox(height: 18),

                // ─────────────────────────────
                // OK Button
                // ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _isRejectDialogShowing = false;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(ctx)!.ok,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isRejectDialogShowing = false;
    });
  }

  // ────────────────────────
  // Fare popup & other methods
  // ────────────────────────
  // void showFareProposalPopup(num fare) {
  //   final isDark = Provider.of<ThemeProvider>(
  //     context,
  //     listen: false,
  //   ).isDarkMode;
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     enableDrag: false,
  //     backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightLayer,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  //     ),
  //     builder: (_) {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               AppLocalizations.of(context)!.driverProposedFare,
  //               style: const TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               "₺${fare.toString()}",
  //               style: const TextStyle(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w700,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 await referenceRideRequest!.update({
  //                   "fareStatus": "accepted",
  //                 });
  //                 if (mounted) Navigator.pop(context);
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 minimumSize: const Size(double.infinity, 50),
  //                 backgroundColor: AppColors.primary,
  //               ),
  //               child: Text(
  //                 AppLocalizations.of(context)!.acceptFare,
  //                 style: const TextStyle(color: Colors.white),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             OutlinedButton(
  //               onPressed: () async {
  //                 await referenceRideRequest!.update({
  //                   "fareStatus": "rejected",
  //                 });
  //                 if (mounted) Navigator.pop(context);
  //               },
  //               style: OutlinedButton.styleFrom(
  //                 minimumSize: const Size(double.infinity, 50),
  //               ),
  //               child: Text(AppLocalizations.of(context)!.rejectFare),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void showFareProposalPopup(num fare) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent
                : Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                12,
                22,
                16 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─────────────────────────────
                    // HANDLE
                    // ─────────────────────────────
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─────────────────────────────
                    // ICON
                    // ─────────────────────────────
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lightLayer.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        size: 28,
                        color: isDark
                            ? AppColors.lightLayer
                            : AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─────────────────────────────
                    // TITLE
                    // ─────────────────────────────
                    Text(
                      AppLocalizations.of(sheetContext)!.driverProposedFare,
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                    ),

                    const SizedBox(height: 6),

                    // ─────────────────────────────
                    // DESCRIPTION
                    // ─────────────────────────────
                    Text(
                      'Please review the driver’s proposed fare.',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────────
                    // FARE CARD
                    // ─────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.lightLayer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'PROPOSED FARE',
                            style: Theme.of(sheetContext).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Theme.of(sheetContext)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.45),
                                ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '₺',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                fare.toString(),
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────────
                    // ACCEPT
                    // ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          await referenceRideRequest!.update({
                            "fareStatus": "accepted",
                          });

                          if (mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 21,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              AppLocalizations.of(sheetContext)!.acceptFare,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ─────────────────────────────
                    // REJECT
                    // ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () async {
                          await referenceRideRequest!.update({
                            "fareStatus": "rejected",
                          });

                          if (mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.tertiary,
                          side: BorderSide(
                            color: AppColors.tertiary.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.close_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(sheetContext)!.rejectFare,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> retrieveOnlineDriversInformation(
    List<ActiveNearbyAvailableDriver> onlineNearestDriverList,
  ) async {
    driversList.clear();

    for (final driver in onlineNearestDriverList) {
      final driverId = driver.driverId!;
      Profile profile;

      // ✅ Use cache if available
      if (_driverProfileCache.containsKey(driverId)) {
        profile = _driverProfileCache[driverId]!;
      } else {
        final snap = await FirebaseFirestore.instance
            .collection("profiles")
            .doc(driverId)
            .get();

        if (!snap.exists) continue;

        profile = Profile.fromFirestore(snap);
        _driverProfileCache[driverId] = profile;
      }

      driversList.add(profile);
    }

    // 🔥 IMPORTANT: notify bottom sheet
    if (_bottomSheetSetState != null) {
      _bottomSheetSetState!(() {});
    }
  }

  void clearDriverCache() {
    _driverProfileCache.clear();
  }

  bool isBottomSheetOpen = false;

  // void showBottomDriversListModel() {
  //   if (!mounted) return;

  //   hideSearchingForDriversContainer();
  //   isProgrammaticClose = false;
  //   isBottomSheetOpen = true;

  //   _shownDriverIds.clear();
  //   for (final d in driversList) {
  //     _shownDriverIds.add(d.id);
  //   }

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, modalSetState) {
  //           _bottomSheetSetState = modalSetState;
  //           return Container(
  //             height: MediaQuery.of(context).size.height * 0.6,
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).scaffoldBackgroundColor,
  //               borderRadius: const BorderRadius.vertical(
  //                 top: Radius.circular(20),
  //               ),
  //             ),
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     AppLocalizations.of(context)!.selectDriver,
  //                     style: Theme.of(context).textTheme.titleLarge,
  //                   ),
  //                 ),
  //                 driversList.isEmpty
  //                     ? SizedBox(
  //                         width: double.maxFinite,
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(16),
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 AppLocalizations.of(
  //                                   context,
  //                                 )!.noAvailableDriverNearby,
  //                                 style: Theme.of(
  //                                   context,
  //                                 ).textTheme.titleMedium,
  //                                 textAlign: TextAlign.center,
  //                               ),

  //                               if (shouldShowExpandSearchCTA) ...[
  //                                 const SizedBox(height: 16),

  //                                 Container(
  //                                   padding: const EdgeInsets.all(14),
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.orange.withValues(
  //                                       alpha: .12,
  //                                     ),
  //                                     borderRadius: BorderRadius.circular(12),
  //                                   ),
  //                                   child: Column(
  //                                     children: [
  //                                       Text(
  //                                         AppLocalizations.of(
  //                                           context,
  //                                         )!.expandSearchAreaQuestion,
  //                                         style: Theme.of(context)
  //                                             .textTheme
  //                                             .titleSmall
  //                                             ?.copyWith(
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                       ),
  //                                       const SizedBox(height: 8),
  //                                       Text(
  //                                         AppLocalizations.of(
  //                                           context,
  //                                         )!.driversMayTakeLongToArrive,
  //                                         textAlign: TextAlign.center,
  //                                       ),
  //                                       const SizedBox(height: 14),
  //                                       SizedBox(
  //                                         width: double.infinity,
  //                                         child: ElevatedButton(
  //                                           onPressed: _isExpandingSearch
  //                                               ? null
  //                                               : _onExpandSearchAccepted,
  //                                           child: _isExpandingSearch
  //                                               ? const SizedBox(
  //                                                   height: 18,
  //                                                   width: 18,
  //                                                   child:
  //                                                       CircularProgressIndicator(
  //                                                         strokeWidth: 2,
  //                                                       ),
  //                                                 )
  //                                               : Text(
  //                                                   AppLocalizations.of(
  //                                                     context,
  //                                                   )!.expandSearchArea,
  //                                                 ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ],
  //                           ),
  //                         ),
  //                       )
  //                     : Expanded(
  //                         child: AnimatedList(
  //                           key: _driverListKey,
  //                           initialItemCount: _shownDriverIds.length,
  //                           padding: const EdgeInsets.only(bottom: 12),
  //                           itemBuilder: (context, index, animation) {
  //                             final driverId = _shownDriverIds[index];

  //                             final ride = driversList.firstWhere(
  //                               (d) => d.id == driverId,
  //                             );

  //                             final driverDistance = GeofireAssistant
  //                                 .activeNearbyAvailableDriversList
  //                                 .firstWhere(
  //                                   (d) => d.driverId == ride.id,
  //                                   orElse: () => ActiveNearbyAvailableDriver(),
  //                                 );

  //                             return SizeTransition(
  //                               sizeFactor: animation,
  //                               axisAlignment: 0.0,
  //                               child: FadeTransition(
  //                                 opacity: animation,
  //                                 child: Column(
  //                                   children: [
  //                                     Padding(
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           /// LEFT SIDE (UNCHANGED UI)
  //                                           Row(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               CircleAvatar(
  //                                                 radius: 30,
  //                                                 backgroundColor:
  //                                                     AppColors.primary,
  //                                                 backgroundImage: NetworkImage(
  //                                                   ride.personal.photoUrl,
  //                                                 ),
  //                                               ),
  //                                               const SizedBox(width: 10),
  //                                               Column(
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   Text(
  //                                                     ride.username,
  //                                                     style: Theme.of(context)
  //                                                         .textTheme
  //                                                         .bodyLarge!
  //                                                         .copyWith(
  //                                                           fontWeight:
  //                                                               FontWeight.bold,
  //                                                         ),
  //                                                   ),
  //                                                   const SizedBox(height: 3),
  //                                                   if (driverDistance
  //                                                           .roadDistanceKm !=
  //                                                       null)
  //                                                     AnimatedSwitcher(
  //                                                       duration:
  //                                                           const Duration(
  //                                                             milliseconds: 400,
  //                                                           ),
  //                                                       child: Text(
  //                                                         "${driverDistance.roadDistanceKm!.toStringAsFixed(1)} km • "
  //                                                         "${driverDistance.etaMinutes!.round()} min away",
  //                                                         key: ValueKey(
  //                                                           "${driverDistance.roadDistanceKm}-${driverDistance.etaMinutes}",
  //                                                         ),
  //                                                         style: Theme.of(
  //                                                           context,
  //                                                         ).textTheme.bodySmall,
  //                                                       ),
  //                                                     )
  //                                                   else
  //                                                     Text(
  //                                                       AppLocalizations.of(
  //                                                         context,
  //                                                       )!.calculatingDistance,
  //                                                     ),
  //                                                   const SizedBox(height: 3),
  //                                                   Row(
  //                                                     children: [
  //                                                       Text(
  //                                                         ride.vehicle.model,
  //                                                       ),
  //                                                       const SizedBox(
  //                                                         width: 4,
  //                                                       ),
  //                                                       const Icon(
  //                                                         Icons.circle,
  //                                                         size: 6,
  //                                                       ),
  //                                                       const SizedBox(
  //                                                         width: 4,
  //                                                       ),
  //                                                       Text(
  //                                                         ride.vehicle.colour,
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                   const SizedBox(height: 5),
  //                                                   Row(
  //                                                     children: [
  //                                                       Container(
  //                                                         padding:
  //                                                             const EdgeInsets.symmetric(
  //                                                               vertical: 2,
  //                                                               horizontal: 4,
  //                                                             ),
  //                                                         decoration: BoxDecoration(
  //                                                           border: Border.all(
  //                                                             color: AppColors
  //                                                                 .border,
  //                                                           ),
  //                                                         ),
  //                                                         child: Text(
  //                                                           ride
  //                                                               .vehicle
  //                                                               .numberPlate,
  //                                                           style:
  //                                                               Theme.of(
  //                                                                     context,
  //                                                                   )
  //                                                                   .textTheme
  //                                                                   .bodySmall,
  //                                                         ),
  //                                                       ),
  //                                                       const SizedBox(
  //                                                         width: 5,
  //                                                       ),
  //                                                       StarRating(
  //                                                         rating: ride
  //                                                             .personal
  //                                                             .rating,
  //                                                         allowHalfRating: true,
  //                                                         color: Colors.amber,
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ],
  //                                           ),

  //                                           /// REQUEST BUTTON
  //                                           TextButton(
  //                                             onPressed: _isRequestingRide
  //                                                 ? null
  //                                                 : () async {
  //                                                     if (driverDistance
  //                                                             .roadDistanceKm ==
  //                                                         null) {
  //                                                       return;
  //                                                     }

  //                                                     setState(() {
  //                                                       _isRequestingRide =
  //                                                           true;
  //                                                     });

  //                                                     try {
  //                                                       await FirebaseDatabase
  //                                                           .instance
  //                                                           .ref(
  //                                                             "All Ride Requests/${referenceRideRequest!.key!}/driverEstimates",
  //                                                           )
  //                                                           .set({
  //                                                             "distanceKm":
  //                                                                 driverDistance
  //                                                                     .roadDistanceKm!,
  //                                                             "etaMin":
  //                                                                 driverDistance
  //                                                                     .etaMinutes,
  //                                                           });

  //                                                       await AppMethods.sendNotificationToDriverNow(
  //                                                         ride.token,
  //                                                         referenceRideRequest!
  //                                                             .key!,
  //                                                         ride.id,
  //                                                         context,
  //                                                       );

  //                                                       isProgrammaticClose =
  //                                                           true;

  //                                                       if (mounted) {
  //                                                         Navigator.pop(
  //                                                           context,
  //                                                         );
  //                                                         _startRequestTimer();
  //                                                         showSearchingForDriversContainer();
  //                                                         _isRequestingRide =
  //                                                             false;
  //                                                       }
  //                                                     } catch (e) {
  //                                                       debugPrint(
  //                                                         '❌ Failed to request driver: $e',
  //                                                       );

  //                                                       if (mounted) {
  //                                                         setState(() {
  //                                                           _isRequestingRide =
  //                                                               false;
  //                                                         });
  //                                                       }
  //                                                     }
  //                                                   },
  //                                             child: Text(
  //                                               AppLocalizations.of(
  //                                                 context,
  //                                               )!.requestRide,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     Divider(
  //                                       thickness: 0.4,
  //                                       color: AppColors.border,
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   ).whenComplete(() {
  //     isBottomSheetOpen = false;
  //     _bottomSheetSetState = null;
  //     // If user dismissed manually -> delete request
  //     if (!isProgrammaticClose) {
  //       if (referenceRideRequest != null) {
  //         referenceRideRequest!.remove();
  //         referenceRideRequest = null;
  //         resetDriverSearch();
  //         hideSearchingForDriversContainer();
  //       }
  //     }
  //   });
  // }

  void showBottomDriversListModel() {
    if (!mounted) return;

    hideSearchingForDriversContainer();

    isProgrammaticClose = false;
    isBottomSheetOpen = true;

    _shownDriverIds
      ..clear()
      ..addAll(driversList.map((d) => d.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            _bottomSheetSetState = modalSetState;

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.42,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.15,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ─────────────────────────────
                      // DRAG HANDLE
                      // ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      // ─────────────────────────────
                      // HEADER
                      // ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.lightLayer.withValues(
                                        alpha: 0.08,
                                      )
                                    : AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.directions_car_rounded,
                                color: isDark
                                    ? AppColors.lightLayer
                                    : AppColors.primary,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.selectDriver,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    driversList.isEmpty
                                        ? AppLocalizations.of(
                                            context,
                                          )!.noAvailableDriverNearby
                                        : '${driversList.length} ${driversList.length == 1 ? 'driver' : 'drivers'} nearby',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withValues(alpha: 0.65),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),

                      // ─────────────────────────────
                      // CONTENT
                      // ─────────────────────────────
                      Expanded(
                        child: driversList.isEmpty
                            ? SingleChildScrollView(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  28,
                                  20,
                                  30,
                                ),
                                child: _buildEmptyDriversState(context),
                              )
                            : AnimatedList(
                                key: _driverListKey,
                                controller: scrollController,
                                initialItemCount: _shownDriverIds.length,
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  28,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index, animation) {
                                  final driverId = _shownDriverIds[index];

                                  final ride = driversList.firstWhere(
                                    (d) => d.id == driverId,
                                  );

                                  final driverDistance = GeofireAssistant
                                      .activeNearbyAvailableDriversList
                                      .firstWhere(
                                        (d) => d.driverId == ride.id,
                                        orElse: () =>
                                            ActiveNearbyAvailableDriver(),
                                      );

                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _buildPremiumDriverCard(
                                          context: context,
                                          ride: ride,
                                          driverDistance: driverDistance,
                                        ),
                                      ),
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
        );
      },
    ).whenComplete(() {
      isBottomSheetOpen = false;
      _bottomSheetSetState = null;

      if (!isProgrammaticClose) {
        if (referenceRideRequest != null) {
          referenceRideRequest!.remove();
          referenceRideRequest = null;

          resetDriverSearch();
          hideSearchingForDriversContainer();
        }
      }
    });
  }

  Widget _buildPremiumDriverCard({
    required BuildContext context,
    required dynamic ride,
    required ActiveNearbyAvailableDriver driverDistance,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasDistance = driverDistance.roadDistanceKm != null;
    final hasEta = driverDistance.etaMinutes != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent.withValues(alpha: 0.65)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: isDark ? 0.25 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────
                // DRIVER AVATAR
                // ─────────────────────────────
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        backgroundImage: ride.personal.photoUrl.isNotEmpty
                            ? NetworkImage(ride.personal.photoUrl)
                            : null,
                        child: ride.personal.photoUrl.isEmpty
                            ? Text(
                                ride.username.isNotEmpty
                                    ? ride.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Available indicator
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 13),

                // ─────────────────────────────
                // DRIVER DETAILS
                // ─────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ride.personal.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '•',
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.45),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Available',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Distance / ETA pill
                      if (hasDistance)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Row(
                              key: ValueKey(
                                '${driverDistance.roadDistanceKm}-${driverDistance.etaMinutes}',
                              ),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.lightLayer
                                      : AppColors.primary,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '${driverDistance.roadDistanceKm!.toStringAsFixed(1)} km',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.lightLayer
                                        : AppColors.primary,
                                  ),
                                ),
                                if (hasEta) ...[
                                  const SizedBox(width: 5),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.lightLayer.withValues(
                                              alpha: 0.5,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${driverDistance.etaMinutes!.round()} min',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.lightLayer
                                              : AppColors.primary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          AppLocalizations.of(context)!.calculatingDistance,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ─────────────────────────────
            // VEHICLE INFORMATION
            // ─────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : AppColors.lightAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    size: 19,
                    color: theme.iconTheme.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      '${ride.vehicle.model} • ${ride.vehicle.colour}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Number plate
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      ride.vehicle.numberPlate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─────────────────────────────
            // REQUEST BUTTON
            // ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isRequestingRide || !hasDistance)
                    ? null
                    : () async {
                        setState(() {
                          _isRequestingRide = true;
                        });

                        try {
                          await FirebaseDatabase.instance
                              .ref(
                                "All Ride Requests/${referenceRideRequest!.key!}/driverEstimates",
                              )
                              .set({
                                "distanceKm": driverDistance.roadDistanceKm!,
                                "etaMin": driverDistance.etaMinutes,
                              });

                          await AppMethods.sendNotificationToDriverNow(
                            ride.token,
                            referenceRideRequest!.key!,
                            ride.id,
                            context,
                          );

                          isProgrammaticClose = true;

                          if (mounted) {
                            Navigator.pop(context);

                            _startRequestTimer();
                            showSearchingForDriversContainer();

                            setState(() {
                              _isRequestingRide = false;
                            });
                          }
                        } catch (e) {
                          debugPrint('❌ Failed to request driver: $e');

                          if (mounted) {
                            setState(() {
                              _isRequestingRide = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isRequestingRide
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_taxi_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.requestRide,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDriversState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_taxi_outlined,
            size: 40,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          AppLocalizations.of(context)!.noAvailableDriverNearby,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),

        // const SizedBox(height: 8),

        // Text(
        //   AppLocalizations.of(context)!.driversMayTakeLongToArrive,
        //   style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        //   textAlign: TextAlign.center,
        // ),
        if (shouldShowExpandSearchCTA) ...[
          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.radar_rounded,
                        color: Colors.orange,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.expandSearchAreaQuestion,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!.driversMayTakeLongToArrive,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isExpandingSearch
                        ? null
                        : _onExpandSearchAccepted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isExpandingSearch
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.expandSearchArea,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _onExpandSearchAccepted() async {
    // if (userCurrentPosition == null || _isExpandingSearch) return;
    final pickup = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    if (pickup == null || _isExpandingSearch) return;

    _isExpandingSearch = true;

    _expandedSearchAccepted = true;
    _currentSearchRadiusKm = _expandedRadiusKm;
    _noDriversFound = false;

    initializeNearbyDriverListener(
      // centerLat: userCurrentPosition!.latitude,
      // centerLng: userCurrentPosition!.longitude,
      centerLat: pickup.locationLatitude!,
      centerLng: pickup.locationLongitude!,
      radiusKm: _expandedRadiusKm,
    );

    await Future.delayed(const Duration(seconds: 1));

    _isExpandingSearch = false;

    await refreshDriverList();

    // Force bottom sheet rebuild
    if (_bottomSheetSetState != null) {
      _bottomSheetSetState!(() {});
    }

    setState(() {});
  }

  void resetDriverSearch() {
    _expandedSearchAccepted = false;
    _noDriversFound = false;
    _currentSearchRadiusKm = _defaultRadiusKm;
    _isExpandingSearch = false;

    GeofireAssistant.activeNearbyAvailableDriversList.clear();
    driverQuerySubscription?.cancel();
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
    clearDriverCache();
    // markersSet.clear();
    _pickupMarker = null;
    _destinationMarker = null;
    _driverMarkers.clear();
    // _rebuildMarkers();
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

  bool get selectingOrigin => isOriginSelected[0];
  // ───────────────────────────────────────────
  // Map tap handling — change pickup to tapped location
  // ───────────────────────────────────────────

  Future<void> _onMapTap(LatLng latlng) async {
    if (!mounted) return;

    setState(() => _isMapLoading = true);

    try {
      final direction = await AppMethods.getAddressFromLatLng(latlng);

      if (direction == null) return;

      if (selectingOrigin) {
        // 🟢 PICKUP MODE
        Provider.of<AppInfo>(
          context,
          listen: false,
        ).updatePickUpLocationAddress(direction);

        _addOrUpdateUserMarker(latlng);

        initializeNearbyDriverListener(
          centerLat: latlng.latitude,
          centerLng: latlng.longitude,
        );
      } else {
        // 🔴 DESTINATION MODE
        Provider.of<AppInfo>(
          context,
          listen: false,
        ).updateDropOffLocationAddress(direction);

        _addOrUpdateDestinationMarker(latlng);
      }
      final pickup = Provider.of<AppInfo>(
        context,
        listen: false,
      ).userPickUpLocation;

      final destination = Provider.of<AppInfo>(
        context,
        listen: false,
      ).userDropOffLocation;

      if (pickup != null && destination != null) {
        await drawPolyLineFromOriginToDestination(
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
        );
      }
    } catch (e) {
      debugPrint("Map tap error: $e");
    } finally {
      if (mounted) {
        setState(() => _isMapLoading = false);
      }
    }
  }

  void _addOrUpdateDestinationMarker(LatLng latlng) {
    _destinationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _rebuildMarkers();
  }

  // Widget _buildSearchOverlay() {
  //   final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

  //   return Material(
  //     color: Colors.black45, // semi-transparent overlay
  //     child: SafeArea(
  //       child: Column(
  //         children: [
  //           // Top search bar
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             margin: const EdgeInsets.symmetric(horizontal: 12),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).scaffoldBackgroundColor,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(8),
  //                 topRight: Radius.circular(8),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: _searchController,
  //                     autofocus: true,
  //                     autocorrect: false,
  //                     decoration: InputDecoration(
  //                       hintText: _isPickupSearch
  //                           ? AppLocalizations.of(context)!.searchPickupLocation
  //                           : AppLocalizations.of(
  //                               context,
  //                             )!.searchDropoffLocation,
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       prefixIcon: Icon(Icons.search),
  //                     ),
  //                     onChanged: (value) => _searchPlaces(value),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () {
  //                     setState(() {
  //                       _showSearchOverlay = false;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // Search results list
  //           Expanded(
  //             child: Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 12),
  //               decoration: BoxDecoration(
  //                 color: isDark
  //                     ? AppColors.darkAccent.withValues(alpha: 0.9)
  //                     : AppColors.lightAccent.withValues(alpha: 0.95),
  //                 borderRadius: BorderRadius.only(
  //                   bottomLeft: Radius.circular(12),
  //                   bottomRight: Radius.circular(12),
  //                 ),
  //               ),
  //               child: (_searchResults.isNotEmpty)
  //                   ? ListView.separated(
  //                       separatorBuilder: (_, _) => Divider(
  //                         height: 0,
  //                         thickness: 0.5,
  //                         color: isDark
  //                             ? AppColors.darkLayer
  //                             : AppColors.lightAccent,
  //                       ),
  //                       itemCount: _searchResults.length,
  //                       itemBuilder: (_, index) {
  //                         final place = _searchResults[index];
  //                         return ListTile(
  //                           title: Text(
  //                             place.mainText ?? '',
  //                             style: TextStyle(fontWeight: FontWeight.w500),
  //                           ),
  //                           subtitle: Text(place.secondaryText ?? ''),
  //                           onTap: () => _selectPlace(place),
  //                         );
  //                       },
  //                     )
  //                   : Center(
  //                       child: Text(
  //                         AppLocalizations.of(context)!.noResultsFound,
  //                         // "No results found",
  //                         style: TextStyle(
  //                           color: isDark ? Colors.white70 : Colors.black54,
  //                         ),
  //                       ),
  //                     ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchOverlay() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final title = _isPickupSearch
        ? AppLocalizations.of(context)!.searchPickupLocation
        : AppLocalizations.of(context)!.searchDropoffLocation;

    return Material(
      color: Colors.black.withValues(alpha: 0.48),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();

                          setState(() {
                            _showSearchOverlay = false;
                            _searchController.clear();
                            _searchResults.clear();
                          });
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),

                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          autocorrect: false,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: title,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          onChanged: _searchPlaces,
                        ),
                      ),

                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _searchResults.clear();
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkAccent.withValues(alpha: 0.97)
                        : Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _searchResults.isEmpty
                      ? _buildEmptySearchState(isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 2),
                          itemBuilder: (_, index) {
                            final place = _searchResults[index];

                            return _buildSearchResultTile(place, isDark);
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultTile(PredictedPlaces place, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectPlace(place),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.20 : 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.mainText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      place.secondaryText ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.20 : 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 30,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _searchController.text.length < 2
                  ? AppLocalizations.of(context)!.searchPickupLocation
                  : AppLocalizations.of(context)!.noResultsFound,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchPlaces(String inputText) async {
    if (inputText.length < 2) {
      setState(() => _searchResults.clear());
      return;
    }

    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$apiKey&components=country:tr|country:cy|country:ng";

    var response = await RequestAssistant.receiveRequest(url);

    if (response == 'Error fetching data. No Response') return;

    if (response['status'] == 'OK') {
      var predictions = response['predictions'] as List;
      setState(() {
        _searchResults = predictions
            .map((json) => PredictedPlaces.fromJson(json))
            .toList();
      });
    } else {
      setState(() => _searchResults.clear());
    }
  }

  Future<void> _selectPlace(PredictedPlaces place) async {
    Direction? direction = await _getPlaceDetails(place.placeId!);

    if (direction == null) return;

    if (_isPickupSearch) {
      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(direction);
      _addOrUpdateUserMarker(
        LatLng(direction.locationLatitude!, direction.locationLongitude!),
      );

      initializeNearbyDriverListener(
        centerLat: direction.locationLatitude!,
        centerLng: direction.locationLongitude!,
      );
    } else {
      Provider.of<AppInfo>(
        context,
        listen: false,
      ).updateDropOffLocationAddress(direction);
    }

    setState(() {
      _showSearchOverlay = false;
      _searchController.clear();
      _searchResults.clear();
    });

    final controller = await _controllerGoogleMap.future;

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(direction.locationLatitude!, direction.locationLongitude!),
        15,
      ),
    );

    await drawPolyLineFromOriginToDestination(
      Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
    );
  }

  Future<Direction?> _getPlaceDetails(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=geometry,name,formatted_address"
        "&key=$apiKey";

    var response = await RequestAssistant.receiveRequest(url);

    if (response == 'Error fetching data. No Response') return null;

    if (response['status'] == 'OK') {
      var result = response['result'];

      double lat = result['geometry']['location']['lat'];
      double lng = result['geometry']['location']['lng'];
      String name = result['name'];
      String address = result['formatted_address'];

      debugPrint("Address: $address");

      Direction direction = Direction();
      direction.locationLatitude = lat;
      direction.locationLongitude = lng;
      direction.locationName = name;
      direction.locationId = placeId;

      return direction;
    }

    return null;
  }

  // Widget _buildPremiumLoadingOverlay() {
  //   return AnimatedOpacity(
  //     duration: const Duration(milliseconds: 250),
  //     opacity: _isMapLoading ? 1 : 0,
  //     child: Container(
  //       color: Colors.black.withValues(alpha: .35),
  //       child: Center(
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).cardColor,
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withValues(alpha: .2),
  //                 blurRadius: 12,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               SizedBox(
  //                 height: 28,
  //                 width: 28,
  //                 child: CircularProgressIndicator(strokeWidth: 3),
  //               ),
  //               SizedBox(height: 16),
  //               Text(
  //                 AppLocalizations.of(context)!.pleaseWait,
  //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPremiumLoadingOverlay() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _isMapLoading ? 1 : 0,
          child: Container(
            color: Colors.black.withValues(alpha: 0.30),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      AppLocalizations.of(context)!.pleaseWait,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildMyLocationButton() {
  //   return FloatingActionButton(
  //     mini: true,
  //     backgroundColor: Colors.white,
  //     onPressed: _goToMyLocation,
  //     child: const Icon(Icons.my_location, color: Colors.black),
  //   );
  // }

  Widget _buildMyLocationButton() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.lightImpact();
          _goToMyLocation();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkAccent : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Icon(
            Icons.my_location_rounded,
            color: isDark ? Colors.white : AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: getLocationSetting(),
    );

    final controller = await _controllerGoogleMap.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  List<bool> isOriginSelected = [true, false];
  // ───────────────────────────────────────────
  // UI
  // ───────────────────────────────────────────
  // @override
  // Widget build(BuildContext context) {
  //   final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
  //   final isAndroid = Platform.isAndroid == true;

  //   return GestureDetector(
  //     onTap: () => FocusScope.of(context).unfocus(),
  //     child: Scaffold(
  //       key: _scaffoldState,
  //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       body: Stack(
  //         children: [
  //           Positioned.fill(
  //             child: GoogleMap(
  //               padding: EdgeInsets.only(
  //                 top: 120, // pushes myLocation button down
  //                 // bottom: bottomPaddingOfMap,
  //                 bottom: MediaQuery.of(context).padding.bottom,
  //               ),
  //               mapType: MapType.normal,
  //               myLocationEnabled: true,
  //               myLocationButtonEnabled: isAndroid ? false : true,
  //               zoomGesturesEnabled: true,
  //               zoomControlsEnabled: true,
  //               style: isDark ? _mapStyle : null,
  //               initialCameraPosition: _kGooglePlex,
  //               polylines: polylineSet,
  //               circles: circlesSet,
  //               markers: markersSet,
  //               onMapCreated: (controller) {
  //                 if (!_controllerGoogleMap.isCompleted) {
  //                   _controllerGoogleMap.complete(controller);
  //                 }
  //                 newGoogleMapController = controller;
  //                 setState(() => bottomPaddingOfMap = 200);
  //                 locateUserPosition();
  //               },
  //               onTap: (argument) async {
  //                 HapticFeedback.lightImpact();

  //                 await _onMapTap(
  //                   LatLng(argument.latitude, argument.longitude),
  //                 );
  //               },
  //             ),
  //           ),

  //           if (isAndroid)
  //             Positioned(
  //               bottom: 250,
  //               right: 16,
  //               child: _buildMyLocationButton(),
  //             ),

  //           Positioned(
  //             bottom: MediaQuery.of(context).padding.bottom + 10,
  //             left: 0,
  //             right: 0,
  //             child: Align(
  //               alignment: Alignment.bottomCenter,
  //               child: _buildToggle(),
  //             ),
  //           ),

  //           // Top UI (pickup/destination + request button) — kept your existing layout outline
  //           Positioned(
  //             left: 0,
  //             right: 0,
  //             top: 0,
  //             child: SafeArea(
  //               child: Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 20),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                         border: Border.all(color: AppColors.border),
  //                         borderRadius: BorderRadius.circular(12),
  //                         color: Theme.of(context).scaffoldBackgroundColor,
  //                       ),
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(6),
  //                               color: Theme.of(context).scaffoldBackgroundColor
  //                                   .withValues(alpha: 0.5),
  //                               // color: Colors.red,
  //                             ),
  //                             child: Column(
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.all(5),
  //                                   child: InkWell(
  //                                     // onTap: openPickupSearch,
  //                                     onTap: () {
  //                                       setState(() {
  //                                         _isPickupSearch =
  //                                             true; // true = pickup, false = destination
  //                                         _searchController.clear();
  //                                         _searchResults.clear();
  //                                         _showSearchOverlay = true;
  //                                       });
  //                                     },

  //                                     child: Row(
  //                                       children: [
  //                                         Iconify(
  //                                           Ic.my_location,
  //                                           color: isDark
  //                                               ? AppColors.darkLayer
  //                                               : AppColors.primary,
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         Expanded(
  //                                           child: Column(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               Text(
  //                                                 AppLocalizations.of(
  //                                                   context,
  //                                                 )!.from,
  //                                                 style: TextStyle(
  //                                                   fontWeight: FontWeight.w500,
  //                                                   color: isDark
  //                                                       ? AppColors.darkLayer
  //                                                       : AppColors.primary,
  //                                                 ),
  //                                               ),
  //                                               Text(
  //                                                 Provider.of<AppInfo>(
  //                                                           context,
  //                                                         ).userPickUpLocation !=
  //                                                         null
  //                                                     ? (Provider.of<AppInfo>(
  //                                                             context,
  //                                                           )
  //                                                           .userPickUpLocation!
  //                                                           .locationName!)
  //                                                     : AppLocalizations.of(
  //                                                         context,
  //                                                       )!.unknownAddress,
  //                                                 overflow:
  //                                                     TextOverflow.ellipsis,
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 5),
  //                                 Divider(
  //                                   height: 1,
  //                                   thickness: 1,
  //                                   color: isDark
  //                                       ? AppColors.darkLayer
  //                                       : AppColors.primary,
  //                                 ),
  //                                 SizedBox(height: 5),
  //                                 Padding(
  //                                   padding: const EdgeInsets.all(5),
  //                                   child: InkWell(
  //                                     onTap: () {
  //                                       setState(() {
  //                                         _isPickupSearch = false;
  //                                         _searchController.clear();
  //                                         _searchResults.clear();
  //                                         _showSearchOverlay = true;
  //                                       });
  //                                     },

  //                                     child: Row(
  //                                       children: [
  //                                         Iconify(
  //                                           Ic.location_on,
  //                                           color: isDark
  //                                               ? AppColors.darkLayer
  //                                               : AppColors.primary,
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         Expanded(
  //                                           child: Column(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               Text(
  //                                                 AppLocalizations.of(
  //                                                   context,
  //                                                 )!.to,
  //                                                 style: TextStyle(
  //                                                   fontWeight: FontWeight.w500,
  //                                                   color: isDark
  //                                                       ? AppColors.darkLayer
  //                                                       : AppColors.primary,
  //                                                 ),
  //                                               ),
  //                                               Text(
  //                                                 Provider.of<AppInfo>(
  //                                                           context,
  //                                                         ).userDropOffLocation !=
  //                                                         null
  //                                                     ? (Provider.of<AppInfo>(
  //                                                             context,
  //                                                           )
  //                                                           .userDropOffLocation!
  //                                                           .locationName!)
  //                                                     : AppLocalizations.of(
  //                                                         context,
  //                                                       )!.enterDestination,
  //                                                 overflow:
  //                                                     TextOverflow.ellipsis,
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(height: 5),
  //                           ElevatedButton(
  //                             onPressed: () {
  //                               if (Provider.of<AppInfo>(
  //                                         context,
  //                                         listen: false,
  //                                       ).userDropOffLocation !=
  //                                       null &&
  //                                   Provider.of<AppInfo>(
  //                                         context,
  //                                         listen: false,
  //                                       ).userPickUpLocation !=
  //                                       null) {
  //                                 saveRideRequestInformation();
  //                               } else {
  //                                 final snackBarPickup = SnackBar(
  //                                   content: Text(
  //                                     AppLocalizations.of(
  //                                       context,
  //                                     )!.pleaseEnterPickupAddress,
  //                                   ),
  //                                   duration: const Duration(seconds: 3),
  //                                 );
  //                                 final snackBarDestination = SnackBar(
  //                                   content: Text(
  //                                     AppLocalizations.of(
  //                                       context,
  //                                     )!.pleaseEnterDestination,
  //                                   ),
  //                                   duration: const Duration(seconds: 3),
  //                                 );

  //                                 if (Provider.of<AppInfo>(
  //                                       context,
  //                                       listen: false,
  //                                     ).userPickUpLocation ==
  //                                     null) {
  //                                   ScaffoldMessenger.of(
  //                                     context,
  //                                   ).showSnackBar(snackBarPickup);
  //                                 } else if (Provider.of<AppInfo>(
  //                                       context,
  //                                       listen: false,
  //                                     ).userDropOffLocation ==
  //                                     null) {
  //                                   ScaffoldMessenger.of(
  //                                     context,
  //                                   ).showSnackBar(snackBarDestination);
  //                                 }
  //                               }
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: isDark
  //                                   ? AppColors.darkLayer
  //                                   : AppColors.primary,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                   4.0,
  //                                 ), // Adjust the radius as needed
  //                               ),
  //                             ),
  //                             child: Text(
  //                               AppLocalizations.of(context)!.requestARide,
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           if (_showSearchOverlay)
  //             Positioned.fill(child: _buildSearchOverlay()),

  //           // Searching container (bottom)
  //           Positioned(
  //             bottom: 0,
  //             left: 0,
  //             right: 0,
  //             child: AnimatedContainer(
  //               clipBehavior: Clip.hardEdge,
  //               duration: const Duration(milliseconds: 400),
  //               curve: Curves.easeInOut,
  //               height: searchingForDriversContainerHeight,
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
  //                 borderRadius: const BorderRadius.vertical(
  //                   top: Radius.circular(16),
  //                 ),
  //                 boxShadow: const [
  //                   BoxShadow(
  //                     color: Colors.black26,
  //                     blurRadius: 6,
  //                     offset: Offset(0, -2),
  //                   ),
  //                 ],
  //               ),
  //               child: AnimatedOpacity(
  //                 duration: const Duration(milliseconds: 300),
  //                 opacity: showSearchingContainer ? 1.0 : 0.0,
  //                 child: SingleChildScrollView(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(12),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         const SizedBox(height: 12),
  //                         SizedBox(
  //                           width: 120,
  //                           height: 120,
  //                           child: Stack(
  //                             fit: StackFit.expand,
  //                             children: [
  //                               CircularProgressIndicator(
  //                                 value:
  //                                     _remainingSeconds /
  //                                     _requestTimeoutSeconds,
  //                                 strokeWidth: 8,
  //                                 valueColor: AlwaysStoppedAnimation(
  //                                   isDark
  //                                       ? AppColors.darkLayer
  //                                       : AppColors.lightLayer,
  //                                 ),
  //                                 backgroundColor: AppColors.tertiary,
  //                               ),
  //                               Center(
  //                                 child: Text(
  //                                   _remainingSecondsText,
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 24,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         const SizedBox(height: 12),
  //                         Text(
  //                           AppLocalizations.of(context)!.waitingForDriver,
  //                           style: Theme.of(context).textTheme.titleMedium,
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         //
  //                         // const LinearProgressIndicator(),
  //                         const SizedBox(height: 16),
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             hideSearchingForDriversContainer();
  //                             _requestTimer?.cancel();
  //                             if (referenceRideRequest != null) {
  //                               referenceRideRequest!.remove();
  //                               referenceRideRequest = null;
  //                               Provider.of<AppInfo>(
  //                                 context,
  //                                 listen: false,
  //                               ).setActiveRideId('');
  //                             }
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: AppColors.tertiary,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: Text(
  //                             AppLocalizations.of(context)!.cancel,
  //                             style: const TextStyle(color: Colors.white),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           if (_isMapLoading) _buildPremiumLoadingOverlay(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildToggle() {
  //   bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
  //   final isPickup = isOriginSelected[0];
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       AnimatedSwitcher(
  //         duration: const Duration(milliseconds: 500),
  //         child: Text(
  //           isPickup
  //               ? AppLocalizations.of(context)!.tapMapToSetPickupLocation
  //               : AppLocalizations.of(context)!.tapMapToSetDestination,
  //           key: ValueKey(isPickup),
  //           style: Theme.of(context).textTheme.bodySmall!.copyWith(
  //             // color: AppColors.tertiary,
  //             // color: Colors.grey.shade700,
  //             color: isDark ? Colors.white : Colors.black54,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Container(
  //         padding: const EdgeInsets.all(6),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(40),
  //           boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
  //         ),
  //         child: ToggleButtons(
  //           isSelected: isOriginSelected,
  //           onPressed: (int index) {
  //             HapticFeedback.selectionClick();
  //             setState(() {
  //               for (int i = 0; i < isOriginSelected.length; i++) {
  //                 isOriginSelected[i] = i == index;
  //               }
  //             });
  //           },
  //           borderRadius: BorderRadius.circular(30),
  //           borderWidth: 0,
  //           selectedColor: AppColors.lightAccent,
  //           fillColor: AppColors.primary,
  //           color: AppColors.border,
  //           children: const [
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 20),
  //               child: Icon(Icons.trip_origin),
  //               // child: Iconify(Ic.my_location),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 20),
  //               child: Icon(Icons.location_on),
  //               // child: Iconify(Ic.location_on),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // List<bool> isOriginSelected = [true, false];

  // bool get selectingOrigin => isOriginSelected[0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final appInfo = Provider.of<AppInfo>(context);

    final pickup = appInfo.userPickUpLocation;
    final destination = appInfo.userDropOffLocation;

    final hasPickup = pickup != null;
    final hasDestination = destination != null;
    final canRequestRide = hasPickup && hasDestination;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldState,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // ─────────────────────────────────────
            // MAP
            // ─────────────────────────────────────
            Positioned.fill(
              child: GoogleMap(
                padding: EdgeInsets.only(
                  top: 150,
                  bottom: MediaQuery.of(context).padding.bottom + 150,
                ),
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: Platform.isAndroid ? false : true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: false,
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

                  if (mounted) {
                    setState(() {
                      bottomPaddingOfMap = 200;
                    });
                  }

                  locateUserPosition();
                },
                onTap: (argument) async {
                  HapticFeedback.lightImpact();

                  await _onMapTap(
                    LatLng(argument.latitude, argument.longitude),
                  );
                },
              ),
            ),

            // ─────────────────────────────────────
            // TOP LOCATION CARD
            // ─────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: _buildPremiumLocationCard(
                    context: context,
                    isDark: isDark,
                    pickup: pickup,
                    destination: destination,
                    canRequestRide: canRequestRide,
                  ),
                ),
              ),
            ),

            // ─────────────────────────────────────
            // MY LOCATION BUTTON
            // ─────────────────────────────────────
            if (Platform.isAndroid)
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 145,
                child: _buildMyLocationButton(),
              ),

            // ─────────────────────────────────────
            // MAP LOCATION SELECTOR
            // ─────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: _buildToggle(),
            ),

            // ─────────────────────────────────────
            // SEARCH OVERLAY
            // ─────────────────────────────────────
            if (_showSearchOverlay)
              Positioned.fill(child: _buildSearchOverlay()),

            // ─────────────────────────────────────
            // SEARCHING FOR DRIVER
            // ─────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSearchingContainer(isDark),
            ),

            // ─────────────────────────────────────
            // MAP LOADING
            // ─────────────────────────────────────
            if (_isMapLoading) _buildPremiumLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLocationCard({
    required BuildContext context,
    required bool isDark,
    required Direction? pickup,
    required Direction? destination,
    required bool canRequestRide,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: isDark ? 0.96 : 0.97,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.22 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_taxi_rounded,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.requestARide,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (canRequestRide)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ready',
                          // AppLocalizations.of(context)!.ready,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Locations
            _buildPremiumLocationField(
              context: context,
              isDark: isDark,
              isPickup: true,
              direction: pickup,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 21, top: 2, bottom: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 1.5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkLayer : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            _buildPremiumLocationField(
              context: context,
              isDark: isDark,
              isPickup: false,
              direction: destination,
            ),

            const SizedBox(height: 14),

            // Request button
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: canRequestRide
                      ? () {
                          HapticFeedback.mediumImpact();
                          saveRideRequestInformation();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: canRequestRide ? 4 : 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    disabledForegroundColor: isDark
                        ? Colors.white38
                        : Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canRequestRide
                            ? Icons.local_taxi_rounded
                            : Icons.location_searching_rounded,
                        size: 21,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        AppLocalizations.of(context)!.requestARide,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLocationField({
    required BuildContext context,
    required bool isDark,
    required bool isPickup,
    required Direction? direction,
  }) {
    final theme = Theme.of(context);

    final hasLocation = direction != null;

    final title = isPickup
        ? AppLocalizations.of(context)!.from
        : AppLocalizations.of(context)!.to;

    final locationText = hasLocation
        ? direction.locationName ?? ''
        : isPickup
        ? AppLocalizations.of(context)!.unknownAddress
        : AppLocalizations.of(context)!.enterDestination;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();

          setState(() {
            _isPickupSearch = isPickup;
            _searchController.clear();
            _searchResults.clear();
            _showSearchOverlay = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isPickup
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPickup
                      ? Icons.my_location_rounded
                      : Icons.location_on_rounded,
                  color: isPickup ? Colors.green.shade600 : Colors.red.shade600,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isPickup
                            ? (isDark
                                  ? Colors.greenAccent.shade100
                                  : Colors.green.shade700)
                            : (isDark
                                  ? Colors.redAccent.shade100
                                  : Colors.red.shade700),
                      ),
                    ),

                    const SizedBox(height: 3),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        locationText,
                        key: ValueKey(locationText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: hasLocation
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: hasLocation
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isPickup = isOriginSelected[0];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Container(
            key: ValueKey(isPickup),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkAccent.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPickup ? Icons.touch_app_rounded : Icons.touch_app_rounded,
                  size: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  isPickup
                      ? AppLocalizations.of(context)!.tapMapToSetPickupLocation
                      : AppLocalizations.of(context)!.tapMapToSetDestination,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent.withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapModeButton(
                selected: isPickup,
                icon: Icons.trip_origin_rounded,
                label: AppLocalizations.of(context)!.from,
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    isOriginSelected = [true, false];
                  });
                },
              ),
              const SizedBox(width: 4),
              _buildMapModeButton(
                selected: !isPickup,
                icon: Icons.location_on_rounded,
                label: AppLocalizations.of(context)!.to,
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    isOriginSelected = [false, true];
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapModeButton({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSearchingContainer(bool isDark) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 400),
  //     curve: Curves.easeOutCubic,
  //     height: searchingForDriversContainerHeight,
  //     width: double.infinity,
  //     clipBehavior: Clip.hardEdge,
  //     decoration: BoxDecoration(
  //       color: isDark
  //           ? AppColors.darkAccent
  //           : Theme.of(context).scaffoldBackgroundColor,
  //       borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.20),
  //           blurRadius: 24,
  //           offset: const Offset(0, -8),
  //         ),
  //       ],
  //     ),
  //     child: AnimatedOpacity(
  //       duration: const Duration(milliseconds: 250),
  //       opacity: showSearchingContainer ? 1 : 0,
  //       child: SafeArea(
  //         top: false,
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               // Handle
  //               Container(
  //                 width: 42,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: isDark ? Colors.white24 : Colors.black12,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),

  //               const SizedBox(height: 14),

  //               // Searching indicator
  //               SizedBox(
  //                 width: 92,
  //                 height: 92,
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   children: [
  //                     CircularProgressIndicator(
  //                       value: _remainingSeconds / _requestTimeoutSeconds,
  //                       strokeWidth: 7,
  //                       backgroundColor: isDark
  //                           ? Colors.white10
  //                           : AppColors.lightLayer,
  //                       valueColor: AlwaysStoppedAnimation<Color>(
  //                         AppColors.tertiary,
  //                       ),
  //                     ),
  //                     Container(
  //                       width: 68,
  //                       height: 68,
  //                       decoration: BoxDecoration(
  //                         color: AppColors.primary.withValues(
  //                           alpha: isDark ? 0.25 : 0.08,
  //                         ),
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           _remainingSecondsText,
  //                           style: const TextStyle(
  //                             fontSize: 19,
  //                             fontWeight: FontWeight.w800,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               const SizedBox(height: 12),

  //               Text(
  //                 AppLocalizations.of(context)!.waitingForDriver,
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.w800,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),

  //               // const SizedBox(height: 5),

  //               // Text(
  //               //   AppLocalizations.of(context)!.waitingForDriver,
  //               //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //               //     color: Theme.of(
  //               //       context,
  //               //     ).colorScheme.onSurface.withValues(alpha: 0.55),
  //               //   ),
  //               //   textAlign: TextAlign.center,
  //               // ),
  //               const SizedBox(height: 16),

  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: OutlinedButton(
  //                   onPressed: () {
  //                     HapticFeedback.mediumImpact();

  //                     hideSearchingForDriversContainer();
  //                     _requestTimer?.cancel();

  //                     if (referenceRideRequest != null) {
  //                       referenceRideRequest!.remove();
  //                       referenceRideRequest = null;

  //                       Provider.of<AppInfo>(
  //                         context,
  //                         listen: false,
  //                       ).setActiveRideId('');
  //                     }
  //                   },
  //                   style: OutlinedButton.styleFrom(
  //                     foregroundColor: AppColors.tertiary,
  //                     side: BorderSide(
  //                       color: AppColors.tertiary.withValues(alpha: 0.7),
  //                     ),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(14),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     AppLocalizations.of(context)!.cancel,
  //                     style: const TextStyle(fontWeight: FontWeight.w700),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchingContainer(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: searchingForDriversContainerHeight,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: showSearchingContainer ? 1 : 0,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─────────────────────────────
                  // Handle
                  // ─────────────────────────────
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─────────────────────────────
                  // Searching indicator
                  // ─────────────────────────────
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring — OUTSIDE the time circle
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: CircularProgressIndicator(
                            value: _requestTimeoutSeconds > 0
                                ? (_remainingSeconds / _requestTimeoutSeconds)
                                      .clamp(0.0, 1.0)
                                : 0,
                            strokeWidth: 7,
                            // backgroundColor: isDark
                            //     ? Colors.white10
                            //     : AppColors.lightLayer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.tertiary,
                            ),
                          ),
                        ),

                        // Time container — smaller, sitting INSIDE the ring
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkAccent
                                : Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _remainingSecondsText,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─────────────────────────────
                  // Waiting text
                  // ─────────────────────────────
                  Text(
                    AppLocalizations.of(context)!.waitingForDriver,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // ─────────────────────────────
                  // Cancel button
                  // ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();

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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tertiary,
                        side: BorderSide(
                          color: AppColors.tertiary.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
