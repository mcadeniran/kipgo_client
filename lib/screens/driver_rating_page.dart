import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
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
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.myReviews.toUpperCase(),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            final reviews = profileProvider.profile!.personal.reviews;

            if (reviews.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.youHaveNoReviews,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }

            // Sort newest → oldest
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Calculate average rating

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Summary Section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    color: isDark ? AppColors.darkAccent : Colors.grey[50],
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Average rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileProvider.profile!.personal.rating
                                  .toStringAsFixed(1),
                              // avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            StarRating(
                              rating: profileProvider.profile!.personal.rating
                                  .roundToDouble(),
                              // rating: avgRating.roundToDouble(),
                              allowHalfRating: true,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${reviews.length} ${AppLocalizations.of(context)!.reviews}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        // Optional icon/visual
                        Icon(
                          Icons.star_rate_rounded,
                          color: Colors.amber,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Reviews List
                Expanded(
                  child: ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDark ? AppColors.darkAccent : Colors.grey[50],
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reviewer photo
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    review.reviewerPhotoUrl.isNotEmpty
                                    ? NetworkImage(review.reviewerPhotoUrl)
                                    : null,
                                backgroundColor: Colors.grey.shade300,
                                child: review.reviewerPhotoUrl.isEmpty
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Review details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reviewer name + timestamp
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review.reviewerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          timeago.format(review.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Rating stars
                                    StarRating(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      rating: review.rating,
                                      allowHalfRating: true,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(height: 8),

                                    // Review text
                                    if (review.details != null &&
                                        review.details!.isNotEmpty)
                                      Text(
                                        review.details!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
