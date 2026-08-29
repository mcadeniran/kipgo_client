import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/bookings/booking_history_tab.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/require_authentication_page.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum BookingSection { attention, upcoming, ongoing, closed, completed }

class BookingsHistory extends StatefulWidget {
  const BookingsHistory({super.key});

  @override
  State<BookingsHistory> createState() => _BookingsHistoryState();
}

class _BookingsHistoryState extends State<BookingsHistory> {
  String? _listeningUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBookingListenerIfPossible();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBookingListenerIfPossible();
    });
  }

  void _startBookingListenerIfPossible() {
    if (!mounted) return;

    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    if (_listeningUserId == profile.id) return;

    _listeningUserId = profile.id;

    context.read<BookingProvider>().listenToUserBookings(profile.id);
  }

  void _handleAuthenticated() {
    if (!mounted) return;

    _startBookingListenerIfPossible();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return RequireAuthenticationPage(
        title: loc.yourBookings,
        message: loc.yourBookingsAuthRequired,
        onAuthenticated: _handleAuthenticated,
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBarWidget(
          title: loc.bookingHistory,
          bottomWidget: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            indicatorPadding: const EdgeInsets.only(bottom: 4),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: loc.attention),
              Tab(text: loc.upcoming),
              Tab(text: loc.ongoing),
              Tab(text: loc.completed),
              Tab(text: loc.closed),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: const TabBarView(
            children: [
              BookingHistoryTab(section: BookingSection.attention),
              BookingHistoryTab(section: BookingSection.upcoming),
              BookingHistoryTab(section: BookingSection.ongoing),
              BookingHistoryTab(section: BookingSection.completed),
              BookingHistoryTab(section: BookingSection.closed),
            ],
          ),
        ),
      ),
    );
  }
}
