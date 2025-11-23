import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/widgets/ride_location_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
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

class _NewTripScreenState extends State<NewTripScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newTripGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.133428350758344, 33.923606022529256),
    zoom: 14.4746,
  );

  late String buttonTitle;

  Set<Marker> markersSet = <Marker>{};
  Set<Circle> circlesSet = <Circle>{};
  Set<Polyline> polylinesSet = <Polyline>{};
  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimateMarker;
  Geolocator geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = 'accepted';

  String durationFromOriginToDestination = '';

  String? _mapStyle;

  bool isRequestDirectionDetails = false;

  DatabaseReference? rideStatusRef;
  StreamSubscription<DatabaseEvent>? rideStatusSubscription;

  // Step 1:When driver accepts user's request
  // Origin addres is the driver's current address and destination address is the passanger's pickup address
  //
  // Step 2: When driver reaches the user's location
  // Origin location is user's current location and destination location is the dropoff location

  Future<void> drawPolylineFromOriginToDestination(
    LatLng originLatLng,
    LatLng destinationLatLng,
    bool isDark,
  ) async {
    showDialog(
      context: context,
      builder: ((BuildContext context) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait)),
    );

    var directionDetailsInfo =
        await AppMethods.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    if (!mounted) return;

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(
      directionDetailsInfo!.ePoints!,
    );

    polylinePositionCoordinates.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResultList) {
        polylinePositionCoordinates.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    polylinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: AppColors.tertiary,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylinesSet.add(polyline);
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

    newTripGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 65),
    );

    Marker originMarker = Marker(
      markerId: MarkerId('originId'),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destinationId'),
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

  void createDriverIconMarker() {
    if (iconAnimateMarker == null) {
      ImageConfiguration imageConfiguration = ImageConfiguration(
        size: Size(24, 24),
      );

      BitmapDescriptor.asset(
        imageConfiguration,
        'assets/images/car.png',
      ).then((value) => iconAnimateMarker = value);
    }
  }

  void saveAssignedDriverDetailsToUserRideRequest() {
    Profile onlineDriverData = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child('driverId') != 'waiting') {
      databaseReference.child('driverLocation').set(driverLocationDataMap);

      databaseReference.child('status').set('accepted');
      databaseReference.child('driverId').set(onlineDriverData.id);
      databaseReference.child('driverName').set(onlineDriverData.username);
      databaseReference
          .child('driverPhone')
          .set(onlineDriverData.personal.phone);
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
          .set(widget.userRideRequestDetails!.rideRequestId!);
      // saveRideRequestIdToDriverHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.thisRideHasBeenAccepted),
        ),
      );
      Navigator.pop(context);
    }
  }

  void getDriverLocationUpdatesAtRealTime() {
    // LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
        .listen((Position position) {
          driverCurrentPosition = position;
          onlineDriverCurrentPosition = position;

          LatLng latLngLiveDriverPosition = LatLng(
            onlineDriverCurrentPosition!.latitude,
            onlineDriverCurrentPosition!.longitude,
          );

          Marker animatingMarker = Marker(
            markerId: MarkerId('AnimatedMarker'),
            position: latLngLiveDriverPosition,
            icon: iconAnimateMarker!,
            infoWindow: InfoWindow(title: 'Your current position'),
          );

          setState(() {
            CameraPosition cameraPosition = CameraPosition(
              target: latLngLiveDriverPosition,
              zoom: 18,
            );
            newTripGoogleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(cameraPosition),
            );

            markersSet.removeWhere(
              (element) => element.markerId.value == 'AnimatedMarker',
            );
            markersSet.add(animatingMarker);
          });

          // oldLatLng = latLngLiveDriverPosition;

          updateDurationInRealTime();

          // Updating driver location in real time in database
          Map driverLatLngMap = {
            'latitude': onlineDriverCurrentPosition!.latitude.toString(),
            'longitude': onlineDriverCurrentPosition!.longitude.toString(),
          };

          FirebaseDatabase.instance
              .ref()
              .child('All Ride Requests')
              .child(widget.userRideRequestDetails!.rideRequestId!)
              .child('driverLocation')
              .set(driverLatLngMap);
        });
  }

  Future<void> updateDurationInRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      LatLng originLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      LatLng destinationLatLng;

      if (rideRequestStatus == 'accepted') {
        destinationLatLng = widget.userRideRequestDetails!.originLatLng!;
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;
      }

      var directionInformation =
          await AppMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng,
            destinationLatLng,
          );

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.durationText!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  Future<void> endTripNow() async {
    showDialog(
      context: context,
      builder: ((BuildContext context) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait)),
    );

    cleanupResources();

    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child('status')
        .set('ended');

    String driverId = Provider.of<ProfileProvider>(
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
      MaterialPageRoute(builder: (c) => const DriverHome()),
      (route) => false,
    );
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  void cleanupResources() {
    streamSubscriptionDriverLivePosition?.cancel();
    newTripGoogleMapController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    createDriverIconMarker();
    buttonTitle = 'Arrived';
    // Get driver's initial location safely
    Geolocator.getCurrentPosition(
      // desiredAccuracy: LocationAccuracy.high,
      locationSettings: getLocationSetting(),
    ).then((position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      setState(() {}); // trigger rebuild once we have location
    });

    // Save ride details
    saveAssignedDriverDetailsToUserRideRequest();

    // ✅ Listen for ride cancellation in real-time
    rideStatusRef = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child('status');

    rideStatusSubscription = rideStatusRef!.onValue.listen((event) async {
      final status = event.snapshot.value?.toString();

      if (status == 'cancelled') {
        // Stop location and cleanup
        cleanupResources();
        rideStatusSubscription?.cancel();

        if (!mounted) return;

        await FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(
              Provider.of<ProfileProvider>(context, listen: false).profile!.id,
            )
            .child('newRide')
            .remove();

        if (!mounted) return;

        // 🏠 Step 3: Redirect driver back home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const DriverHome()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancel live location updates
    streamSubscriptionDriverLivePosition?.cancel();
    rideStatusSubscription?.cancel();
    // Dispose Google Map controller
    newTripGoogleMapController?.dispose();

    PushNotificationSystem().resetRideFlags();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      body: Column(
        children: [
          // Google Maps
          Expanded(
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: mapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
              markers: markersSet,
              circles: circlesSet,
              polylines: polylinesSet,
              style: isDark ? _mapStyle : null,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newTripGoogleMapController = controller;

                setState(() {
                  mapPadding = 350;
                });

                var driverCurrentLatLng = LatLng(
                  driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude,
                );

                var userPickupLatLng =
                    widget.userRideRequestDetails!.originLatLng;

                drawPolylineFromOriginToDestination(
                  driverCurrentLatLng,
                  userPickupLatLng!,
                  isDark,
                );

                getDriverLocationUpdatesAtRealTime();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              MediaQuery.of(context).padding.bottom + 5,
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
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                  child: Column(
                    children: [
                      rideRequestStatus == 'arrived'
                          ? Text(
                              AppLocalizations.of(context)!.waitingForRider,
                              style: Theme.of(context).textTheme.labelMedium,
                            )
                          : rideRequestStatus == 'accepted'
                          ? Text(
                              "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toPickup}",
                              style: Theme.of(context).textTheme.labelMedium,
                            )
                          : Text(
                              "$durationFromOriginToDestination ${AppLocalizations.of(context)!.toDropoff}",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                      SizedBox(height: 5),
                      Divider(color: AppColors.border, thickness: 0.5),
                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Driver arrives at pickup station - Arrived Button

                          if (rideRequestStatus == 'accepted') {
                            rideRequestStatus = 'arrived';
                            setState(() {
                              // print("Should print start trip");
                              buttonTitle = AppLocalizations.of(
                                context,
                              )!.startTrip;
                            });

                            FirebaseDatabase.instance
                                .ref()
                                .child('All Ride Requests')
                                .child(
                                  widget.userRideRequestDetails!.rideRequestId!,
                                )
                                .child('status')
                                .set(rideRequestStatus);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: ((BuildContext context) =>
                                  ProgressDialog(
                                    message: AppLocalizations.of(
                                      context,
                                    )!.pleaseWait,
                                  )),
                            );

                            await drawPolylineFromOriginToDestination(
                              widget.userRideRequestDetails!.originLatLng!,
                              widget.userRideRequestDetails!.destinationLatLng!,
                              isDark,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }
                          // User is onboard - Trip Started Button
                          else if (rideRequestStatus == 'arrived') {
                            rideRequestStatus = 'ontrip';
                            AppMethods.sendDriverArrivalNotification(
                              widget.userRideRequestDetails!.userId!,
                              widget.userRideRequestDetails!.originAddress!,
                              context,
                            );

                            setState(() {
                              // print('Button should be end trip');
                              buttonTitle = AppLocalizations.of(
                                context,
                              )!.endTrip;
                            });

                            FirebaseDatabase.instance
                                .ref()
                                .child('All Ride Requests')
                                .child(
                                  widget.userRideRequestDetails!.rideRequestId!,
                                )
                                .child('status')
                                .set(rideRequestStatus);
                          }
                          // User reached dropoff location
                          else if (rideRequestStatus == 'ontrip') {
                            endTripNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor: Colors.white54,
                          padding: EdgeInsets.all(16),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.directions_car, size: 25),
                        label: Text(buttonTitle),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _makePhoneCall(
                          context,
                          widget.userRideRequestDetails!.userPhone!,
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor: Colors.white54,
                          padding: EdgeInsets.all(8),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.call, size: 28),
                            SizedBox(width: 12),
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
}
