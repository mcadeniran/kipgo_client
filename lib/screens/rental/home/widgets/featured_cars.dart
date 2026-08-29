import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FeaturedCars extends StatefulWidget {
  const FeaturedCars({super.key});

  @override
  State<FeaturedCars> createState() => _FeaturedCarsState();
}

class _FeaturedCarsState extends State<FeaturedCars> {
  final PageController _pageController = PageController(
    viewportFraction: .94,
    keepPage: true,
  );

  int _currentIndex = 0;
  Timer? _timer;

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      final cp = context.read<CarProvider>();

      if (cp.featuredCars.isEmpty) return;

      int nextPage = _currentIndex + 1;

      if (nextPage >= cp.featuredCars.length) {
        nextPage = 0;
      }

      if (!_pageController.hasClients) return;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<CarProvider, RentalShopProvider>(
      builder: (context, cp, rs, _) {
        if (cp.loading || rs.loading) {
          return _buildLoadingState();
        }

        if (cp.featuredCars.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),

            const SizedBox(height: 15),

            SizedBox(
              height: 320,
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction != ScrollDirection.idle) {
                    _timer?.cancel();
                  } else {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        _startAutoScroll();
                      }
                    });
                  }

                  return true;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cp.featuredCars.length,

                  padEnds: false,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _PremiumFeaturedCarCard(
                        car: cp.featuredCars[index],
                        totalCars: cp.featuredCars.length,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 13),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: cp.featuredCars.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    spacing: 5,
                    expansionFactor: 3,
                    activeDotColor: isDark ? Colors.white : AppColors.primary,
                    dotColor: isDark
                        ? Colors.white.withValues(alpha: .2)
                        : AppColors.primary.withValues(alpha: .15),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.featuredCars,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                loc.handpickedRides,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).cardColor,
      ),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _PremiumFeaturedCarCard extends StatelessWidget {
  final CarWithShop car;
  final int totalCars;

  const _PremiumFeaturedCarCard({required this.car, required this.totalCars});

  String? _getCoverImage() {
    try {
      return car.car.images.lastWhere((image) => image.isCover == true).url;
    } catch (_) {
      if (car.car.images.isNotEmpty) {
        return car.car.images.first.url;
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currencyCode = car.car.currency ?? car.shop.currency;

    final finalPrice = formatCurrency(
      amount: car.finalPrice,
      currencyCode: currencyCode,
      context: context,
    );

    final basePrice = formatCurrency(
      amount: car.basePrice,
      currencyCode: currencyCode,
      context: context,
      decimalDigits: 0,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isDark ? AppColors.darkAccent : theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .18 : .07),
                blurRadius: 28,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(flex: 6, child: _buildImageSection(context, isDark)),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleRow(context),

                      const SizedBox(height: 7),

                      _buildSpecs(context, isDark),

                      const Spacer(),

                      _buildPriceRow(context, isDark, finalPrice, basePrice),

                      const SizedBox(height: 8),

                      _buildCompanyRow(context, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, bool isDark) {
    final imageUrl = _getCoverImage();
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDark
              ? AppColors.darkLayer.withValues(alpha: .35)
              : AppColors.primary.withValues(alpha: .035),
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

        // Subtle bottom gradient.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 95,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .38),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Featured badge.
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  loc.featuredCap,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Discount.
        if (car.hasDiscount)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                car.shop.discount!.type == 'fixed'
                    ? '-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context)}'
                    : car.discountLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        // Favourite button.
        // Positioned(
        //   top: 12,
        //   right: 12,
        //   child: Container(
        //     height: 38,
        //     width: 38,
        //     decoration: BoxDecoration(
        //       color: Colors.white.withValues(alpha: .94),
        //       shape: BoxShape.circle,
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withValues(alpha: .10),
        //           blurRadius: 10,
        //         ),
        //       ],
        //     ),
        //     child: Icon(
        //       Icons.favorite_border_rounded,
        //       color: AppColors.primary,
        //       size: 20,
        //     ),
        //   ),
        // ),

        // Rating.
        Positioned(
          bottom: 12,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  car.car.review.average.toStringAsPrecision(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '(${car.car.review.totalReviews})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${car.car.brand} ${car.car.model}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          '${car.car.year}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecs(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildSpec(
          icon: Icons.settings_outlined,
          label: carPropertiesTranslations(context, car.car.transmission),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildSpec(
          icon: Icons.local_gas_station_outlined,
          label: carPropertiesTranslations(context, car.car.fuel),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildSpec(
          icon: Icons.people_outline_rounded,
          label: '${car.car.seats}',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSpec({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.blueGrey.shade400),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: .72)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    bool isDark,
    String finalPrice,
    String basePrice,
  ) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (car.hasDiscount) ...[
          Text(
            basePrice,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.4,
            ),
          ),
          const SizedBox(width: 7),
        ],

        Text(
          loc.amountPerDay(finalPrice),
          style: TextStyle(
            color: car.hasDiscount
                ? Colors.red.shade600
                : isDark
                ? AppColors.lightLayer
                : AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),

        // const SizedBox(width: 5),

        // Padding(
        //   padding: const EdgeInsets.only(bottom: 2),
        //   child: Text(
        //     '/ day',
        //     style: TextStyle(
        //       color: Colors.grey.shade500,
        //       fontSize: 10,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        const Spacer(),

        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyRow(BuildContext context, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RentalCompanyDetailPage(company: car.shop),
          ),
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.verified_rounded,
            size: 15,
            color: isDark
                ? Colors.white.withValues(alpha: .7)
                : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              car.shop.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: .72)
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
