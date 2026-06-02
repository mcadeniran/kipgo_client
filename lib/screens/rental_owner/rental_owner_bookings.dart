import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental_owner/widgets/booking_list_tab.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum BookingTabType { attention, upcoming, ongoing, completed, closed }

class RentalOwnerBookings extends StatelessWidget {
  const RentalOwnerBookings({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            loc.bookings,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actions: [LanguageWidget()],
          actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 8,
          bottom: TabBar(
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
        ),
        body: const TabBarView(
          children: [
            BookingListTab(type: BookingTabType.attention),
            BookingListTab(type: BookingTabType.upcoming),
            BookingListTab(type: BookingTabType.ongoing),
            BookingListTab(type: BookingTabType.completed),
            BookingListTab(type: BookingTabType.closed),
          ],
        ),
      ),
    );
  }
}
