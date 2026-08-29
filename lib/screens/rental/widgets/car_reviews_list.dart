import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CarReviewsList extends StatelessWidget {
  final List<CarRatingModel> ratings;
  const CarReviewsList({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: AppLocalizations.of(context)!.reviewsInitCap),
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.only(
          top: 12,
          right: 12,
          left: 12,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView.separated(
          separatorBuilder: (context, _) {
            return SizedBox(height: 10);
          },
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];

            final avg =
                (rating.vehicle.cleanliness +
                    rating.vehicle.comfort +
                    rating.vehicle.condition +
                    rating.vehicle.overall +
                    rating.vehicle.valueForMoney) /
                5;

            return Container(
              padding: EdgeInsets.all(12),
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.35),
                ),
                color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            foregroundImage: NetworkImage(
                              rating.createdBy.photoUrl,
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rating.createdBy.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              StarRating(
                                rating: avg,
                                mainAxisAlignment: MainAxisAlignment.start,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        timeago.format(rating.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    rating.details.review == ''
                        ? AppLocalizations.of(context)!.noComment
                        : rating.details.review,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall!.color!.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
