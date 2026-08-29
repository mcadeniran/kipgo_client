import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalReviewSummary extends StatelessWidget {
  final RentalReview review;
  final List<CarRatingModel> reviews;
  final VoidCallback? onSeeAll;
  final String title;

  const RentalReviewSummary({
    super.key,
    required this.review,
    required this.reviews,
    this.onSeeAll,
    this.title = 'Customer Reviews',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(onPressed: onSeeAll, child: const Text('See All')),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------------
          // OVERALL + DISTRIBUTION
          // ------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text(
                      review.average.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.average.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${review.totalReviews} reviews',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _RatingDistribution(review: review, isDark: isDark),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------------
          // RECOMMENDATION
          // ------------------------------------------------------------
          if (review.totalReviews > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      '${review.recommendationRate.toStringAsFixed(0)}% of customers would recommend this company',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ------------------------------------------------------------
          // REVIEW PREVIEWS
          // ------------------------------------------------------------
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Reviews',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...reviews
                .take(3)
                .map(
                  (reviewItem) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewPreviewCard(
                      review: reviewItem,
                      isDark: isDark,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  final RentalReview review;
  final bool isDark;

  const _RatingDistribution({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final distribution = review.distribution;

    final values = <int, int>{
      5: distribution.five,
      4: distribution.four,
      3: distribution.three,
      2: distribution.two,
      1: distribution.one,
    };

    return Column(
      children: values.entries.map((entry) {
        final rating = entry.key;
        final count = entry.value;

        final percentage = review.totalReviews == 0
            ? 0.0
            : count / review.totalReviews;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                child: Text(
                  '$rating',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              const Icon(Icons.star_rounded, size: 13, color: Colors.amber),

              const SizedBox(width: 6),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: .08)
                        : Colors.grey.withValues(alpha: .12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amber,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              SizedBox(
                width: 22,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ReviewPreviewCard extends StatelessWidget {
  final CarRatingModel review;
  final bool isDark;

  const _ReviewPreviewCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final details = review.details;

    final displayName = details.isAnonymous
        ? 'Anonymous'
        : review.createdBy.name.trim().isEmpty
        ? 'Customer'
        : review.createdBy.name;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .035)
            : Colors.grey.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundImage:
                    !details.isAnonymous && review.createdBy.photoUrl.isNotEmpty
                    ? NetworkImage(review.createdBy.photoUrl)
                    : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _formatReviewDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.vehicle.overall
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),

          if (details.title.isNotEmpty) ...[
            const SizedBox(height: 9),

            Text(
              details.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],

          if (details.review.isNotEmpty) ...[
            const SizedBox(height: 4),

            Text(
              details.review,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
