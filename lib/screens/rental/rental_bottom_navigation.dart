import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
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
    final user = auth.profile!;

    Provider.of<InAppNotificationProvider>(
      context,
      listen: false,
    ).listenToNotifications(user.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    final user = context.read<AuthProvider>().profile!;
    final isAdmin = user.isAdmin;

    final screens = [
      RentalHome(),
      BookingsHistory(),
      if (isAdmin) AdminScreen(),
      SettingsScreen(),
    ];

    final destinations = [
      NavigationDestination(
        icon: Iconify(
          Ic.outline_home,
          color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
        ),
        selectedIcon: Iconify(Ic.sharp_home, color: Colors.white),
        label: loc.home,
      ),
      NavigationDestination(
        icon: Iconify(
          Ic.outline_calendar_today,
          color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
          size: 22,
        ),
        selectedIcon: Iconify(
          Ic.round_calendar_today,
          color: Colors.white,
          size: 22,
        ),
        label: loc.bookings,
      ),

      if (isAdmin)
        NavigationDestination(
          icon: Iconify(
            Ic.round_admin_panel_settings,
            color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
          ),
          selectedIcon: Iconify(
            Ic.round_admin_panel_settings,
            color: Colors.white,
          ),
          label: loc.admin,
        ),

      NavigationDestination(
        icon: Iconify(
          Ic.round_person_outline,
          color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
        ),
        selectedIcon: Iconify(Ic.round_person, color: Colors.white),
        label: loc.profile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: isDark ? AppColors.darkLayer : AppColors.primary,
          indicatorShape: const CircleBorder(),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          maintainBottomViewPadding: true,
          selectedIndex: index,
          onDestinationSelected: (value) {
            setState(() {
              index = value;
            });
          },
          destinations: destinations,
        ),
      ),
    );
  }
}
