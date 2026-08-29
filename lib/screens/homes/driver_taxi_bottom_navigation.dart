import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/driver_rating_page.dart';
import 'package:kipgo/screens/rides/drivers/my_drives_screen.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

import 'driver_home.dart';

class DriverTaxiBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const DriverTaxiBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<DriverTaxiBottomNavigation> createState() =>
      _DriverTaxiBottomNavigationState();
}

class _DriverTaxiBottomNavigationState
    extends State<DriverTaxiBottomNavigation> {
  late int _index;

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final screens = <Widget>[
      const DriverHome(),
      const MyDrivesScreen(),
      const DriverRatingPage(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        color: backgroundColor,
        child: SafeArea(
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
              selectedIndex: _index,
              onTabChange: (value) {
                setState(() {
                  _index = value;
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
                GButton(icon: Icons.home_rounded, text: loc.home, haptic: true),
                GButton(
                  icon: Icons.local_taxi_rounded,
                  text: loc.myDrives,
                  haptic: true,
                ),
                GButton(
                  icon: Icons.star_rounded,
                  text: loc.myReviews,
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
      ),
    );
  }
}
