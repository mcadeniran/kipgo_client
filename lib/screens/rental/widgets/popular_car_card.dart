import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class PopularCarCard extends StatelessWidget {
  final CarWithShop car;
  final int totalCars;

  const PopularCarCard({super.key, required this.car, required this.totalCars});

  String? _getImageUrl() {
    if (car.car.images.isEmpty) {
      return null;
    }

    try {
      return car.car.images.lastWhere((image) => image.isCover == true).url;
    } catch (_) {
      return car.car.images.first.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final currency = car.car.currency ?? car.shop.currency;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .05)
                  : Colors.black.withValues(alpha: .025),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .18 : .06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: _buildImage(context, isDark)),

                Expanded(
                  flex: 13,
                  child: _buildDetails(context, isDark, currency),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, bool isDark) {
    final imageUrl = _getImageUrl();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDark
              ? AppColors.darkLayer.withValues(alpha: .3)
              : AppColors.primary.withValues(alpha: .03),
          child: imageUrl == null
              ? Image.asset('assets/images/placeholder.jpeg', fit: BoxFit.cover)
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return Image.asset(
                      'assets/images/image_spinner.gif',
                      fit: BoxFit.cover,
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/images/placeholder.jpeg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
        ),

        // Image gradient.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 75,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .42),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Popular badge.
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 12,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.popularTag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Discount badge.
        if (car.hasDiscount)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                car.shop.discount!.type == 'fixed'
                    ? '-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context, decimalDigits: 0)}'
                    : car.discountLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        // Favourite.
        // Positioned(
        //   bottom: 10,
        //   right: 10,
        //   child: Container(
        //     height: 34,
        //     width: 34,
        //     decoration: BoxDecoration(
        //       color: Colors.white.withValues(alpha: .94),
        //       shape: BoxShape.circle,
        //     ),
        //     child: Icon(
        //       Icons.favorite_border_rounded,
        //       color: AppColors.primary,
        //       size: 18,
        //     ),
        //   ),
        // ),

        // Rating.
        Positioned(
          bottom: 12,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .52),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                const SizedBox(width: 3),
                Text(
                  car.car.review.average.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '(${car.car.review.totalReviews})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, bool isDark, String currency) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${car.car.brand} ${car.car.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.15,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '${car.car.year}',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          _buildSpecs(context, isDark),

          const Spacer(),

          _buildPrice(context, isDark, currency),
        ],
      ),
    );
  }

  Widget _buildSpecs(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 7,
      runSpacing: 4,
      children: [
        _specItem(
          icon: Icons.settings_outlined,
          label: carPropertiesTranslations(context, car.car.transmission),
          isDark: isDark,
        ),
        _specItem(
          icon: Icons.local_gas_station_outlined,
          label: carPropertiesTranslations(context, car.car.fuel),
          isDark: isDark,
        ),
        _specItem(
          icon: Icons.people_outline_rounded,
          label: '${car.car.seats}',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _specItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey.shade400),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark
                ? Colors.white.withValues(alpha: .62)
                : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context, bool isDark, String currency) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (car.hasDiscount) ...[
          Text(
            formatCurrency(
              amount: car.basePrice,
              currencyCode: currency,
              context: context,
              decimalDigits: 0,
            ),
            style: TextStyle(
              fontSize: 9,
              color: Colors.blueGrey.shade400,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 5),
        ],

        Expanded(
          child: Text(
            loc.amountPerDay(
              formatCurrency(
                amount: car.finalPrice,
                currencyCode: currency,
                context: context,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: car.hasDiscount
                  ? Colors.red.shade600
                  : isDark
                  ? AppColors.lightLayer
                  : AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        // const Spacer(),
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 15,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
