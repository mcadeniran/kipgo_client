import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/rental/bookings/bookings_history.dart';
import 'package:kipgo/screens/rental/home/rental_home.dart';
import 'package:kipgo/screens/settings_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalBottomNavigation extends StatefulWidget {
  const RentalBottomNavigation({super.key});

  @override
  State<RentalBottomNavigation> createState() => _RentalBottomNavigationState();
}

class _RentalBottomNavigationState extends State<RentalBottomNavigation> {
  int index = 0;
  final screens = [RentalHome(), BookingsHistory(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: screens[index],
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
              label: 'Home',
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
              label: 'Bookings',
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
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
