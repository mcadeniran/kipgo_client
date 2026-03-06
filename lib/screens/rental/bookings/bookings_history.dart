import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/rental/bookings/widgets/all_bookings.dart';
import 'package:kipgo/screens/rental/bookings/widgets/approved_booking.dart';
import 'package:kipgo/screens/rental/bookings/widgets/cancelled_booking.dart';
import 'package:kipgo/screens/rental/bookings/widgets/completed_booking.dart';
import 'package:kipgo/screens/rental/bookings/widgets/pending_booking.dart';
import 'package:kipgo/screens/rental/bookings/widgets/rejected_booking.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingsHistory extends StatelessWidget {
  const BookingsHistory({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'Booking History',
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
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
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
              AllBookings(),
              PendingBooking(),
              ApprovedBooking(),
              RejectedBooking(),
              CompletedBooking(),
              CancelledBooking(),
            ],
          ),
        ),
      ),
    );
  }
}
