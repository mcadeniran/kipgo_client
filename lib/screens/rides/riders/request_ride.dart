import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/screens/homes/customer_home.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/active_nearby_available_driver.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rides/riders/precise_pickup_location.dart';
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

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.133428350758344, 33.923606022529256),
    zoom: 14.4746,
  );

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRideContainerHeight = 0;
  double searchingForDriversContainerHeight = 0;
  bool showSearchingContainer = false; // control visibility

  Position? userCurrentPosition;
  // var geoLocation = Geolocator;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String username = "";
  String userEmail = "";
  String userRideRequestStatus = '';

  bool showDriverListsModel = false;

  // String? _address;
  bool activateNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = 'Driver is coming';
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  List<ActiveNearbyAvailableDriver> onlineNearbyAvailableDriversList = [];

  bool requestPositionInfo = true;

  String? _mapStyle;

  late LocationSettings locationSettings;

  Future<void> locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
      locationSettings: getLocationSetting(),
    );

    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    if (!mounted) return;
    String humanReadableAddress =
        await AppMethods.searchAddressFromGeographicalCoordinates(
          userCurrentPosition!,
          context,
        );

    debugPrint("Address: $humanReadableAddress");

    if (!mounted) return;
    driverRideStatus = AppLocalizations.of(context)!.driverIsComing;
    username = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.username;

    initializeNearbyDriverListener();
  }

  StreamSubscription<dynamic>? _geoQuerySubscription;

  void initializeNearbyDriverListener() {
    final geo = GeoFlutterFire();
    final driversCollection = FirebaseFirestore.instance.collection(
      'activeDrivers',
    );

    final center = geo.point(
      latitude: userCurrentPosition!.latitude,
      longitude: userCurrentPosition!.longitude,
    );

    // 🔍 Query drivers within 5km
    driverQuerySubscription = geo
        .collection(collectionRef: driversCollection)
        .within(center: center, radius: 5, field: 'position')
        .listen((List<DocumentSnapshot> documentList) {
          GeofireAssistant.activeNearbyAvailableDriversList.clear();

          for (var doc in documentList) {
            final data = doc.data() as Map<String, dynamic>?;

            if (data == null || data['position'] == null) continue;

            final GeoPoint point = data['position']['geopoint'];

            ActiveNearbyAvailableDriver driver = ActiveNearbyAvailableDriver();
            driver.driverId = doc.id;
            driver.locationLatitude = point.latitude;
            driver.locationLongitude = point.longitude;

            GeofireAssistant.activeNearbyAvailableDriversList.add(driver);
          }

          displayActiveDriversOnUserMap();
        });
  }

  void displayActiveDriversOnUserMap() {
    if (!mounted) return; // ✅ Prevent setState after dispose
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = <Marker>{};

      for (ActiveNearbyAvailableDriver eachDriver
          in GeofireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(
          eachDriver.locationLatitude!,
          eachDriver.locationLongitude!,
        );

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      markersSet = driversMarkerSet;
    });
  }

  void createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(30, 30),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/car.png',
      ).then((value) => activeNearbyIcon = value);
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool isDark) async {
    var originPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(
      context,
      listen: false,
    ).userDropOffLocation;

    if (destinationPosition == null) {
      return;
    }

    var originLatLng = LatLng(
      originPosition!.locationLatitude!,
      originPosition.locationLongitude!,
    );

    var destinationLatLng = LatLng(
      destinationPosition.locationLatitude!,
      destinationPosition.locationLongitude!,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
    );

    var directionDetailsInfo =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    if (!mounted) return;

    Navigator.pop(context);

    if (directionDetailsInfo == null) return;

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList = pPoints.decodePolyline(
      directionDetailsInfo.ePoints!,
    );

    pLineCoordinateList.clear();

    if (decodePolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointsResultList) {
        pLineCoordinateList.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: pLineCoordinateList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if (originLatLng.longitude > destinationLatLng.longitude &&
        originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }

    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: MarkerId('originId'),
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: AppLocalizations.of(context)!.from,
      ),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destinationId'),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: AppLocalizations.of(context)!.to,
      ),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId('originId'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destinationId'),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  void checkIfLocationPermissionAllowed() async {
    await Geolocator.requestPermission();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  Future<void> saveRideRequestInformation() async {
    // Create new ride request in DB
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
    };

    await referenceRideRequest!.set(userInformationMap);

    Provider.of<AppInfo>(context, listen: false).setActiveRideId(rideId);

    // Listen for updates
    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue
        .listen((eventSnap) async {
          if (eventSnap.snapshot.value == null) return;

          final data = Map<String, dynamic>.from(
            eventSnap.snapshot.value as Map,
          );

          // Update driver info fields dynamically
          setState(() {
            driverCarModel = data['model'] ?? driverCarModel;
            driverCarColour = data['colour'] ?? driverCarColour;
            driverNumberPlate = data['numberPlate'] ?? driverNumberPlate;
            driverPhone = data['driverPhone'] ?? driverPhone;
            driverName = data['driverName'] ?? driverName;
            driverPhotoUrl = data['driverPhotoUrl'] ?? driverPhotoUrl;
            userRideRequestStatus = data['status'] ?? userRideRequestStatus;
          });

          // ✅ Handle rejection (even if driverLocation is null)
          if (userRideRequestStatus == 'rejected') {
            setState(() {
              assignedDriverInfoContainerHeight = 0;
              userRideRequestStatus = '';
            });
            // showBottomDriversListModel();
            hideSearchingForDriversContainer();
            if (referenceRideRequest != null) {
              referenceRideRequest!.remove();
              referenceRideRequest = null;
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
              // Optionally re-open driver list modal
              // showDriverListsModel = true;
              // showBottomDriversListModel();
            }
            return; // stop here since rejected
          }

          // Handle driver location updates
          if (data['driverLocation'] != null) {
            switch (userRideRequestStatus) {
              case 'accepted':
                cleanupRideResources(); // Stop listeners and free resources

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
                      builder: (_) => profile.role == 'rider'
                          ? CustomerHome()
                          : DriverHome(),
                    ),
                    (route) => false, // Removes all previous routes
                  );
                }
                break;
              default:
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //       AppLocalizations.of(context)!.noAvailableDriverNearby,
                //     ),
                //     duration: const Duration(seconds: 3),
                //   ),
                // );
                break;
            }
          }
        });

    // Start searching for drivers
    onlineNearbyAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  void showSearchingForDriversContainer() {
    setState(() {
      showSearchingContainer = true;
      searchingForDriversContainerHeight = 150;
    });
  }

  void hideSearchingForDriversContainer() {
    setState(() {
      showSearchingContainer = false;
      searchingForDriversContainerHeight = 0;
    });
  }

  Future<void> searchNearestOnlineDrivers() async {
    if (onlineNearbyAvailableDriversList.isEmpty) {
      // Cancel/Delete the ride request information
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoordinateList.clear();
      });
      final noDriverSnackbar = SnackBar(
        content: Text(AppLocalizations.of(context)!.noAvailableDriverNearby),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(noDriverSnackbar);

      return;
    }

    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    setState(() {
      showDriverListsModel = true;
    });

    showBottomDriversListModel();

    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(referenceRideRequest!.key!)
        .child('driverId')
        .onValue
        .listen((eventRideRequestSnapshot) {
          if (eventRideRequestSnapshot.snapshot.value != null) {
            if (eventRideRequestSnapshot.snapshot.value != 'waiting') {
              // showUIForAssignedDriverInfo();
            }
          }
        });
  }

  Future<void> retrieveOnlineDriversInformation(
    List onlineNearestDriverList,
  ) async {
    driversList.clear();

    for (int i = 0; i < onlineNearestDriverList.length; i++) {
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(onlineNearestDriverList[i].driverId)
          .get()
          .then((dataSnapshot) {
            driversList.add(Profile.fromFirestore(dataSnapshot));
          });
    }
  }

  void showBottomDriversListModel() {
    if (showDriverListsModel == true) {
      Future.microtask(() {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
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
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          Divider(thickness: 0.4, color: AppColors.border),
                      itemCount: driversList.length,
                      itemBuilder: (context, index) {
                        final ride = driversList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Row(
                                        children: [
                                          Text(ride.vehicle.model),
                                          // Text("${ride['model']}"),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.circle, size: 6),
                                          const SizedBox(width: 4),
                                          Text(ride.vehicle.colour),
                                          // Text("${ride['colour']}"),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                                  // MIGHT REMOVE
                                  showBottomDriversListModel();
                                  showSearchingForDriversContainer();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.requestRide,
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
      });
    } else {
      // Close if it's already open
      Navigator.pop(context);
      if (Navigator.canPop(context)) {}
    }
  }

  @override
  void initState() {
    super.initState();
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (isDark) {
      _loadMapStyle();
    }

    checkIfLocationPermissionAllowed();
    createActiveNearbyDriverIconMarker();
  }

  void cleanupRideResources() async {
    // Cancel ride request subscription
    tripRideRequestInfoStreamSubscription?.cancel();
    // tripRideRequestInfoStreamSubscription = null;

    await driverQuerySubscription?.cancel();
    driverQuerySubscription = null;

    // Cancel GeoFire subscription
    await _geoQuerySubscription?.cancel();
    // _geoQuerySubscription = null;
    // Clean up Firebase ride request reference
    referenceRideRequest?.onDisconnect();
    // referenceRideRequest = null;

    // Dispose Google Maps controller
    newGoogleMapController?.dispose();
    // newGoogleMapController = null;

    // Reset temporary data (optional, keeps things tidy)
    markersSet.clear();
    circlesSet.clear();
    polylineSet.clear();
    pLineCoordinateList.clear();
    userRideRequestStatus = '';
    // driverRideStatus = AppLocalizations.of(context)!.driverIsComing;
  }

  @override
  void dispose() {
    cleanupRideResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              style: isDark ? _mapStyle : null,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              circles: circlesSet,
              markers: markersSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 200;
                });
                locateUserPosition();
              },
            ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) =>
                                          PrecisePickupLocationScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.tertiary
                                      : AppColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      4.0,
                                    ), // Adjust the radius as needed
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.changePickup,
                                  style: TextStyle(
                                    // color: isDark ? Colors.white : Colors.black,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Requesting a ride
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: AnimatedContainer(
            //     clipBehavior: Clip.hardEdge,
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.easeInOut,
            //     height: searchingForDriversContainerHeight,
            //     width: double.infinity,
            //     color: isDark ? AppColors.darkAccent : Colors.grey[50],
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       // mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text(
            //           AppLocalizations.of(context)!.waitingForDriver,
            //           style: Theme.of(context).textTheme.bodyLarge,
            //         ),
            //         const SizedBox(height: 12),
            //         const LinearProgressIndicator(),
            //         const SizedBox(height: 10),
            //         ElevatedButton(
            //           onPressed: () {
            //             // Cancel ride searching
            //             hideSearchingForDriversContainer();
            //             // setState(() {
            //             //   showDriverListsModel = true;
            //             // });
            //             // showBottomDriversListModel();

            //             // Optional: cancel the ride request in DB if you want
            //             if (referenceRideRequest != null) {
            //               referenceRideRequest!.remove();
            //               referenceRideRequest = null;
            //             }
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.redAccent,
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //           ),
            //           child: Text(
            //             AppLocalizations.of(context)!.cancel,
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
                  color: isDark ? AppColors.darkAccent : Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showSearchingContainer ? 1.0 : 0.0, // ✅ fade in/out
                  curve: Curves.easeInOut,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.waitingForDriver,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              hideSearchingForDriversContainer();

                              // Optional: cancel the ride request in DB if needed
                              if (referenceRideRequest != null) {
                                referenceRideRequest!.remove();
                                referenceRideRequest = null;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
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
