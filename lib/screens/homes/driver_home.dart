import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
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

    driverStatusProvider = context.read<DriverStatusProvider>();
    activeDriveProvider = context.read<DriverRideProvider>();
  }

  @override
  void initState() {
    super.initState();

    driverProfile = context.read<ProfileProvider>().profile!;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final statusProvider = context.read<DriverStatusProvider>();

      final granted = await statusProvider.requestLocationPermission(context);

      if (!granted) {
        debugPrint('Driver did not grant location permission.');
      }

      await _initializePushNotifications(context);

      if (!mounted) return;

      final profile = context.read<ProfileProvider>().profile;

      final appInfo = context.read<AppInfo>();

      if (profile != null) {
        if (appInfo.rideId != null) {
          await appInfo.startRideListener(appInfo.rideId!);
        } else {
          await appInfo.recoverActiveRide(profile.id);
        }

        if (!mounted) return;

        context.read<DriverRideProvider>().listenForActiveRide(profile.id);
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

  bool _isDriverReady(Profile profile) {
    return profile.account.isProfileCompleted &&
        profile.account.isApproved &&
        profile.personal.isPhoneVerified &&
        _hasCompleteVehicle(profile);
  }

  bool _hasCompleteVehicle(Profile profile) {
    final vehicle = profile.vehicle;

    return vehicle.colour.isNotEmpty &&
        vehicle.licence.isNotEmpty &&
        vehicle.licenceUrl.isNotEmpty &&
        vehicle.model.isNotEmpty &&
        vehicle.numberPlate.isNotEmpty &&
        vehicle.registrationUrl.isNotEmpty &&
        vehicle.selfieUrl.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final driverStatus = context.watch<DriverStatusProvider>();

    final driveProvider = context.watch<DriverRideProvider>();

    final appInfo = context.watch<AppInfo>();

    final profileProvider = context.watch<ProfileProvider>();

    final profile = profileProvider.profile;

    final activeRide = appInfo.hasActiveRide;
    final activeDrive = driveProvider.hasActiveDrive;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(
        context,
        isDark: isDark,
        driverStatus: driverStatus,
        profile: profile,
        activeRide: activeRide,
        activeDrive: activeDrive,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: activeDrive
              ? ActiveDriveWidget(ride: driveProvider.driveData!)
              : RefreshIndicator(
                  onRefresh: () async {
                    // final currentProfile = context
                    //     .read<ProfileProvider>()
                    //     .profile;

                    // if (currentProfile != null) {
                    //   await context.read<DriverRideProvider>().refresh();
                    // }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile != null) ...[
                          _buildWelcomeSection(context, profile),

                          const SizedBox(height: 18),

                          _buildDriverStatusCard(
                            context,
                            profile: profile,
                            statusProvider: driverStatus,
                            activeRide: activeRide,
                            activeDrive: activeDrive,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 16),

                          _buildAccountStatus(context, profile),

                          if (activeRide) ...[
                            const SizedBox(height: 18),
                            _buildSectionTitle(context, loc.activeRide),
                            const SizedBox(height: 10),
                            const ActiveRideWidget(),
                          ],

                          if (driverStatus.isOnline && !activeRide) ...[
                            const SizedBox(height: 18),
                            _buildLiveMap(context, driverStatus, isDark),
                          ],

                          const SizedBox(height: 28),

                          _buildVehicleCard(context, profile, isDark),

                          const SizedBox(height: 28),

                          _buildQuickStats(context, profile, isDark),

                          const SizedBox(height: 28),

                          const AdsCarouselWidget(),

                          const SizedBox(height: 28),

                          // ------------------------------------------------------------
                          // PASSENGER TOOLS
                          // ------------------------------------------------------------
                          Text(
                            loc.passengerTools,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            loc.bookAndManageRidesAsPassenger,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildToolCard(
                            context,
                            icon: Icons.hail_rounded,
                            title: AppLocalizations.of(context)!.requestRide,
                            subtitle: loc.requestRideAsPassenger,
                            enabled:
                                !driverStatus.isOnline &&
                                !activeRide &&
                                profileProvider
                                    .profile!
                                    .account
                                    .isProfileCompleted &&
                                profileProvider
                                    .profile!
                                    .personal
                                    .isPhoneVerified,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RequestRide(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildToolCard(
                            context,
                            icon: Icons.history_rounded,
                            title: AppLocalizations.of(context)!.rideHistory,
                            subtitle: loc.viewRidesCompleted,
                            enabled: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RideHistoryScreen(),
                                ),
                              );
                            },
                          ),

                          // _buildDriverShortcuts(
                          //   context,
                          //   isDark,
                          //   canRequestPassengerRide,
                          // ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool isDark,
    required DriverStatusProvider driverStatus,
    required Profile? profile,
    required bool activeRide,
    required bool activeDrive,
  }) {
    final loc = AppLocalizations.of(context)!;

    final canToggle =
        profile != null &&
        _isDriverReady(profile) &&
        !activeRide &&
        !activeDrive;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'KIPGO',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (canToggle)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildAppBarStatus(context, driverStatus, loc),
          ),
      ],
    );
  }

  Widget _buildAppBarStatus(
    BuildContext context,
    DriverStatusProvider provider,
    AppLocalizations loc,
  ) {
    return GestureDetector(
      onTap: provider.isLoading
          ? null
          : () => provider.toggleStatus(!provider.isOnline, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: provider.isOnline ? Colors.greenAccent : Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              provider.isOnline ? loc.nowOnline : loc.currentlyOffline,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, Profile profile) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.hiUser(profile.username),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                loc.readyForYourNextRide,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.amber.withValues(alpha: 0.10),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                profile.personal.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15);
  }

  Widget _buildDriverStatusCard(
    BuildContext context, {
    required Profile profile,
    required DriverStatusProvider statusProvider,
    required bool activeRide,
    required bool activeDrive,
    required bool isDark,
  }) {
    final loc = AppLocalizations.of(context)!;

    final ready = _isDriverReady(profile);

    final isOnline = statusProvider.isOnline;

    final canToggle = ready && !activeRide && !activeDrive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? [AppColors.primary, AppColors.darkLayer]
              : isDark
              ? [AppColors.darkAccent, AppColors.darkLayer]
              : [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isOnline
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.white.withValues(alpha: 0.12)
                      : isDark
                      ? AppColors.lightLayer.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isOnline
                      ? Icons.wifi_rounded
                      : Icons.power_settings_new_rounded,
                  color: isOnline
                      ? Colors.white
                      : isDark
                      ? AppColors.lightLayer
                      : AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? loc.nowOnline : loc.currentlyOffline,
                      style: GoogleFonts.poppins(
                        color: isOnline ? Colors.white : null,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOnline
                          ? loc.youAreRadyToReceiveRideRequests
                          : loc.goOnlineWhenYouareReady,
                      style: GoogleFonts.poppins(
                        color: isOnline
                            ? Colors.white.withValues(alpha: 0.70)
                            : Theme.of(context).textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!ready)
            _buildDisabledStatusMessage(context, profile)
          else
            GestureDetector(
              onTap: !canToggle || statusProvider.isLoading
                  ? null
                  : () => statusProvider.toggleStatus(!isOnline, context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: isOnline
                      ? Border.all(color: Colors.white.withValues(alpha: 0.20))
                      : null,
                ),
                child: Center(
                  child: statusProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isOnline
                                  ? Icons.power_settings_new_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline ? loc.goOffline : loc.goOnline,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisabledStatusMessage(BuildContext context, Profile profile) {
    final loc = AppLocalizations.of(context)!;

    String message;

    if (!_hasCompleteVehicle(profile)) {
      message = loc.submitDocumentsPrompt;
    } else if (!profile.account.isProfileCompleted) {
      message = loc.completeProfilePrompt;
    } else if (!profile.personal.isPhoneVerified) {
      message = loc.pleaseVerifyYourNumber;
    } else if (!profile.account.isApproved) {
      message = loc.documentsPending;
    } else {
      message = loc.yourAccountIsNotReadyYet;
    }

    return GestureDetector(
      onTap: () {
        if (!_hasCompleteVehicle(profile)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehicleDetailsScreen()),
          );
        } else if (!profile.account.isProfileCompleted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.amber,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatus(BuildContext context, Profile profile) {
    if (!_hasCompleteVehicle(profile)) {
      return const SizedBox.shrink();
    }

    if (!profile.account.isApproved) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.pending_actions_rounded,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.documentsPending,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLiveMap(
    BuildContext context,
    DriverStatusProvider provider,
    bool isDark,
  ) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, loc.yourLocation),
        const SizedBox(height: 10),
        Container(
          height: 210,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.133428350758344, 33.923606022529256),
              zoom: 14.5,
            ),
            onMapCreated: (controller) {
              provider.attachMap(controller);
              provider.locateDriverPosition(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context, Profile profile, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final vehicle = profile.vehicle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, loc.yourVehicle),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehicleDetailsScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkAccent : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.lightLayer.withValues(alpha: 0.25)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_taxi_rounded,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.model.isEmpty ? loc.vehicle : vehicle.model,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          vehicle.colour,
                          vehicle.numberPlate,
                        ].where((e) => e.isNotEmpty).join(' • '),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, Profile profile, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star_rounded,
            value: profile.personal.rating.toStringAsFixed(1),
            label: loc.rating,
            iconColor: Colors.amber,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.verified_rounded,
            value: profile.account.isApproved ? loc.approved : loc.pending,
            label: loc.accountTitle,
            iconColor: profile.account.isApproved ? Colors.green : Colors.amber,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 21),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final isDark = context.read<ThemeProvider>().isDarkMode;

    final backgroundColor = isDark ? AppColors.darkAccent : theme.cardColor;

    final iconBackgroundColor = enabled
        ? isDark
              ? AppColors.lightLayer.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: isDark ? 0.30 : 0.08)
        : Colors.grey.withValues(alpha: 0.10);

    final iconColor = enabled
        ? (isDark ? AppColors.lightLayer : AppColors.primary)
        : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.border.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ----------------------------------------------------------
                // ICON
                // ----------------------------------------------------------
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 26, color: iconColor),
                ),

                const SizedBox(width: 14),

                // ----------------------------------------------------------
                // TITLE + SUBTITLE
                // ----------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: enabled
                              ? theme.colorScheme.onSurface
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: enabled
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                )
                              : Colors.grey.withValues(alpha: 0.6),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ----------------------------------------------------------
                // ARROW
                // ----------------------------------------------------------
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.035),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: enabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}
