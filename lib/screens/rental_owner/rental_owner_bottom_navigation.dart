import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental_owner/rental_owner_bookings.dart';
import 'package:kipgo/screens/rental_owner/rental_owner_home.dart';
import 'package:kipgo/screens/rental_owner/widgets/rental_owner_settings_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RenterOwnerBottomNavigation extends StatefulWidget {
  final int initialIndex;
  const RenterOwnerBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<RenterOwnerBottomNavigation> createState() =>
      _RenterOwnerBottomNavigationState();
}

class _RenterOwnerBottomNavigationState
    extends State<RenterOwnerBottomNavigation> {
  late int index;

  final screens = [
    RentalOwnerHome(),
    RentalOwnerBookings(),
    RentalOwnerSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;

    RentalShop shop = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).rentalShop!;

    Provider.of<InAppNotificationProvider>(
      context,
      listen: false,
    ).listenToNotifications(shop.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: isDark ? AppColors.darkLayer : AppColors.primary,
          indicatorShape: CircleBorder(),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          maintainBottomViewPadding: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          animationDuration: Duration(milliseconds: 800),
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: [
            NavigationDestination(
              icon: Iconify(
                Ic.outline_home,
                color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
                // size: 38,
              ),
              selectedIcon: Iconify(
                Ic.sharp_home,
                color: Colors.white,
                // size: 38,
              ),
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
            NavigationDestination(
              icon: Iconify(
                Ic.round_person_outline,
                color: isDark ? AppColors.lightLayer : AppColors.darkLayer,
                // size: 38,
              ),
              selectedIcon: Iconify(
                Ic.round_person,
                color: Colors.white,
                // size: 38,
              ),
              label: loc.profile,
            ),
          ],
        ),
      ),
    );
  }
}
