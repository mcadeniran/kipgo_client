import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/rides/ride_details_screen.dart';
import 'package:kipgo/screens/rides/riders/rating_dialog.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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

    final isCompleted = ride.status == 'ended';
    final isCancelled = ride.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
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
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildTopRow(context, isCompleted, isCancelled),

                const SizedBox(height: 18),

                _buildRoute(context),

                const SizedBox(height: 18),

                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),

                const SizedBox(height: 14),

                _buildBottomRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(
    BuildContext context,
    bool isCompleted,
    bool isCancelled,
  ) {
    final loc = AppLocalizations.of(context)!;

    final statusColor = isCompleted
        ? Colors.green
        : isCancelled
        ? Colors.redAccent
        : Colors.orange;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_outline
                    : isCancelled
                    ? Icons.cancel_outlined
                    : Icons.timelapse,
                size: 15,
                color: statusColor,
              ),
              const SizedBox(width: 5),
              Text(
                _statusText(loc),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        Text(
          timeago.format(ride.time),
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 4),

        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_horiz, size: 20),
          onSelected: (value) {
            if (value == 'delete') {
              onDelete?.call();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(loc.deleteRide),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoute(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.radio_button_checked,
                size: 16,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),

            Container(
              width: 1,
              height: 38,
              color: Colors.blueGrey.withValues(alpha: 0.3),
            ),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routeText(context, loc.pickup, ride.originAddress),

              const SizedBox(height: 24),

              _routeText(context, loc.destination, ride.destinationAddress),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeText(BuildContext context, String label, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 15,
          color: Colors.blueGrey,
        ),

        const SizedBox(width: 6),

        Text(
          formatDate(ride.time, context),
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.blueGrey),
        ),

        const Spacer(),

        if (ride.isRated)
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              SizedBox(width: 3),
              Text(
                loc.rated,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          )
        else if (ride.status == 'ended')
          TextButton(
            onPressed: () {
              _showRatingDialog(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              loc.rateRide,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        const SizedBox(width: 4),

        const Icon(Icons.chevron_right_rounded, size: 20),
      ],
    );
  }

  String formatDate(DateTime date, BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return DateFormat('EEE, M/d/y', '$locale').format(date);
  }

  void _showRatingDialog(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (rating, reviews) async {
          final userP = context.read<ProfileProvider>().profile;

          if (userP == null) return;

          final review = Review(
            rating: rating,
            details: reviews,
            rideId: ride.id,
            reviewerId: userP.id,
            reviewerName: userP.username,
            reviewerPhotoUrl: userP.personal.photoUrl,
            createdAt: DateTime.now(),
          );

          try {
            final docRef = FirebaseFirestore.instance
                .collection("profiles")
                .doc(ride.driverId);

            await docRef.update({
              "personal.reviews": FieldValue.arrayUnion([review.toMap()]),
            });

            final rideRef = FirebaseDatabase.instance
                .ref()
                .child("All Ride Requests")
                .child(ride.id);

            await rideRef.update({"isRated": true});
          } catch (e) {
            if (context.mounted) {
              ReusableToast.error(
                context,
                loc.failedToSubmitReview,
                e.toString(),
              );
              debugPrint("Failed to submit review: $e");
            }
          }
        },
      ),
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
