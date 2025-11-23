import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rides/riders/rating_dialog.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/ride_history_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/rides/ride_details_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String? reviews;
  double rating = 2.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<ProfileProvider>().profile!.id;
      context.read<RideHistoryProvider>().fetchUserRides(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideHistoryProvider>();
    final isDark = context.read<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.rideHistory.toUpperCase(),
      ),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(12),
        child: Builder(
          builder: (_) {
            if (rideProvider.isLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (rideProvider.userRides.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noRideFound),
              );
            }
            return AnimatedList(
              key: _listKey,
              initialItemCount: rideProvider.userRides.length,
              itemBuilder: (context, index, animation) {
                final ride = rideProvider.userRides[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: RideCard(
                    ride: ride,
                    isDark: isDark,
                    onDelete: () async {
                      final confirm = await _showDeleteDialog(context);
                      if (confirm == true) {
                        if (!context.mounted) return;
                        _deleteRideOptimistically(
                          context,
                          rideProvider,
                          ride,
                          index,
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  void _deleteRideOptimistically(
    BuildContext context,
    RideHistoryProvider provider,
    RideHistory ride,
    int index,
  ) async {
    // Remove from UI with animation
    final removedRide = ride;
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: RideCard(
          ride: removedRide,
          isDark: context.read<ThemeProvider>().isDarkMode,
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    try {
      await provider.deleteRide(removedRide.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.rideDeletedSuccessfully,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Rollback UI (reinsert ride)
      provider.restoreRide(removedRide, index);
      _listKey.currentState?.insertItem(index);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.errorDeletingRide} $e",
            ),
            backgroundColor: AppColors.tertiary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class RideCard extends StatelessWidget {
  final RideHistory ride;
  final bool isDark;
  final VoidCallback? onDelete;

  const RideCard({
    super.key,
    required this.ride,
    required this.isDark,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      color: isDark ? AppColors.darkAccent : Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: ride.driverId == 'waiting'
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RideDetailsScreen(
                      title: loc.rideDetails,
                      isRider: true,
                      history: ride,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeago.format(ride.time),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (!ride.isRated)
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => RatingDialog(
                          onSubmit: (rating, reviews) async {
                            final userP = Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            ).profile;

                            final review = Review(
                              rating: rating,
                              details: reviews,
                              rideId: ride.id,
                              reviewerId: userP!.id,
                              reviewerName: userP.username,
                              reviewerPhotoUrl: userP.personal.photoUrl,
                              createdAt: DateTime.now(),
                            );

                            // Update driver profile
                            try {
                              // 1️⃣ Save review to driver Firestore profile
                              final docRef = FirebaseFirestore.instance
                                  .collection("profiles")
                                  .doc(ride.driverId);

                              await docRef.update({
                                "personal.reviews": FieldValue.arrayUnion([
                                  review.toMap(),
                                ]),
                              });

                              // 2️⃣ Mark ride as rated in Realtime Database
                              final rideRef = FirebaseDatabase.instance
                                  .ref()
                                  .child("All Ride Requests")
                                  .child(ride.id);

                              await rideRef.update({"isRated": true});
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Failed to submit review: $e",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.rateRide),
                    ),
                  if (ride.isRated)
                    Icon(Icons.star_outline_sharp, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 6),
              _buildAddressRow(
                Icons.location_on,
                Colors.indigo,
                ride.originAddress,
              ),
              const SizedBox(height: 12),
              _buildAddressRow(
                Icons.flag,
                Colors.redAccent,
                ride.destinationAddress,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusText(loc),
                    style: TextStyle(
                      color: ride.status == 'ended' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: IconButton(
                      style: IconButton.styleFrom(padding: EdgeInsets.zero),
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  String _statusText(AppLocalizations loc) {
    switch (ride.status) {
      case 'accepted':
        return loc.rideAccepted;
      case 'arrived':
        return loc.rideArrived;
      case 'ontrip':
        return loc.rideOnTrip;
      case 'ended':
        return loc.rideEnded;
      case 'cancelled':
        return loc.cancelled;
      default:
        return loc.rideUnknown;
    }
  }
}
