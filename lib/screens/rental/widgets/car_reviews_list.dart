import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarReviewsList extends StatelessWidget {
  const CarReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: 'Reviews'),
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
          itemCount: 20,
          itemBuilder: (context, index) {
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary,
                            backgroundImage: AssetImage(
                              'assets/images/user.jpeg',
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Jack Sparrow",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '4 days ago',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  StarRating(
                    rating: 5,
                    mainAxisAlignment: MainAxisAlignment.start,
                    color: Colors.amber,
                    size: 18,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "The rental car was clean, reliable, and the service was quick and efficient. Overall, the experience was hassle-free and enjoyable.",
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
