import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/screens/rides/riders/ride_card.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/ride_history_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;

      if (profile != null) {
        context.read<RideHistoryProvider>().fetchUserRides(profile.id);
      }
    });
  }

  String getFilterLabel(String label) {
    switch (label) {
      case "All":
        return AppLocalizations.of(context)!.all;
      case "Completed":
        return AppLocalizations.of(context)!.completed;
      case "Cancelled":
        return AppLocalizations.of(context)!.cancelled;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideHistoryProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final filteredRides = _filteredRides(rideProvider.userRides);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: loc.rideHistory.toUpperCase()),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, rideProvider, isDark),

            _buildFilters(context),

            Expanded(
              child: rideProvider.isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : filteredRides.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: filteredRides.length,
                      itemBuilder: (context, index) {
                        final ride = filteredRides[index];

                        return RideCard(
                          ride: ride,
                          isDark: isDark,
                          onDelete: () async {
                            final confirm = await _showDeleteDialog(context);

                            if (confirm == true && context.mounted) {
                              await rideProvider.deleteRide(ride.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<RideHistory> _filteredRides(List<RideHistory> rides) {
    switch (_selectedFilter) {
      case 1:
        return rides.where((ride) => ride.status == 'ended').toList();

      case 2:
        return rides.where((ride) => ride.status == 'cancelled').toList();

      default:
        return rides;
    }
  }

  Widget _buildHeader(
    BuildContext context,
    RideHistoryProvider provider,
    bool isDark,
  ) {
    final loc = AppLocalizations.of(context)!;

    final completedCount = provider.userRides
        .where((ride) => ride.status == 'ended')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.yourJourneys,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.yourTravelHistory,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkAccent
                  : AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  completedCount.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  loc.trips,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedFilter == index;

          return ChoiceChip(
            label: Text(
              getFilterLabel(_filters[index]),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
            checkmarkColor: Colors.white,
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = index;
              });
            },
            selectedColor: isDark ? AppColors.darkLayer : AppColors.primary,
            backgroundColor: isDark
                ? AppColors.darkAccent
                : Colors.grey.shade100,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkAccent
                    : AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.route_outlined,
                size: 42,
                color: isDark ? AppColors.darkLayer : AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              loc.noJourneysYet,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              loc.yourCompletedTripsWIllAppear,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.local_taxi_outlined),
              label: Text(loc.bookARide),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.deleteRide),
        content: Text(loc.areYouSureRide),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }
}
