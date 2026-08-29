import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/screens/rides/active_ride_widget.dart';
import 'package:kipgo/screens/widgets/require_authentication_page.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/rides/riders/request_ride.dart';
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
      if (!mounted) return;

      final auth = context.read<AuthProvider>();

      // Guests do not need location or notification initialization.
      if (!auth.isLoggedIn) return;

      await _initializeAuthenticatedFeatures();
    });
  }

  Future<void> _initializeAuthenticatedFeatures() async {
    await _initializePushNotifications();

    final profile = context.read<ProfileProvider>().profile;

    final appInfo = context.read<AppInfo>();

    if (profile != null) {
      if (appInfo.rideId != null) {
        await appInfo.startRideListener(appInfo.rideId!);
      } else {
        await appInfo.recoverActiveRide(profile.id);
      }
    }
  }

  Future<void> _initializePushNotifications() async {
    if (!mounted) return;

    await PushNotificationSystem().generateAndGetToken(context);
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> _requireAuthentication({
    required VoidCallback onAuthenticated,
  }) async {
    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn) {
      onAuthenticated();
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RequireAuthenticationPage()),
    );

    if (result == true && mounted) {
      onAuthenticated();
    }
  }

  void _requestRide() {
    _requireAuthentication(
      onAuthenticated: () async {
        final profile = context.read<ProfileProvider>().profile;

        if (profile == null) return;

        final personal = profile.personal;

        if (personal.firstName.isEmpty ||
            personal.lastName.isEmpty ||
            personal.phone.isEmpty) {
          _showProfileMessage(
            AppLocalizations.of(context)!.pleaseCompleteYourProfile,
          );
          return;
        }

        if (!personal.isPhoneVerified) {
          _showProfileMessage(
            AppLocalizations.of(context)!.pleaseVerifyYourPhoneNumber,
          );
          return;
        }

        // Ask for location only when the user is actually
        // requesting a ride.
        await _requestLocationPermission();

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestRide()),
        );
      },
    );
  }

  void _showProfileMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final auth = context.watch<AuthProvider>();

    // final appInfo = context.watch<AppInfo>();

    final isLoggedIn = auth.isLoggedIn;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,

      appBar: AppBarWidget(title: 'KIPGO'),

      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),

        child: SafeArea(
          top: false,

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(12, 22, 12, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // --------------------------------------------------
                // HERO
                // --------------------------------------------------
                _buildHero(context, isLoggedIn: isLoggedIn, isDark: isDark),

                const SizedBox(height: 22),

                // --------------------------------------------------
                // GUEST CTA
                // --------------------------------------------------
                if (!isLoggedIn) _buildGuestRideCard(context, isDark),

                // --------------------------------------------------
                // ACTIVE RIDE
                // --------------------------------------------------
                if (isLoggedIn)
                  Consumer<AppInfo>(
                    builder: (context, appInfo, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),

                        child: appInfo.hasActiveRide
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: ActiveRideWidget(),
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),

                // Main ride CTA
                _buildRideCta(context, isDark),

                // --------------------------------------------------
                // POPULAR DESTINATIONS
                // --------------------------------------------------

                // _buildPopularDestinations(context, isDark),
                const SizedBox(height: 24),

                // --------------------------------------------------
                // WHY KIPGO
                // --------------------------------------------------
                _buildWhyKipGo(context, isDark),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // PROMOTIONAL / ADS
                // --------------------------------------------------
                _buildSectionTitle(context, loc.exploreKipgo),

                const SizedBox(height: 12),

                const AdsCarouselWidget(),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // FOOTER MESSAGE
                // --------------------------------------------------
                _buildPremiumFooter(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // HERO
  // ==============================================================

  Widget _buildHero(
    BuildContext context, {
    required bool isLoggedIn,
    required bool isDark,
  }) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final profile = context.watch<ProfileProvider>().profile;

    final title = isLoggedIn && profile != null
        ? '${AppLocalizations.of(context)!.hi} ${profile.username}'
        : loc.moveSmarterWithKipgo;

    final subtitle = isLoggedIn
        ? AppLocalizations.of(context)!.whatWouldYouLikeToDoToday
        : loc.reliableRidesWhenever;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: .82)],
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -45,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_taxi_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.kipgoTaxi,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: .82),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              if (!isLoggedIn)
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _requestRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hail_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.requestRide,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: .08);
  }

  Widget _buildRideCta(BuildContext context, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _requestRide,
      borderRadius: BorderRadius.circular(22),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccent : Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .08),

              blurRadius: 20,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(
                Icons.local_taxi_outlined,
                color: isDark ? AppColors.darkLayer : AppColors.primary,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    loc.whereAreYouGoing,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    loc.requestAComfortableRide,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // POPULAR DESTINATIONS CARD
  // ==============================================================

  Widget _buildPopularDestinations(BuildContext context, bool isDark) {
    final destinations = [
      (
        title: 'Airport',
        subtitle: 'Ercan International',
        icon: Icons.flight_takeoff_rounded,
      ),
      (
        title: 'Kyrenia',
        subtitle: 'City centre',
        icon: Icons.location_city_outlined,
      ),
      (
        title: 'Nicosia',
        subtitle: 'Capital city',
        icon: Icons.apartment_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Popular destinations'),

        const SizedBox(height: 12),

        SizedBox(
          height: 125,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            physics: const BouncingScrollPhysics(),

            itemCount: destinations.length,

            separatorBuilder: (_, __) => const SizedBox(width: 12),

            itemBuilder: (context, index) {
              final destination = destinations[index];

              return Container(
                width: 150,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        destination.icon,
                        color: isDark ? AppColors.darkLayer : AppColors.primary,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      destination.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      destination.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // GUEST CARD
  // ==============================================================

  Widget _buildGuestRideCard(BuildContext context, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: isDark ? AppColors.darkLayer : AppColors.primary,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.readyToRide,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  loc.signInToRequestARide,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: .08);
  }

  // ==============================================================
  // WHY KIPGO
  // ==============================================================
  Widget _buildWhyKipGo(BuildContext context, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    final features = [
      (
        icon: Icons.verified_user_outlined,
        title: loc.safe,
        subtitle: loc.trustedDrivers,
      ),
      (
        icon: Icons.access_time_rounded,
        title: loc.reliable,
        subtitle: loc.onTimeRides,
      ),
      (
        icon: Icons.payments_outlined,
        title: loc.simple,
        subtitle: loc.clearPricing,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildSectionTitle(context, loc.whyRideWithKipgo),

        const SizedBox(height: 12),

        Row(
          children: features.map((feature) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),

                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: .05)
                        : Colors.black.withValues(alpha: .04),
                  ),
                ),

                child: Column(
                  children: [
                    Icon(
                      feature.icon,
                      size: 24,
                      color: isDark ? AppColors.darkLayer : AppColors.primary,
                    ),

                    const SizedBox(height: 9),

                    Text(
                      feature.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      feature.subtitle,
                      textAlign: TextAlign.center,

                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }

  // ==============================================================
  // FOOTER
  // ==============================================================

  Widget _buildPremiumFooter(BuildContext context, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent
            : AppColors.primary.withValues(alpha: .04),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: isDark ? AppColors.darkLayer : AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.travelWithConfidence,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loc.kipgoMakesGettingAroundSimple,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.blueGrey,
                    height: 1.4,
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
