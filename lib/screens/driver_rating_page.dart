import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class DriverRatingPage extends StatelessWidget {
  const DriverRatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: loc.myReviews.toUpperCase()),
      body: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            final profile = profileProvider.profile;

            if (profile == null) {
              return _buildEmptyState(
                context,
                icon: Icons.person_outline_rounded,
                message: loc.youHaveNoReviews,
                isDark: isDark,
              );
            }

            // Copy the list before sorting so we don't mutate
            // the profile provider's underlying list.
            final reviews = List.of(profile.personal.reviews)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final averageRating = profile.personal.rating;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
              children: [
                _buildRatingHero(
                  context,
                  averageRating: averageRating,
                  reviewCount: reviews.length,
                  isDark: isDark,
                  loc: loc,
                ),

                const SizedBox(height: 16),

                if (reviews.isNotEmpty) ...[
                  _buildRatingDistribution(
                    context,
                    reviews: reviews,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        loc.reviews,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReviewCard(
                        context,
                        review: review,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ] else
                  _buildEmptyState(
                    context,
                    icon: Icons.rate_review_outlined,
                    message: loc.youHaveNoReviews,
                    isDark: isDark,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RATING HERO
  // ---------------------------------------------------------------------------

  Widget _buildRatingHero(
    BuildContext context, {
    required double averageRating,
    required int reviewCount,
    required bool isDark,
    required AppLocalizations loc,
  }) {
    final backgroundColor = isDark ? AppColors.darkAccent : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
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
              // Rating number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.myReviews,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ 5.0',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    StarRating(
                      rating: averageRating,
                      allowHalfRating: true,
                      color: Colors.amber,
                      size: 20,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      loc.numOfTotalReviews(reviewCount),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative rating icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withValues(alpha: 0.16),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.yourPassengerFeedback,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RATING DISTRIBUTION
  // ---------------------------------------------------------------------------

  Widget _buildRatingDistribution(
    BuildContext context, {
    required List reviews,
    required bool isDark,
  }) {
    final backgroundColor = isDark ? AppColors.darkAccent : Colors.white;

    final total = reviews.length;

    final loc = AppLocalizations.of(context)!;

    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final review in reviews) {
      final rating = review.rating.round().clamp(1, 5);
      counts[rating] = (counts[rating] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.ratingBreakdown,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          for (int rating = 5; rating >= 1; rating--)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '$rating',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: total == 0 ? 0 : counts[rating]! / total,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    width: 22,
                    child: Text(
                      '${counts[rating]}',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REVIEW CARD
  // ---------------------------------------------------------------------------

  Widget _buildReviewCard(
    BuildContext context, {
    required dynamic review,
    required bool isDark,
  }) {
    final backgroundColor = isDark ? AppColors.darkAccent : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: isDark
                      ? AppColors.darkLayer
                      : Colors.grey.shade100,
                  backgroundImage: review.reviewerPhotoUrl.isNotEmpty
                      ? NetworkImage(review.reviewerPhotoUrl)
                      : null,
                  child: review.reviewerPhotoUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 26,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    StarRating(
                      mainAxisAlignment: MainAxisAlignment.start,
                      rating: review.rating,
                      allowHalfRating: true,
                      color: Colors.amber,
                      size: 15,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                timeago.format(review.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            ],
          ),

          if (review.details != null && review.details!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.grey.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 18,
                    color: AppColors.tertiary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.details!.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required bool isDark,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: .08)
                    : AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 38,
                color: isDark
                    ? AppColors.lightLayer
                    : AppColors.primary.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              loc.passengerFeedbackWillAppearHere,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class DriverRatingPage extends StatelessWidget {
//   const DriverRatingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBarWidget(
//         title: AppLocalizations.of(context)!.myReviews.toUpperCase(),
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Consumer<ProfileProvider>(
//           builder: (context, profileProvider, _) {
//             if (profileProvider.isLoading) {
//               return const Center(child: CircularProgressIndicator.adaptive());
//             }

//             final reviews = profileProvider.profile!.personal.reviews;

//             if (reviews.isEmpty) {
//               return Center(
//                 child: Text(
//                   AppLocalizations.of(context)!.youHaveNoReviews,
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                 ),
//               );
//             }

//             // Sort newest → oldest
//             reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//             // Calculate average rating

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 🔹 Summary Section
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.border),
//                     color: isDark ? AppColors.darkAccent : Colors.grey[50],
//                   ),
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Average rating
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               profileProvider.profile!.personal.rating
//                                   .toStringAsFixed(1),
//                               // avgRating.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             StarRating(
//                               rating: profileProvider.profile!.personal.rating
//                                   .roundToDouble(),
//                               // rating: avgRating.roundToDouble(),
//                               allowHalfRating: true,
//                               color: Colors.amber,
//                               size: 18,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "${reviews.length} ${AppLocalizations.of(context)!.reviews}",
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Optional icon/visual
//                         Icon(
//                           Icons.star_rate_rounded,
//                           color: Colors.amber,
//                           size: 30,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // 🔹 Reviews List
//                 Expanded(
//                   child: ListView.separated(
//                     itemCount: reviews.length,
//                     separatorBuilder: (_, _) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final review = reviews[index];
//                       return Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         color: isDark ? AppColors.darkAccent : Colors.grey[50],
//                         elevation: 0,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Reviewer photo
//                               CircleAvatar(
//                                 radius: 25,
//                                 backgroundImage:
//                                     review.reviewerPhotoUrl.isNotEmpty
//                                     ? NetworkImage(review.reviewerPhotoUrl)
//                                     : null,
//                                 backgroundColor: Colors.grey.shade300,
//                                 child: review.reviewerPhotoUrl.isEmpty
//                                     ? const Icon(Icons.person, size: 30)
//                                     : null,
//                               ),
//                               const SizedBox(width: 12),

//                               // Review details
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Reviewer name + timestamp
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           review.reviewerName,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 15,
//                                           ),
//                                         ),
//                                         Text(
//                                           timeago.format(review.createdAt),
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 6),

//                                     // Rating stars
//                                     StarRating(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       rating: review.rating,
//                                       allowHalfRating: true,
//                                       color: Colors.amber,
//                                       size: 14,
//                                     ),
//                                     const SizedBox(height: 8),

//                                     // Review text
//                                     if (review.details != null &&
//                                         review.details!.isNotEmpty)
//                                       Text(
//                                         review.details!,
//                                         style: const TextStyle(fontSize: 14),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
