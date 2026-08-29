import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/booking_details/shuttle_booking_details_page.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/empty/shuttle_booking_empty_state.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_bookings/shuttle_booking_list.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/require_authentication_page.dart';
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
  late final ShuttleBookingsProvider _bookingsProvider;

  String? _initializedUserId;

  @override
  void initState() {
    super.initState();

    _bookingsProvider = context.read<ShuttleBookingsProvider>();

    _tabController = TabController(
      length: ShuttleBookingGroup.values.length,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForCurrentUser();
    });
  }

  Future<void> _initializeForCurrentUser() async {
    if (!mounted) return;

    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    if (_initializedUserId == profile.id) return;

    _initializedUserId = profile.id;

    await _bookingsProvider.initialize(profile.id);
  }

  @override
  void dispose() {
    _bookingsProvider.stopWatching();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return RequireAuthenticationPage(
        title: loc.yourBookings,
        message: loc.yourBookingsAuthRequired,
        onAuthenticated: _initializeForCurrentUser,
      );
    }

    return Consumer<ShuttleBookingsProvider>(
      builder: (_, provider, _) {
        return Scaffold(
          appBar: AppBarWidget(
            title: loc.myShuttleBookings,
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
        final profile = profileProvider.profile;

        if (profile == null) {
          return const SizedBox.shrink();
        }

        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
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
