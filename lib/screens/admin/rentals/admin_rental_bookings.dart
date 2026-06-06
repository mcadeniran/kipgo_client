import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/admin/rentals/admin_bookings/admin_booking_list_tab.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum AdminBookingTabType { attention, upcoming, ongoing, completed, closed }

class AdminRentalBookings extends StatelessWidget {
  const AdminRentalBookings({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 5,
      child: Container(
        color: AppColors.primary,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              indicatorColor: isDark ? Colors.white : AppColors.lightLayer,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              padding: EdgeInsets.all(0),
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: loc.attention),
                Tab(text: loc.upcoming),
                Tab(text: loc.ongoing),
                Tab(text: loc.completed),
                Tab(text: loc.closed),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AdminBookingListTab(type: AdminBookingTabType.attention),
                  AdminBookingListTab(type: AdminBookingTabType.upcoming),
                  AdminBookingListTab(type: AdminBookingTabType.ongoing),
                  AdminBookingListTab(type: AdminBookingTabType.completed),
                  AdminBookingListTab(type: AdminBookingTabType.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
