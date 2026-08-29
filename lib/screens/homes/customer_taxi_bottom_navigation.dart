import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/homes/customer_home.dart';
import 'package:kipgo/screens/rides/riders/ride_history_screen.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/screens/widgets/require_authentication_page.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CustomerTaxiBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const CustomerTaxiBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<CustomerTaxiBottomNavigation> createState() =>
      _CustomerTaxiBottomNavigationState();
}

class _CustomerTaxiBottomNavigationState
    extends State<CustomerTaxiBottomNavigation> {
  late int index;

  @override
  void initState() {
    super.initState();

    index = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // Guests don't need a notification token.
    if (!auth.isLoggedIn) return;

    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    context.read<InAppNotificationProvider>().listenToNotifications(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final loc = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();

    final screens = [
      const CustomerHome(),
      auth.isLoggedIn
          ? const RideHistoryScreen()
          : RequireAuthenticationPage(
              title: loc.yourRideHistory,
              message: loc.signInToView,
            ),
      // const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GNav(
            selectedIndex: index,

            onTabChange: (value) {
              setState(() {
                index = value;
              });
            },
            tabBorderRadius: 100,
            backgroundColor: Colors.transparent,
            color: isDark ? AppColors.darkLayer : AppColors.primary,
            activeColor: Colors.white,
            tabBackgroundColor: isDark
                ? AppColors.darkLayer
                : AppColors.primary,
            padding: const EdgeInsets.all(12),
            gap: 8,

            tabs: [
              GButton(icon: Icons.home_outlined, text: loc.home, haptic: true),

              GButton(
                icon: Icons.history_outlined,
                text: loc.rideHistory,
                haptic: true,
              ),

              GButton(
                icon: Icons.person_outline,
                text: loc.profile,
                haptic: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
