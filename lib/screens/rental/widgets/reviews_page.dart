import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_model.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/models/rating_distribution.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental/widgets/rating_summary_card.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum ReviewSortOption { mostRecent, highestRated, lowestRated }

class ReviewsPage extends StatefulWidget {
  final String title;

  /// Used when displaying company reviews.
  final RentalReview? shopReview;

  /// Used when displaying car reviews.
  final Review? carReview;

  /// Reviews to display.
  final List<CarRatingModel> reviews;

  final bool isCompanyReview;

  final RatingSummaryType type;

  const ReviewsPage({
    super.key,
    required this.title,
    required this.reviews,
    required this.isCompanyReview,
    required this.type,
    this.shopReview,
    this.carReview,
  }) : assert(
         shopReview != null || carReview != null,
         'Either shopReview or carReview must be provided',
       );

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  ReviewSortOption _sortOption = ReviewSortOption.mostRecent;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final bool isCompanyReview = widget.shopReview != null;

    final double average = isCompanyReview
        ? widget.shopReview!.average
        : widget.carReview!.average;

    final int totalReviews = isCompanyReview
        ? widget.shopReview!.totalReviews
        : widget.carReview!.totalReviews;

    final double recommendationRate = isCompanyReview
        ? widget.shopReview!.recommendationRate
        : widget.carReview!.recommendationRate;

    final distribution = isCompanyReview
        ? widget.shopReview!.distribution
        : _carDistribution(widget.carReview!, widget.reviews);

    final sortedReviews = _sortedReviews(widget.reviews);

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ============================================================
          // PREMIUM APP BAR
          // ============================================================
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.only(
                left: 52,
                right: 20,
                bottom: 16,
              ),
              title: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: .82),
                          AppColors.tertiary.withValues(alpha: .7),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: -70,
                    right: -50,
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .05),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -80,
                    left: -60,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .04),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 58, 20, 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  loc.verifiedReviews,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            loc.whatCustomersAreSaying,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: .85),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // RATING HERO
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkAccent
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ------------------------------------------------
                        // SCORE
                        // ------------------------------------------------
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              Text(
                                average.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 7),

                              _Stars(rating: average, size: 17),

                              const SizedBox(height: 7),

                              Text(
                                loc.numOfTotalReviews(totalReviews),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _DistributionChart(
                            distribution: distribution,
                            totalReviews: totalReviews,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    if (totalReviews > 0) ...[
                      const SizedBox(height: 18),

                      Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: .15),
                      ),

                      const SizedBox(height: 15),

                      // ------------------------------------------------
                      // RECOMMENDATION
                      // ------------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.lightLayer.withValues(
                                        alpha: 0.08,
                                      )
                                    : AppColors.primary.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                Icons.thumb_up_alt_rounded,
                                size: 17,
                                color: isDark
                                    ? AppColors.lightLayer
                                    : AppColors.primary,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                isCompanyReview
                                    ? loc.pctOfCustomersCompany(
                                        recommendationRate.toStringAsFixed(0),
                                      )
                                    : loc.pctOfCustomersCar(
                                        recommendationRate.toStringAsFixed(0),
                                      ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // CATEGORY SCORES
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
              child: _CategoryRatings(
                shopReview: widget.shopReview,
                carReview: widget.carReview,
                isDark: isDark,
              ),
            ),
          ),

          // ============================================================
          // REVIEW HEADER / SORT
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.customerReviews,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  PopupMenuButton<ReviewSortOption>(
                    initialValue: _sortOption,
                    onSelected: (value) {
                      setState(() {
                        _sortOption = value;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: ReviewSortOption.mostRecent,
                        child: Text(loc.mostRecent),
                      ),
                      PopupMenuItem(
                        value: ReviewSortOption.highestRated,
                        child: Text(loc.highestRated),
                      ),
                      PopupMenuItem(
                        value: ReviewSortOption.lowestRated,
                        child: Text(loc.lowestRated),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: .2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort_rounded, size: 16),
                          SizedBox(width: 5),
                          Text(
                            loc.sort,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // REVIEWS
          // ============================================================
          if (sortedReviews.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 50,
                ),
                child: _EmptyReviews(isDark: isDark),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final review = sortedReviews[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PremiumReviewCard(review: review, isDark: isDark),
                  );
                }, childCount: sortedReviews.length),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ),
        ],
      ),
    );
  }

  List<CarRatingModel> _sortedReviews(List<CarRatingModel> reviews) {
    final result = [...reviews];

    switch (_sortOption) {
      case ReviewSortOption.mostRecent:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case ReviewSortOption.highestRated:
        result.sort((a, b) => b.vehicle.overall.compareTo(a.vehicle.overall));
        break;

      case ReviewSortOption.lowestRated:
        result.sort((a, b) => a.vehicle.overall.compareTo(b.vehicle.overall));
        break;
    }

    return result;
  }

  RatingDistribution _carDistribution(
    Review review,
    List<CarRatingModel> reviews,
  ) {
    // We should eventually use the precomputed distribution
    // stored in Firestore. For now this creates it from the
    // reviews supplied to the page.
    int one = 0;
    int two = 0;
    int three = 0;
    int four = 0;
    int five = 0;

    for (final item in reviews) {
      switch (item.vehicle.overall) {
        case 1:
          one++;
          break;
        case 2:
          two++;
          break;
        case 3:
          three++;
          break;
        case 4:
          four++;
          break;
        case 5:
          five++;
          break;
      }
    }

    return RatingDistribution(
      one: one,
      two: two,
      three: three,
      four: four,
      five: five,
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final double size;

  const _Stars({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final difference = rating - index;

        IconData icon;

        if (difference >= 1) {
          icon = Icons.star_rounded;
        } else if (difference >= .5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        return Icon(icon, size: size, color: Colors.amber);
      }),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final RatingDistribution distribution;
  final int totalReviews;
  final bool isDark;

  const _DistributionChart({
    required this.distribution,
    required this.totalReviews,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final values = {
      5: distribution.five,
      4: distribution.four,
      3: distribution.three,
      2: distribution.two,
      1: distribution.one,
    };

    return Column(
      children: values.entries.map((entry) {
        final count = entry.value;

        final percentage = totalReviews == 0 ? 0.0 : count / totalReviews;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                child: Text(
                  '${entry.key}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 3),

              const Icon(Icons.star_rounded, size: 13, color: Colors.amber),

              const SizedBox(width: 7),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: .08)
                        : Colors.grey.withValues(alpha: .13),
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              SizedBox(
                width: 22,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryRatings extends StatelessWidget {
  final RentalReview? shopReview;
  final Review? carReview;
  final bool isDark;

  const _CategoryRatings({
    required this.shopReview,
    required this.carReview,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final List<_CategoryRating> ratings;
    AppLocalizations loc = AppLocalizations.of(context)!;

    if (shopReview != null) {
      ratings = [
        _CategoryRating(
          label: loc.communication,
          value: shopReview!.communication,
          icon: Icons.chat_bubble_outline_rounded,
        ),
        _CategoryRating(
          label: loc.pickupExperience,
          value: shopReview!.pickupExperience,
          icon: Icons.key_rounded,
        ),
        _CategoryRating(
          label: loc.professionalism,
          value: shopReview!.professionalism,
          icon: Icons.workspace_premium_outlined,
        ),
        _CategoryRating(
          label: loc.returnExperience,
          value: shopReview!.returnExperience,
          icon: Icons.assignment_return_outlined,
        ),
      ];
    } else {
      ratings = [
        _CategoryRating(
          label: loc.cleanliness,
          value: carReview!.cleanliness,
          icon: Icons.cleaning_services_outlined,
        ),
        _CategoryRating(
          label: loc.comfort,
          value: carReview!.comfort,
          icon: Icons.airline_seat_recline_normal_outlined,
        ),
        _CategoryRating(
          label: loc.condition,
          value: carReview!.condition,
          icon: Icons.directions_car_outlined,
        ),
        _CategoryRating(
          label: loc.valueForMoney,
          value: carReview!.valueForMoney,
          icon: Icons.payments_outlined,
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.ratingBreakdown,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 4),
            itemCount: ratings.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final item = ratings[index];

              return Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.lightLayer.withValues(alpha: 0.08)
                          : AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 16,
                      color: isDark ? AppColors.lightLayer : AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.value.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryRating {
  final String label;
  final double value;
  final IconData icon;

  const _CategoryRating({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _PremiumReviewCard extends StatelessWidget {
  final CarRatingModel review;
  final bool isDark;

  const _PremiumReviewCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final details = review.details;

    AppLocalizations loc = AppLocalizations.of(context)!;

    final bool anonymous = details.isAnonymous;

    final String name = anonymous
        ? loc.anonymous
        : review.createdBy.name.trim().isEmpty
        ? loc.customer
        : review.createdBy.name;

    final String photoUrl = anonymous ? '' : review.createdBy.photoUrl;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // USER
          // ============================================================
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.primary.withValues(alpha: .08),
                backgroundImage: !anonymous && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (!anonymous) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      formatDate(review.createdAt, context),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.vehicle.overall}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ============================================================
          // TITLE
          // ============================================================
          if (details.title.trim().isNotEmpty) ...[
            const SizedBox(height: 13),

            Text(
              details.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],

          // ============================================================
          // REVIEW
          // ============================================================
          if (details.review.trim().isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              details.review,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.55),
            ),
          ],

          // ============================================================
          // PROS
          // ============================================================
          if (details.pros.isNotEmpty) ...[
            const SizedBox(height: 13),

            _ReviewTags(
              title: loc.whatTheyLiked,
              icon: Icons.thumb_up_alt_outlined,
              values: details.pros,
              isPositive: true,
              isDark: isDark,
            ),
          ],

          // ============================================================
          // CONS
          // ============================================================
          if (details.cons.isNotEmpty) ...[
            const SizedBox(height: 8),

            _ReviewTags(
              title: loc.couldBeImproved,
              icon: Icons.thumb_down_alt_outlined,
              values: details.cons,
              isPositive: false,
              isDark: isDark,
            ),
          ],

          // ============================================================
          // PHOTOS
          // ============================================================
          if (details.ratingPhoto.isNotEmpty) ...[
            const SizedBox(height: 14),

            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: details.ratingPhoto.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photo = details.ratingPhoto[index];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photo.url,
                      height: 76,
                      width: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          height: 76,
                          width: 76,
                          color: Colors.grey.withValues(alpha: .1),
                          child: const Icon(Icons.image_not_supported_outlined),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          // ============================================================
          // RECOMMENDATION
          // ============================================================
          if (details.wouldRecommend || details.wouldRentAgain) ...[
            const SizedBox(height: 14),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (details.wouldRecommend)
                  _MiniBadge(
                    icon: Icons.thumb_up_alt_outlined,
                    label: loc.wouldRecommend,
                    isDark: isDark,
                  ),

                if (details.wouldRentAgain)
                  _MiniBadge(
                    icon: Icons.refresh_rounded,
                    label: loc.wouldRentAgain,
                    isDark: isDark,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String formatDate(DateTime date, BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return DateFormat('EEE, MMM d, yyyy', '$locale').format(date);
  }
}

class _ReviewTags extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> values;
  final bool isPositive;
  final bool isDark;

  const _ReviewTags({
    required this.title,
    required this.icon,
    required this.values,
    required this.isPositive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isPositive ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values.map((value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withValues(alpha: .07)
                    : Colors.orange.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final bool isDark;

  const _EmptyReviews({required this.isDark});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .07),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.rate_review_outlined,
            size: 30,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          loc.noReviewsYet,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 6),

        Text(
          loc.beTheFirst,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
        ),
      ],
    );
  }
}
