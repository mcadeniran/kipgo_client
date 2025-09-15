import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/screens/text_screen.dart';
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

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken(context);
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBarWidget(title: 'KIPGO'),
      backgroundColor: AppColors.primary,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              Text(
                AppLocalizations.of(context)!.whatWouldYouLikeToDoToday,
                style: GoogleFonts.poppins(fontSize: 16),
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
                children: [
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.of(context)!.requestRide,
                    icon: Icons.directions_car,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestRide()),
                        // MaterialPageRoute(builder: (_) => const InitiateRide()),
                      );
                    },
                  ),
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
                  _buildOptionCard(
                    context,
                    title: AppLocalizations.of(context)!.test,
                    icon: Icons.laptop_chromebook,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TestScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AdsCarouselWidget(),
              const SizedBox(height: 10),
            ],
          ),
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
