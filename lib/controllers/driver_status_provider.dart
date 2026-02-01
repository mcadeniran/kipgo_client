import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/helpers/helpers.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/background_location_disclosure.dart';
import 'package:kipgo/utils/methods.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class DriverStatusProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  String get statusText => _isOnline ? "Now Online" : "Currently Offline";

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late LocationSettings locationSettings;

  StreamSubscription<Position>? _positionSub;

  GoogleMapController? _newGoogleMapController;
  Completer<GoogleMapController>? _controllerGoogleMap; // make nullable

  DriverStatusProvider() {
    _controllerGoogleMap = Completer<GoogleMapController>();
    _loadStatus();
  }

  final geo = GeoFlutterFire();
  final driversCollection = FirebaseFirestore.instance.collection(
    'activeDrivers',
  );

  set newGoogleMapController(GoogleMapController controller) {
    _newGoogleMapController = controller;
    if (!(_controllerGoogleMap?.isCompleted ?? true)) {
      _controllerGoogleMap!.complete(controller);
    }
    notifyListeners();
  }

  void attachMap(GoogleMapController controller) {
    _newGoogleMapController = controller;
    if (!(_controllerGoogleMap?.isCompleted ?? true)) {
      _controllerGoogleMap!.complete(controller);
    }
    notifyListeners();
  }

  // Call this from the screen's dispose (or when the mini-map is off-screen)
  void detachMap() {
    _newGoogleMapController?.dispose();
    _newGoogleMapController = null;

    // reset the completer so future awaits don't hang forever
    _controllerGoogleMap = Completer<GoogleMapController>();
  }

  // Optional getter if you still need it
  Future<GoogleMapController> get controllerFuture async {
    _controllerGoogleMap ??= Completer<GoogleMapController>();
    return _controllerGoogleMap!.future;
  }

  // A safe animator that won’t hang or throw if the map isn’t present
  Future<void> safeAnimateCamera(CameraUpdate update) async {
    try {
      if (_newGoogleMapController != null) {
        await _newGoogleMapController!.animateCamera(update);
      } else {
        // No map mounted; just ignore
      }
    } catch (_) {
      // controller might be disposed; ignore safely
    }
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnline = prefs.getBool("driver_status") ?? false;
    notifyListeners();
  }

  /// 🔹 Internal method that actually requests permission
  Future<bool> _handleLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    // print("PERMISSION STATUS: $permission");

    // Step 1: Request foreground if not granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }

    // Step 2: Handle denied forever → settings
    if (permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.permissionRequired),
          content: Text(
            AppLocalizations.of(context)!.locationPermissionIsPermanentlyDenied,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Geolocator.openAppSettings();
              },
              child: Text(AppLocalizations.of(context)!.openSettings),
            ),
          ],
        ),
      );
      return false;
    }

    // Step 3: If only foreground → ask for background later
    if (permission == LocationPermission.whileInUse) {
      // Don't immediately request background here
      return true; // ✅ foreground is fine for now
    }
    // Already has background
    return permission == LocationPermission.always;
  }

  // Future<bool> ensureBackgroundPermission(BuildContext context) async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   // print("FROM ENSURE BACKGROUND PERMISSION: $permission");
  //   if (permission == LocationPermission.always) {
  //     // ✅ Already has background
  //     return true;
  //   }

  //   if (permission == LocationPermission.whileInUse) {
  //     // ❌ Only foreground — explain to the driver
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: Text(AppLocalizations.of(context)!.backgroundLocationNeeded),
  //         content: Text(AppLocalizations.of(context)!.kipgoNeeds),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(ctx);
  //               await Geolocator.openAppSettings();
  //             },
  //             child: Text(AppLocalizations.of(context)!.openSettings),
  //           ),
  //         ],
  //       ),
  //     );
  //     return false;
  //   }

  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     // Handle normal denied case
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: Text(AppLocalizations.of(context)!.locationPermissionRequired),
  //         content: Text(
  //           AppLocalizations.of(context)!.locationPermissionRequiredDrivers,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(ctx);
  //               await Geolocator.openAppSettings();
  //             },
  //             child: Text(AppLocalizations.of(context)!.openSettings),
  //           ),
  //         ],
  //       ),
  //     );
  //     return false;
  //   }

  //   return false;
  // }

  Future<bool> ensureBackgroundPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    // ✅ Already granted
    if (permission == LocationPermission.always) {
      return true;
    }

    // ❌ Must show disclosure BEFORE background permission
    final accepted = await showBackgroundLocationDisclosure(context);
    if (!accepted) return false;

    // 🔐 Redirect user to system settings (Android requirement)
    await Geolocator.openAppSettings();

    return false;
  }

  Future<void> toggleStatus(bool value, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (value) {
      final hasBg = await ensureBackgroundPermission(context);
      if (!hasBg) {
        _isOnline = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isOnline = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("driver_status", _isOnline);

      if (!context.mounted) return;
      await driverIsOnlineNow(context);
      _isLoading = false;
      notifyListeners();

      // Fire-and-forget: don’t await (prevents UI “hangs” if map isn’t ready)
      if (context.mounted) {
        // ignore: unawaited_futures
        Future(() => updateDriverLocationInRealTime());
      }
    } else {
      _isOnline = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("driver_status", _isOnline);

      if (context.mounted) {
        driverIsOfflineNow(context);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> requestLocationPermission(BuildContext context) async {
    return await _handleLocationPermission(context);
  }

  void setDriverOnline(String driverId, double lat, double lng) {
    final GeoFirePoint point = geo.point(latitude: lat, longitude: lng);
    driversCollection.doc(driverId).set({
      'position': point.data,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  void setDriverOffline(String driverId) {
    driversCollection.doc(driverId).delete();
  }

  Future<void> driverIsOnlineNow(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    if (!context.mounted) return;
    Profile currentDriver = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: getLocationSettings(context),
      );

      driverCurrentPosition = pos;

      setDriverOnline(currentDriver.id, pos.latitude, pos.longitude);

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(currentDriver.id)
          .update({'newRideStatus': 'idle'});
    } catch (e) {
      debugPrint('Error setting driver online: $e');
    }
  }

  Future<void> forceOfflineForTrip(String driverId) async {
    // Stop location streaming immediately
    await _positionSub?.cancel();
    _positionSub = null;

    _isOnline = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("driver_status", false);

    // 🔥 CRITICAL: remove driver from rider-visible pool
    setDriverOffline(driverId);

    notifyListeners();
  }

  void updateDriverLocationInRealTime() async {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;
    final hasPermission = await _handleLocationPermission(ctx);
    if (!hasPermission) return;

    // 🔐 Only one listener
    await _positionSub?.cancel();

    final profile = Provider.of<ProfileProvider>(ctx, listen: false).profile!;
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: getLocationSettings(ctx),
        ).listen((pos) async {
          if (!_isOnline) return;

          driverCurrentPosition = pos;
          setDriverOnline(profile.id, pos.latitude, pos.longitude);

          // Throttle camera updates to reduce jank
          _throttledAnimate(LatLng(pos.latitude, pos.longitude));
        });
  }

  void driverIsOfflineNow(BuildContext context) {
    Provider.of<ProfileProvider>(context, listen: false).profile!;
    _positionSub?.cancel(); // 🧹 stop streaming
    _positionSub = null;
    _isOnline = false;
    notifyListeners();

    // remove from activeDrivers as you already do
    final currentDriver = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;
    setDriverOffline(currentDriver.id);
  }

  DateTime? _lastAnimateAt;
  void _throttledAnimate(LatLng latLng) {
    final now = DateTime.now();
    if (_lastAnimateAt == null ||
        now.difference(_lastAnimateAt!) > const Duration(seconds: 2)) {
      _lastAnimateAt = now;
      safeAnimateCamera(CameraUpdate.newLatLng(latLng));
    }
  }

  Future<void> locateDriverPosition(BuildContext context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    Position cPosition = await Geolocator.getCurrentPosition(
      locationSettings: getLocationSettings(context),
    );

    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );

    await safeAnimateCamera(
      CameraUpdate.newLatLng(
        LatLng(latLngPosition.latitude, latLngPosition.longitude),
      ),
    );

    if (!context.mounted) return;

    await AppMethods.searchAddressFromGeographicalCoordinates(
      driverCurrentPosition!,
      context,
    );
  }

  LocationSettings getLocationSettings(BuildContext context) {
    // Platform-specific location settings
    LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationText: AppLocalizations.of(context)!.kipgoWillContinue,
          notificationTitle: AppLocalizations.of(context)!.runningInBackground,
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 100,
        maximumAge: Duration(minutes: 5),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 100,
      );
    }
    return locationSettings;
  }
}
