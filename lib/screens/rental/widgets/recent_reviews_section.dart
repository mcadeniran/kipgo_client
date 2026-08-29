import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentReviewsSection extends StatelessWidget {
  final List<CarRatingModel> reviews;
  final VoidCallback onSeeAll;

  const RecentReviewsSection({
    super.key,
    required this.reviews,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayedReviews = reviews.take(3).toList();

    AppLocalizations loc = AppLocalizations.of(context)!;

    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.recentReviews,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.seeAll,
                    style: TextStyle(
                      color: isDark ? AppColors.lightLayer : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ...displayedReviews.map((review) => _ReviewPreviewCard(review: review)),
      ],
    );
  }
}

class _ReviewPreviewCard extends StatelessWidget {
  final CarRatingModel review;

  const _ReviewPreviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final anonymous = review.details.isAnonymous;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: anonymous || review.createdBy.photoUrl.isEmpty
                    ? const AssetImage('assets/images/avatar.png')
                    : NetworkImage(review.createdBy.photoUrl) as ImageProvider,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anonymous ? loc.anonymous : review.createdBy.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeago.format(review.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
              ),

              _MiniRating(rating: review.rental.overall.toDouble()),
            ],
          ),

          if (review.details.title.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.details.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],

          if (review.details.review.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              review.details.review,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: .75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniRating extends StatelessWidget {
  final double rating;

  const _MiniRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
