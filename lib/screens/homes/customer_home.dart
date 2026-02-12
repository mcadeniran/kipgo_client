import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/screens/edit_profile.dart';
import 'package:kipgo/screens/rides/active_ride_widget.dart';
// import 'package:kipgo/screens/test_screen.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/rides/riders/ride_history_screen.dart' as history;
import 'package:kipgo/screens/profile_screen.dart' as profile;
import 'package:kipgo/screens/rides/riders/request_ride.dart';
import 'package:kipgo/screens/settings_screen.dart' as settings;
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestLocationPermission();
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
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Optional: redirect user to app settings
      // await Geolocator.openAppSettings(); (if using geolocator >=9.0.0)
    }
  }

  Future<void> _initializePushNotifications(BuildContext context) async {
    await PushNotificationSystem().generateAndGetToken(context);
  }

  @override
  Widget build(BuildContext context) {
    bool activeRide = Provider.of<AppInfo>(context).hasActiveRide;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: 'KIPGO'),
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading) {
                    return CircularProgressIndicator.adaptive();
                  }
                  final displayName = profileProvider.profile!.username;
                  return Text(
                    "${AppLocalizations.of(context)!.hi} $displayName",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3);
                },
              ),
              const SizedBox(height: 10),
              Consumer<ProfileProvider>(
                builder: (context, pp, _) {
                  if (pp.profile!.personal.firstName != '' &&
                      pp.profile!.personal.lastName != '' &&
                      pp.profile!.personal.phone != '' &&
                      pp.profile!.personal.isPhoneVerified) {
                    return Text(
                      AppLocalizations.of(context)!.whatWouldYouLikeToDoToday,
                      style: GoogleFonts.poppins(fontSize: 16),
                    );
                  } else if (pp.profile!.personal.firstName != '' &&
                      pp.profile!.personal.lastName != '' &&
                      pp.profile!.personal.phone != '' &&
                      pp.profile!.personal.isPhoneVerified == false) {
                    return profileErrorMessage(
                      AppLocalizations.of(context)!.pleaseVerifyYourPhoneNumber,
                    );
                  } else {
                    return profileErrorMessage(
                      AppLocalizations.of(context)!.pleaseCompleteYourProfile,
                    );
                  }
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
              const SizedBox(height: 20),
              // Buttons grid
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 140,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                children: [
                  if (activeRide == false) ...[
                    Consumer<ProfileProvider>(
                      builder: (context, pp, _) {
                        if (pp.profile!.personal.firstName != '' &&
                            pp.profile!.personal.lastName != '' &&
                            pp.profile!.personal.phone != '' &&
                            pp.profile!.personal.isPhoneVerified) {
                          return _buildOptionCard(
                            context,
                            title: AppLocalizations.of(context)!.requestRide,
                            icon: Icons.hail_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RequestRide(),
                                ),
                              );
                            },
                          );
                        } else {
                          return rideNotAvailable(isDark);
                        }
                      },
                    ),
                  ],

                  _buildOptionCard(
                    context,
                    title: AppLocalizations.of(context)!.rideHistory,
                    icon: Icons.history,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const history.RideHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.of(context)!.myProfile,
                    icon: Icons.person,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const profile.ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.of(context)!.settings,
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const settings.SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  // _buildOptionCard(
                  //   context,
                  //   title: AppLocalizations.of(context)!.test,
                  //   icon: Icons.laptop_chromebook,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => const TestScreen()),
                  //     );
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              AdsCarouselWidget(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  InkWell rideNotAvailable(bool isDark) {
    return InkWell(
      onTap: null,
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.35;
          final overlaySize = constraints.maxWidth * 0.6;

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      Icons.hail,
                      size: iconSize.clamp(24, 48),
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.requestRide,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Icon(
                  Icons.do_disturb_alt,
                  size: overlaySize.clamp(40, 90),
                  color: isDark ? Colors.white54 : Colors.black26,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget profileErrorMessage(String message) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.red.shade400.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
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
              title,
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
