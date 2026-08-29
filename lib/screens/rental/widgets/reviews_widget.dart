import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/widgets/car_reviews_list.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewsWidget extends StatelessWidget {
  final String carId;
  const ReviewsWidget({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarRatingProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const CircularProgressIndicator.adaptive();
        }

        if (provider.ratings.isEmpty) {
          return Text(AppLocalizations.of(context)!.noReviewsYet);
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.reviewsInitCap} (${provider.ratings.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CarReviewsList(ratings: provider.ratings),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(width: 8),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.ratings.length > 5
                    ? 5
                    : provider.ratings.length,
                itemBuilder: (context, index) {
                  final rating = provider.ratings[index];
                  final avg =
                      (rating.vehicle.cleanliness +
                          rating.vehicle.comfort +
                          rating.vehicle.condition +
                          rating.vehicle.overall +
                          rating.vehicle.valueForMoney) /
                      5;

                  return Container(
                    padding: EdgeInsets.all(4),
                    width: provider.ratings.length == 1
                        ? MediaQuery.of(context).size.width - 24
                        : MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  foregroundImage: NetworkImage(
                                    rating.createdBy.photoUrl,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rating.createdBy.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    // SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          avg.toString(),
                                          // rating.carRating.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              timeago.format(rating.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            rating.details.review == ''
                                ? AppLocalizations.of(context)!.noComment
                                : rating.details.review,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
