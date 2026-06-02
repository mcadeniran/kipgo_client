import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/bookings/booking_history_tab.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum BookingSection { attention, upcoming, ongoing, closed, cancelled }

class BookingsHistory extends StatefulWidget {
  const BookingsHistory({super.key});

  @override
  State<BookingsHistory> createState() => _BookingsHistoryState();
}

class _BookingsHistoryState extends State<BookingsHistory> {
  @override
  void initState() {
    super.initState();

    final uid = context.read<ProfileProvider>().profile!.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // context.read<BookingProvider>().loadBookings(uid);
      context.read<BookingProvider>().listenToUserBookings(uid);
    });
  }

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
            loc.bookingHistory,
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
              Tab(text: loc.closed),
              Tab(text: loc.cancelled),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: TabBarView(
            children: [
              BookingHistoryTab(section: BookingSection.attention),
              BookingHistoryTab(section: BookingSection.upcoming),
              BookingHistoryTab(section: BookingSection.ongoing),
              BookingHistoryTab(section: BookingSection.closed),
              BookingHistoryTab(section: BookingSection.cancelled),
            ],
          ),
        ),
      ),
    );
  }
}
