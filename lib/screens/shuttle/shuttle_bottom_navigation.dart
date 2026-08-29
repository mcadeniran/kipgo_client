import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/screens/shuttle/bookings/shuttle_bookings_page.dart';
import 'package:kipgo/screens/shuttle/home/shuttle_home.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleBottomNavigation extends StatefulWidget {
  final int initialIndex;
  const ShuttleBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<ShuttleBottomNavigation> createState() =>
      _ShuttleBottomNavigationState();
}

class _ShuttleBottomNavigationState extends State<ShuttleBottomNavigation> {
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
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    final screens = [ShuttleHome(), ShuttleBookingsPage(), SettingsScreen()];

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
              GButton(
                icon: Icons.home_outlined,
                text: loc.home,
                haptic: true,
                borderRadius: BorderRadius.circular(100),
              ),
              GButton(
                icon: Icons.calendar_today_outlined,
                text: loc.bookings,
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
