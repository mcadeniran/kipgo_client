import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/booking_details/shuttle_booking_details_page.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/empty/shuttle_booking_empty_state.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/shuttle_booking_list.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_provider.dart';
import '../../../controllers/shuttle_bookings_provider.dart';
import '../../../models/shuttle_booking/shuttle_booking_group.dart';
import 'package:iconify_flutter/icons/game_icons.dart';

class ShuttleBookingsPage extends StatefulWidget {
  const ShuttleBookingsPage({super.key});

  @override
  State<ShuttleBookingsPage> createState() => _ShuttleBookingsPageState();
}

class _ShuttleBookingsPageState extends State<ShuttleBookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late ShuttleBookingsProvider _bookingsProvider;

  @override
  void initState() {
    super.initState();

    _bookingsProvider = context.read<ShuttleBookingsProvider>();

    _tabController = TabController(
      length: ShuttleBookingGroup.values.length,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialBookings();
    });
  }

  @override
  void dispose() {
    _bookingsProvider.stopWatching();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialBookings() async {
    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    final provider = context.read<ShuttleBookingsProvider>();

    await provider.initialize(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Consumer<ShuttleBookingsProvider>(
      builder: (_, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              loc.myShuttleBookings,
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
              controller: _tabController,
              tabs: [
                _buildTab(
                  loc.attention,
                  provider.count(ShuttleBookingGroup.attention),
                ),
                _buildTab(
                  loc.upcoming,
                  provider.count(ShuttleBookingGroup.upcoming),
                ),
                _buildTab(
                  loc.ongoing,
                  provider.count(ShuttleBookingGroup.ongoing),
                ),
                _buildTab(
                  loc.completed,
                  provider.count(ShuttleBookingGroup.completed),
                ),
                _buildTab(
                  loc.closed,
                  provider.count(ShuttleBookingGroup.closed),
                ),
              ],
            ),
          ),
          backgroundColor: AppColors.primary,

          body: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: TabBarView(
              controller: _tabController,
              children: const [
                _BookingsTab(group: ShuttleBookingGroup.attention),
                _BookingsTab(group: ShuttleBookingGroup.upcoming),
                _BookingsTab(group: ShuttleBookingGroup.ongoing),
                _BookingsTab(group: ShuttleBookingGroup.completed),
                _BookingsTab(group: ShuttleBookingGroup.closed),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),

          if (count > 0) ...[
            const SizedBox(width: 6),

            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.lightLayer,
              child: Text("$count", style: const TextStyle(fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  final ShuttleBookingGroup group;

  const _BookingsTab({required this.group});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    String getEmptyTitle(ShuttleBookingGroup group) {
      switch (group.name) {
        case 'attention':
          return loc.allCaughtUp;
        case 'upcoming':
          return loc.noUpcomingJourneys;
        case 'ongoing':
          return loc.noActiveJourney;
        case 'completed':
          return loc.noCompletedJourney;
        case 'closed':
          return loc.noClosedBookings;
        default:
          return '';
      }
    }

    String getEmptyMessage(ShuttleBookingGroup group) {
      switch (group.name) {
        case 'attention':
          return loc.allCaughtUpSubtitle;
        case 'upcoming':
          return loc.noUpcomingJourneysSubtitle;
        case 'ongoing':
          return loc.noActiveJourneySubtitle;
        case 'completed':
          return loc.noCompletedJourneySubtitle;
        case 'closed':
          return loc.noClosedBookingsSubtitle;
        default:
          return '';
      }
    }

    return Consumer2<ShuttleBookingsProvider, ProfileProvider>(
      builder: (context, provider, profileProvider, _) {
        // final state = provider.state(group);

        final profile = profileProvider.profile;

        if (profile == null) {
          return const SizedBox.shrink();
        }

        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // if (state.loading && state.bookings.isEmpty) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        if (provider.error != null) {
          print(provider.error);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),

                  const SizedBox(height: 16),

                  Text(
                    provider.error ?? loc.somethingWentWrong,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // FilledButton(
                  //   onPressed: () {
                  //     provider.refresh(userId: profile.id, group: group);
                  //   },
                  //   child: Text(loc.retry),
                  // ),
                ],
              ),
            ),
          );
        }

        final bookings = provider.bookings(group);

        if (bookings.isEmpty) {
          return ShuttleBookingEmptyState(
            title: getEmptyTitle(group),
            subtitle: getEmptyMessage(group),
            iconify: GameIcons.cardboard_box,
          );
        }

        return ShuttleBookingList(
          bookings: bookings,

          // onRefresh: () async {
          //   switch (group) {
          //     case ShuttleBookingGroup.completed:
          //     case ShuttleBookingGroup.closed:
          //       // await provider.refresh(userId: profile.id, group: group);
          //       break;

          //     default:
          //       return;
          //   }
          // },
          onBookingTap: (booking) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ShuttleBookingDetailsPage(bookingId: booking.id),
              ),
            );
          },
        );
      },
    );
  }
}
