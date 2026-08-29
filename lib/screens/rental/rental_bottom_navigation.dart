import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/admin/admin_screen.dart';
import 'package:kipgo/screens/rental/bookings/bookings_history.dart';
import 'package:kipgo/screens/rental/home/rental_home.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const RentalBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<RentalBottomNavigation> createState() => _RentalBottomNavigationState();
}

class _RentalBottomNavigationState extends State<RentalBottomNavigation> {
  late int index;

  @override
  void initState() {
    super.initState();

    index = widget.initialIndex;

    final auth = context.read<AuthProvider>();
    final user = auth.profile;

    if (user != null) {
      context.read<InAppNotificationProvider>().listenToNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final auth = context.watch<AuthProvider>();
    final user = auth.profile;

    // ------------------------------------------------------------
    // Admin is only possible for authenticated users
    // ------------------------------------------------------------
    final isAdmin = user?.isAdmin == true;

    final screens = [
      const RentalHome(),
      // if (!isGuest)
      const BookingsHistory(),
      if (isAdmin) const AdminScreen(),
      const SettingsScreen(),
    ];

    // Keep index valid if the available tabs change.
    final safeIndex = index >= screens.length ? 0 : index;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
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
            onTabChange: (value) {
              setState(() {
                index = value;
              });
            },
            tabBorderRadius: 100,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
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

              // if (!isGuest)
              GButton(
                icon: Icons.calendar_today_outlined,
                text: loc.bookings,
                haptic: true,
                borderRadius: BorderRadius.circular(100),
              ),

              if (isAdmin)
                GButton(
                  icon: Icons.admin_panel_settings_outlined,
                  text: loc.admin,
                  haptic: true,
                  borderRadius: BorderRadius.circular(100),
                ),

              GButton(
                icon: Icons.person_outlined,
                text: loc.profile,
                haptic: true,
                borderRadius: BorderRadius.circular(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
