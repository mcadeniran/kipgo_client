import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/controllers/driver_ride_provider.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/driver_rating_page.dart';
import 'package:kipgo/screens/edit_profile.dart';
import 'package:kipgo/screens/rides/active_ride_widget.dart';
import 'package:kipgo/screens/rides/drivers/active_drive_widget.dart';
import 'package:kipgo/screens/rides/riders/request_ride.dart';
import 'package:kipgo/screens/rides/riders/ride_history_screen.dart';
import 'package:kipgo/screens/settings/vehicle_details_screen.dart';
// import 'package:kipgo/screens/test_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/profile_screen.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/utils/colors.dart';
import '../rides/drivers/my_drives_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late Profile driverProfile;
  late DriverStatusProvider driverStatusProvider;
  late DriverRideProvider activeDriveProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    driverStatusProvider = Provider.of<DriverStatusProvider>(
      context,
      listen: false,
    );
    activeDriveProvider = Provider.of<DriverRideProvider>(
      context,
      listen: false,
    );
  }

  @override
  void initState() {
    super.initState();
    driverProfile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    // 🔹 Run after the first frame so dialogs can show safely
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final driverStatusProvider = Provider.of<DriverStatusProvider>(
        context,
        listen: false,
      );

      bool granted = await driverStatusProvider.requestLocationPermission(
        context,
      );

      if (!granted) {
        // You can handle denial (e.g., prevent going online automatically)
        debugPrint("Driver did not grant location permission.");
      } else {
        debugPrint("Driver granted location permission ✅");
      }

      await _initializePushNotifications(context);

      final user = Provider.of<ProfileProvider>(context, listen: false).profile;
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      if (user != null) {
        if (appInfo.rideId != null) {
          await appInfo.startRideListener(appInfo.rideId!);
        } else {
          await appInfo.recoverActiveRide(user.id);
        }
      }

      if (user != null) {
        Provider.of<DriverRideProvider>(
          context,
          listen: false,
        ).listenForActiveRide(user.id);
      }
    });
  }

  @override
  void dispose() {
    activeDriveProvider.detachListener();
    driverStatusProvider.detachMap();
    super.dispose();
  }

  Future<void> _initializePushNotifications(BuildContext context) async {
    await PushNotificationSystem().generateAndGetToken(context);
  }

  @override
  Widget build(BuildContext context) {
    final driverStatus = Provider.of<DriverStatusProvider>(context);
    bool activeRide = Provider.of<AppInfo>(context).hasActiveRide;
    final driveProvider = Provider.of<DriverRideProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'KIPGO DRIVER',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),

        actions: [
          Consumer<ProfileProvider>(
            builder: (context, p, _) {
              if (p.isLoading) {
                return Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Transform.scale(
                    scale: Platform.isIOS ? 1 : 0.6,
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: AppColors.lightLayer,
                    ),
                  ),
                );
              } else if (p.profile!.account.isProfileCompleted &&
                  p.profile!.account.isApproved &&
                  !activeRide &&
                  !activeDriveProvider.hasActiveDrive) {
                return Consumer<DriverStatusProvider>(
                  builder: (context, ds, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ds.statusText == 'Now Online'
                              ? AppLocalizations.of(context)!.nowOnline
                              : AppLocalizations.of(context)!.currentlyOffline,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ds.isOnline
                                ? Colors.white
                                : AppColors.lightLayer,
                          ),
                        ),
                        ds.isLoading
                            ? Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Transform.scale(
                                  scale: Platform.isIOS ? 1 : 0.6,
                                  child: CircularProgressIndicator.adaptive(
                                    backgroundColor: AppColors.lightLayer,
                                  ),
                                ),
                              )
                            : Transform.scale(
                                scale: 0.6,
                                child: Switch.adaptive(
                                  value: ds.isOnline,
                                  onChanged: (value) =>
                                      ds.toggleStatus(value, context),
                                  activeColor: AppColors.lightLayer,
                                  inactiveThumbColor: AppColors.tertiary,
                                ),
                              ),
                      ],
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: driveProvider.hasActiveDrive
          ? ActiveDriveWidget(ride: driveProvider.driveData!)
          : Container(
              height: double.maxFinite,
              decoration: BoxDecoration(
                // color: Colors.white,
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        if (profileProvider.isLoading) {
                          return CircularProgressIndicator.adaptive();
                        }
                        final displayName = profileProvider.profile!.username;
                        return Column(
                          children: [
                            Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.hi} $displayName",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        // color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    StarRating(
                                      allowHalfRating: true,
                                      rating: profileProvider
                                          .profile!
                                          .personal
                                          .rating,
                                      size: 14,
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: -0.3),
                            if (profileProvider.profile!.vehicle.colour == '' ||
                                profileProvider.profile!.vehicle.licence ==
                                    '' ||
                                profileProvider.profile!.vehicle.licenceUrl ==
                                    '' ||
                                profileProvider.profile!.vehicle.model == '' ||
                                profileProvider.profile!.vehicle.numberPlate ==
                                    '' ||
                                profileProvider
                                        .profile!
                                        .vehicle
                                        .registrationUrl ==
                                    '' ||
                                profileProvider.profile!.vehicle.selfieUrl ==
                                    '') ...[
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const VehicleDetailsScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.submitDocumentsPrompt,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else if (!profileProvider
                                .profile!
                                .account
                                .isApproved) ...[
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.documentsPending,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                            if (!profileProvider
                                .profile!
                                .account
                                .isProfileCompleted) ...[
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EditProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.completeProfilePrompt,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    Consumer<AppInfo>(
                      builder: (context, appInfo, child) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: appInfo.hasActiveRide
                                ? ActiveRideWidget()
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                    if (driverStatus.isOnline && !activeRide) ...[
                      const SizedBox(height: 20),
                      Container(
                        clipBehavior: Clip.hardEdge,
                        width: double.maxFinite,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GoogleMap(
                          myLocationEnabled: true,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(
                              35.133428350758344,
                              33.923606022529256,
                            ),
                            zoom: 14.5,
                          ),
                          onMapCreated: (controller) {
                            // driverStatus.newGoogleMapController = controller;
                            // driverStatus.locateDriverPosition(context);
                            driverStatus.attachMap(controller);
                            driverStatus.locateDriverPosition(context);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 140,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      children: [
                        _buildCard(
                          context,
                          icon: Icons.local_taxi,
                          label: AppLocalizations.of(context)!.myDrives,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyDrivesScreen(),
                              ),
                            );
                          },
                        ),
                        if (!driverStatus.isOnline && !activeRide)
                          _buildCard(
                            context,
                            icon: Icons.hail_rounded,
                            label: AppLocalizations.of(context)!.requestRide,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RequestRide(),
                                ),
                              );
                            },
                          ),
                        _buildCard(
                          context,
                          icon: Icons.history,
                          label: AppLocalizations.of(context)!.rideHistory,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RideHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          context,
                          icon: Symbols.map_pin_review,
                          label: AppLocalizations.of(context)!.myReviews,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DriverRatingPage(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          context,
                          icon: Icons.person,
                          label: AppLocalizations.of(context)!.myProfile,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          context,
                          icon: Icons.settings,
                          label: AppLocalizations.of(context)!.settings,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        // _buildCard(
                        //   context,
                        //   icon: Icons.laptop,
                        //   label: AppLocalizations.of(context)!.test,
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => const TestScreen(),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkLayer : Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
