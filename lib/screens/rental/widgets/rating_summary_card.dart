import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/rating_distribution.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum RatingSummaryType { car, company }

class RatingSummaryCard extends StatelessWidget {
  final double average;
  final int totalReviews;
  final RatingDistribution distribution;
  final RatingSummaryType type;

  final double? comfort;
  final double? cleanliness;
  final double? condition;
  final double? valueForMoney;

  final double? communication;
  final double? pickupExperience;
  final double? professionalism;
  final double? returnExperience;

  const RatingSummaryCard({
    super.key,
    required this.average,
    required this.totalReviews,
    required this.distribution,
    required this.type,
    this.comfort,
    this.cleanliness,
    this.condition,
    this.valueForMoney,
    this.communication,
    this.pickupExperience,
    this.professionalism,
    this.returnExperience,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    final categories = type == RatingSummaryType.car
        ? [
            _RatingCategory(
              icon: Icons.airline_seat_recline_normal_rounded,
              label: loc.comfort,
              value: comfort ?? 0,
            ),
            _RatingCategory(
              icon: Icons.cleaning_services_rounded,
              label: loc.cleanliness,
              value: cleanliness ?? 0,
            ),
            _RatingCategory(
              icon: Icons.directions_car_filled_rounded,
              label: loc.condition,
              value: condition ?? 0,
            ),
            _RatingCategory(
              icon: Icons.payments_rounded,
              label: loc.valueForMoney,
              value: valueForMoney ?? 0,
            ),
          ]
        : [
            _RatingCategory(
              icon: Icons.forum_rounded,
              label: loc.communication,
              value: communication ?? 0,
            ),
            _RatingCategory(
              icon: Icons.location_on_rounded,
              label: loc.pickupExperience,
              value: pickupExperience ?? 0,
            ),
            _RatingCategory(
              icon: Icons.verified_user_rounded,
              label: loc.professionalism,
              value: professionalism ?? 0,
            ),
            _RatingCategory(
              icon: Icons.assignment_return_rounded,
              label: loc.returnExperience,
              value: returnExperience ?? 0,
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),

          const SizedBox(height: 22),

          _buildDistribution(context),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            padding: EdgeInsets.only(top: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) {
              return _RatingCategoryCard(category: categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.star_rounded, color: Colors.white, size: 17),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.overallRating,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                loc.numOfTotalReviews(totalReviews),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistribution(BuildContext context) {
    final total = distribution.total;

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = distribution.getCount(rating);
        final percentage = total == 0 ? 0.0 : count / total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  '$rating',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),

              const SizedBox(width: 8),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: percentage,
                    backgroundColor: Colors.grey.withValues(alpha: .15),
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 25,
                child: Text(
                  '$count',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _RatingCategory {
  final IconData icon;
  final String label;
  final double value;

  const _RatingCategory({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _RatingCategoryCard extends StatelessWidget {
  final _RatingCategory category;

  const _RatingCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.lightLayer.withValues(alpha: .08)
            : AppColors.lightLayer.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : Colors.black.withValues(alpha: .04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkLayer.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              category.icon,
              size: 18,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      category.value.toStringAsFixed(1),
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
      ),
    );
  }
}
