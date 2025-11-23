import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/helpers/location_settings_helper.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/screens/widgets/ride_location_card_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

class ActiveDriveWidget extends StatefulWidget {
  final RideHistory ride;
  const ActiveDriveWidget({super.key, required this.ride});

  @override
  State<ActiveDriveWidget> createState() => _ActiveDriveWidgetState();
}

class _ActiveDriveWidgetState extends State<ActiveDriveWidget> {
  bool status = true;
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.133428350758344, 33.923606022529256),
    zoom: 14.4746,
  );

  String? _mapStyle;

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

  bool isRequestDirectionDetails = false;

  DatabaseReference? rideStatusRef;
  StreamSubscription<DatabaseEvent>? rideStatusSubscription;

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

  Future<void> updatePolylineBasedOnStatus(bool isDark) async {
    if (driverCurrentPosition == null) return;

    polylinesSet.clear();
    markersSet.clear();
    circlesSet.clear();

    LatLng driverLatLng = LatLng(
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
    LatLng originLatLng = LatLng(
      widget.ride.origin.latitude,
      widget.ride.origin.longitude,
    );
    LatLng destinationLatLng = LatLng(
      widget.ride.destination.latitude,
      widget.ride.destination.longitude,
    );

    // 🔹 accepted → show driver → origin route
    if (rideRequestStatus == 'accepted') {
      await drawPolylineFromOriginToDestination(
        driverLatLng,
        originLatLng,
        isDark,
      );
    }
    // 🔹 arrived → no polyline (clear everything except driver's marker)
    else if (rideRequestStatus == 'arrived') {
      setState(() {
        polylinesSet.clear();
        circlesSet.clear();
        markersSet.removeWhere((m) => m.markerId.value != 'AnimatedMarker');
      });
    }
    // 🔹 ontrip → show origin → destination route
    else if (rideRequestStatus == 'ontrip') {
      await drawPolylineFromOriginToDestination(
        originLatLng,
        destinationLatLng,
        isDark,
      );
    }
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
              .child(widget.ride.id)
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
        LatLng originLatLng = LatLng(
          widget.ride.origin.latitude,
          widget.ride.origin.longitude,
        );
        destinationLatLng = originLatLng;
      } else {
        destinationLatLng = LatLng(
          widget.ride.destination.latitude,
          widget.ride.destination.longitude,
        );
      }

      var directionInformation =
          await AppMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng,
            destinationLatLng,
          );

      debugPrint(directionInformation!.durationText);

      setState(() {
        durationFromOriginToDestination = directionInformation.durationText!;
      });

      isRequestDirectionDetails = false;
    }
  }

  Future<void> endTripNow() async {
    showDialog(
      context: context,
      builder: ((BuildContext context) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait)),
    );

    // End trip
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.ride.id)
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
    // Navigator.pop(context);

    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) {
      return;
    }

    final shouldGoHome = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(ctx)!.rideCompleted,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(AppLocalizations.of(ctx)!.yourRideHasEnded),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(ctx)!.ok),
            ),
          ],
        );
      },
    );

    if (shouldGoHome == true) {
      cleanupResources();
      // if (!mounted) return;
      // Provider.of<DriverStatusProvider>(
      //   context,
      //   listen: false,
      // ).toggleStatus(true, context);
      if (!mounted) return;
      Navigator.pop(ctx);
    } else {}
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
    cleanupResources();
    _loadMapStyle();
    createDriverIconMarker();
    buttonTitle = '';
    rideRequestStatus = widget.ride.status;

    // Get driver's initial location safely
    Geolocator.getCurrentPosition(locationSettings: getLocationSetting()).then((
      position,
    ) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      setState(() {}); // trigger rebuild once we have location
    });

    // 🟢 Fetch actual live ride status instead of using stale widget.ride.status
    FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.ride.id)
        .child('status')
        .get()
        .then((snapshot) {
          final liveStatus = snapshot.value?.toString() ?? widget.ride.status;

          setState(() {
            rideRequestStatus = liveStatus;

            // Keep button title in sync
            if (rideRequestStatus == 'accepted') {
              buttonTitle = AppLocalizations.of(context)!.arrived;
            } else if (rideRequestStatus == 'arrived') {
              buttonTitle = AppLocalizations.of(context)!.startTrip;
            } else if (rideRequestStatus == 'ontrip') {
              buttonTitle = AppLocalizations.of(context)!.endTrip;
            } else {
              buttonTitle = '';
            }
          });
        });

    // 🟡 Now listen to updates for future changes
    rideStatusRef = FirebaseDatabase.instance
        .ref()
        .child('All Ride Requests')
        .child(widget.ride.id)
        .child('status');

    rideStatusSubscription = rideStatusRef!.onValue.listen((event) async {
      final status = event.snapshot.value?.toString();

      if (status == null) return;

      // 🚀 Keep internal state and button updated live
      setState(() {
        rideRequestStatus = status;
        if (status == 'accepted') {
          buttonTitle = AppLocalizations.of(context)!.arrived;
        } else if (status == 'arrived') {
          buttonTitle = AppLocalizations.of(context)!.startTrip;
        } else if (status == 'ontrip') {
          buttonTitle = AppLocalizations.of(context)!.endTrip;
        }
      });

      if (status == 'ended') {
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx == null) {
          return;
        }

        if (!ctx.mounted) return;

        cleanupResources();
        rideStatusSubscription?.cancel();

        showDialog(
          context: ctx,
          builder: ((BuildContext context) => ProgressDialog(
            message: AppLocalizations.of(context)!.pleaseWait,
          )),
        );

        // End trip
        FirebaseDatabase.instance
            .ref()
            .child('All Ride Requests')
            .child(widget.ride.id)
            .child('status')
            .set('ended');

        String driverId = Provider.of<ProfileProvider>(
          ctx,
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

        await showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                AppLocalizations.of(ctx)!.rideEnded,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(AppLocalizations.of(ctx)!.yourRideHasEnded),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx)!.ok),
                ),
              ],
            );
          },
        );
        if (!ctx.mounted) return;
        Provider.of<DriverStatusProvider>(
          ctx,
          listen: false,
        ).toggleStatus(true, ctx);
        if (!ctx.mounted) return;
        if (Navigator.canPop(ctx)) {
          Navigator.pop(ctx);
        }
      }

      // Handle cancellation event here if needed
      if (status == 'cancelled') {
        // Stop location and cleanup
        cleanupResources();
        rideStatusSubscription?.cancel();

        if (!mounted) return;

        // 🔔 Step 1: Show a quick toast/snackbar notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.riderCancelledTrip),
            backgroundColor: AppColors.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

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
            .child(
              Provider.of<ProfileProvider>(context, listen: false).profile!.id,
            )
            .child('newRide')
            .remove();

        // Small delay for the toast to appear before dialog
        await Future.delayed(const Duration(milliseconds: 600));
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx == null) {
          return;
        }
        // 🪧 Step 2: Show a dialog for confirmation
        await showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                AppLocalizations.of(ctx)!.rideCancelled,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(AppLocalizations.of(ctx)!.theRiderHasCancelled),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx)!.ok),
                ),
              ],
            );
          },
        );

        if (!ctx.mounted) return;
        Provider.of<DriverStatusProvider>(
          ctx,
          listen: false,
        ).toggleStatus(true, ctx);

        // 🏠 Step 3: Redirect driver back home
        Navigator.pop(ctx);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.ride.status == 'accepted') {
        buttonTitle = AppLocalizations.of(context)!.arrived;
      } else if (widget.ride.status == 'arrived') {
        buttonTitle = AppLocalizations.of(context)!.startTrip;
      } else {
        buttonTitle = AppLocalizations.of(context)!.endTrip;
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: EdgeInsets.all(16),
      height: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Consumer<ProfileProvider>(
            builder: (context, pp, _) {
              return Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.hi} ${pp.profile!.username}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2),
                  StarRating(
                    allowHalfRating: true,
                    rating: pp.profile!.personal.rating,
                    size: 14,
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: GoogleMap(
                padding: EdgeInsets.only(top: mapPadding),
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
                    mapPadding = 50;
                  });

                  updatePolylineBasedOnStatus(isDark);

                  getDriverLocationUpdatesAtRealTime();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          RideLocationCard(
            currentLocation: widget.ride.originAddress,
            destinationAddress: widget.ride.destinationAddress,
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
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
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
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
                                    .child(widget.ride.id)
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
                                await updatePolylineBasedOnStatus(isDark);
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }
                              // User is onboard - Trip Started Button
                              else if (rideRequestStatus == 'arrived') {
                                rideRequestStatus = 'ontrip';
                                AppMethods.sendDriverArrivalNotification(
                                  widget.ride.userId,
                                  widget.ride.originAddress,
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
                                    .child(widget.ride.id)
                                    .child('status')
                                    .set(rideRequestStatus);

                                await updatePolylineBasedOnStatus(isDark);
                              }
                              // User reached dropoff location
                              else if (rideRequestStatus == 'ontrip') {
                                endTripNow();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.5),
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
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _makePhoneCall(context, widget.ride.userPhone),
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
                          Text(widget.ride.username),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
