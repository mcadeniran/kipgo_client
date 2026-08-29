import 'dart:ui';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/helpers/require_authentication.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_model.dart' hide Rules;
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/rental/widgets/rating_summary_card.dart';
import 'package:kipgo/screens/rental/widgets/recent_reviews_section.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:kipgo/screens/rental/widgets/reviews_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';

class CarDetailsPage extends StatefulWidget {
  final CarWithShop car;
  const CarDetailsPage({super.key, required this.car});

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  double currentPage = 0;
  List<BookingModel> bookings = [];
  bool isReviewLoading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CarRatingProvider>(
        context,
        listen: false,
      ).fetchCarRatings(widget.car.car.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final car = widget.car.car;

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,

      bottomNavigationBar: _PremiumBookingBar(
        car: widget.car,
        isDark: isDark,
        onBook: car.availableUnits == 0
            ? null
            : () async {
                final authenticated = await requireAuthentication(context);

                if (!authenticated || !context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarBookingPage(car: widget.car),
                  ),
                );
              },
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ============================================================
          // HERO
          // ============================================================
          SliverAppBar(
            expandedHeight: size.height * 0.38,
            collapsedHeight: 64,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,

            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _GlassIconButton(
                icon: Icons.arrow_back_ios_new_outlined,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // actions: [
            //   Padding(
            //     padding: const EdgeInsets.only(right: 12),
            //     child: _GlassIconButton(
            //       icon: Icons.favorite_border_rounded,
            //       onTap: () {
            //
            //       },
            //     ),
            //   ),
            // ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double maxHeight = size.height * 0.38;
                final double minHeight = 64;
                final double currentHeight = constraints.maxHeight;

                final double progress =
                    ((currentHeight - minHeight) / (maxHeight - minHeight))
                        .clamp(0.0, 1.0);

                final bool collapsed = progress < 0.25;

                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,

                  titlePadding: const EdgeInsets.only(
                    left: 60,
                    right: 60,
                    bottom: 14,
                  ),

                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: collapsed ? 1 : 0,
                    child: Text(
                      '${widget.car.car.brand} ${widget.car.car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // =========================================================
                      // IMAGE GALLERY
                      // =========================================================
                      PageView.builder(
                        key: const PageStorageKey('car-image-gallery'),
                        physics: const PageScrollPhysics(),
                        itemCount: widget.car.car.images.length,

                        onPageChanged: (index) {
                          if (!mounted) return;

                          setState(() {
                            currentPage = index.toDouble();
                          });
                        },

                        itemBuilder: (context, index) {
                          final image = widget.car.car.images[index];

                          return Image.network(
                            image.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
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

                            errorBuilder: (_, _, _) {
                              return Image.asset(
                                'assets/images/placeholder.jpeg',
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        },
                      ),

                      // =========================================================
                      // PREMIUM IMAGE GRADIENT
                      // =========================================================
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.45, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: .35),
                                Colors.transparent,
                                Colors.black.withValues(alpha: .65),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // =========================================================
                      // IMAGE COUNTER
                      // =========================================================
                      if (widget.car.car.images.length > 1)
                        Positioned(
                          right: 16,
                          bottom: 18,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${currentPage.toInt() + 1}/${widget.car.car.images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // =========================================================
                      // DOT INDICATOR
                      // =========================================================
                      if (widget.car.car.images.length > 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: IgnorePointer(
                            child: DotsIndicator(
                              dotsCount: widget.car.car.images.length,
                              position: currentPage,
                              animate: true,
                              decorator: DotsDecorator(
                                color: Colors.white.withValues(alpha: .45),
                                activeColor: Colors.white,
                                activeSize: const Size(20, 6),
                                size: const Size(6, 6),
                                spacing: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // MAIN CONTENT
          // ============================================================
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 26, 12, 30),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // VEHICLE HEADER
                      // ==================================================
                      _VehicleHeader(car: widget.car, isDark: isDark),

                      const SizedBox(height: 20),

                      // ==================================================
                      // QUICK SPECS
                      // ==================================================
                      _PremiumSectionTitle(
                        title: loc.vehicleDetails,
                        icon: Icons.directions_car_filled_rounded,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      _PremiumSpecsCard(car: car, isDark: isDark),

                      const SizedBox(height: 24),

                      // ==================================================
                      // RENTAL COMPANY
                      // ==================================================
                      _PremiumSectionTitle(
                        title: loc.rentalPartner,
                        icon: Icons.business_rounded,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      _RentalPartnerCard(
                        car: widget.car,
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RentalCompanyDetailPage(
                                companyId: car.shopId,
                              ),
                            ),
                          );
                        },
                        onRules: () => _showRentalRules(
                          context,
                          isDark,
                          widget.car.shop.rules,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // FEATURES
                      // ==================================================
                      if (car.features.isNotEmpty) ...[
                        _PremiumSectionTitle(
                          title: AppLocalizations.of(context)!.features,
                          icon: Icons.auto_awesome_rounded,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 12),

                        _PremiumFeaturesCard(
                          features: car.features,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 26),
                      ],

                      // ==================================================
                      // REVIEWS
                      // ==================================================
                      Consumer<CarRatingProvider>(
                        builder: (context, ratingProvider, child) {
                          if (ratingProvider.loading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final reviews = ratingProvider.ratings;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PremiumSectionTitle(
                                title: loc.guestReviews,
                                icon: Icons.star_rounded,
                                isDark: isDark,
                                trailing: reviews.isNotEmpty
                                    ? TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ReviewsPage(
                                                title: loc.carNameReviews(
                                                  '${car.brand} ${car.model}',
                                                ),
                                                reviews: reviews,
                                                type: RatingSummaryType.car,
                                                isCompanyReview: false,
                                                carReview: car.review,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(loc.seeAll),
                                      )
                                    : null,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                loc.seeWhatOtherTravellersCar,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: .60),
                                ),
                              ),

                              const SizedBox(height: 14),

                              RatingSummaryCard(
                                type: RatingSummaryType.car,
                                average: car.review.average,
                                totalReviews: car.review.totalReviews,
                                distribution: car.review.distribution,
                                comfort: car.review.comfort,
                                cleanliness: car.review.cleanliness,
                                condition: car.review.condition,
                                valueForMoney: car.review.valueForMoney,
                              ),

                              if (reviews.isNotEmpty) ...[
                                const SizedBox(height: 20),

                                RecentReviewsSection(
                                  reviews: reviews.length > 2
                                      ? reviews.sublist(0, 2)
                                      : reviews,
                                  onSeeAll: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewsPage(
                                          title: loc.carNameReviews(
                                            '${car.brand} ${car.model}',
                                          ),
                                          reviews: reviews,
                                          type: RatingSummaryType.car,
                                          isCompanyReview: false,
                                          carReview: car.review,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRentalRules(BuildContext context, bool isDark, Rules rules) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: .08),
                          Colors.white.withValues(alpha: .02),
                        ]
                      : [
                          Colors.white.withValues(alpha: .6),
                          Colors.white.withValues(alpha: .3),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  /// 🔘 Drag Handle
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rentalRules,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: .2),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Rules Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _GlassRuleCard(
                            icon: Icons.lock_outline,
                            title: AppLocalizations.of(
                              context,
                            )!.securityDeposit,
                            description: rules.securityDeposit,
                          ),
                          _GlassRuleCard(
                            icon: Icons.local_gas_station,
                            title: AppLocalizations.of(context)!.fuelPolicy,
                            description: rules.fuelPolicy,
                          ),
                          _GlassRuleCard(
                            icon: Icons.speed,
                            title: AppLocalizations.of(context)!.mileageLimit,
                            description: rules.mileageLimit,
                          ),
                          _GlassRuleCard(
                            icon: Icons.shield_outlined,
                            title: AppLocalizations.of(context)!.insurance,
                            description: rules.insurance,
                          ),
                          _GlassRuleCard(
                            icon: Icons.access_time,
                            title: AppLocalizations.of(context)!.lateReturn,
                            description: rules.lateReturn,
                          ),
                          _GlassRuleCard(
                            icon: Icons.cancel_outlined,
                            title: AppLocalizations.of(context)!.cancellation,
                            description: rules.cancellation,
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _VehicleHeader extends StatelessWidget {
  final CarWithShop car;
  final bool isDark;

  const _VehicleHeader({required this.car, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final vehicle = car.car;
    final review = vehicle.review;
    AppLocalizations loc = AppLocalizations.of(context)!;

    final reviewText = loc.numOfTotalReviews(review.totalReviews);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${vehicle.year} • ${carPropertiesTranslations(context, vehicle.carType)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: .60),
                    ),
                  ),
                ],
              ),
            ),

            if (car.hasDiscount) _DiscountBadge(label: car.discountLabel),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    review.average.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              reviewText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

class _PremiumSpecsCard extends StatelessWidget {
  final CarModel car;
  final bool isDark;

  const _PremiumSpecsCard({required this.car, required this.isDark});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .05) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .07)
              : AppColors.border.withValues(alpha: .45),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SpecTile(
              icon: Icons.settings_rounded,
              title: loc.transmission,
              value: carPropertiesTranslations(context, car.transmission),
              isDark: isDark,
            ),
          ),

          _VerticalDivider(isDark: isDark),

          Expanded(
            child: _SpecTile(
              icon: Icons.local_gas_station_rounded,
              title: loc.fuel,
              value: carPropertiesTranslations(context, car.fuel),
              isDark: isDark,
            ),
          ),

          _VerticalDivider(isDark: isDark),

          Expanded(
            child: _SpecTile(
              icon: Icons.event_seat_rounded,
              title: loc.seatsLabel,
              value: '${car.seats}',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _SpecTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: .08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: .55),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;

  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: isDark
          ? Colors.white.withValues(alpha: .08)
          : AppColors.border.withValues(alpha: .5),
    );
  }
}

class _RentalPartnerCard extends StatelessWidget {
  final CarWithShop car;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRules;

  const _RentalPartnerCard({
    required this.car,
    required this.isDark,
    required this.onTap,
    required this.onRules,
  });

  @override
  Widget build(BuildContext context) {
    final shop = car.shop;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .05) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .07)
              : AppColors.border.withValues(alpha: .45),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.lightLayer.withValues(alpha: 0.08)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      shop.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Image.asset(
                          'assets/images/avatar.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            shop.review.average.toStringAsFixed(1),
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

                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.lightLayer.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: .08)
                : AppColors.border.withValues(alpha: .5),
          ),

          const SizedBox(height: 10),

          InkWell(
            onTap: onRules,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 17,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.viewRentalRules,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeaturesCard extends StatelessWidget {
  final List<String> features;
  final bool isDark;

  const _PremiumFeaturesCard({required this.features, required this.isDark});

  IconData _featureIcon(String feature) {
    final value = feature.toLowerCase();

    if (value.contains('air')) {
      return Icons.ac_unit_rounded;
    }

    if (value.contains('gps') || value.contains('navigation')) {
      return Icons.navigation_rounded;
    }

    if (value.contains('wifi')) {
      return Icons.wifi_rounded;
    }

    if (value.contains('camera')) {
      return Icons.camera_alt_outlined;
    }

    if (value.contains('bluetooth')) {
      return Icons.bluetooth_rounded;
    }

    if (value.contains('leather')) {
      return Icons.event_seat_rounded;
    }

    if (value.contains('usb')) {
      return Icons.usb_rounded;
    }

    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: .05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .07)
                  : AppColors.border.withValues(alpha: .45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _featureIcon(feature),
                size: 16,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),

              const SizedBox(width: 7),

              Text(
                feature,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PremiumSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final bool isDark;

  const _PremiumSectionTitle({
    required this.title,
    required this.icon,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final String label;

  const _DiscountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .90),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: .25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PremiumBookingBar extends StatelessWidget {
  final CarWithShop car;
  final bool isDark;
  final VoidCallback? onBook;

  const _PremiumBookingBar({
    required this.car,
    required this.isDark,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final currency = car.car.currency ?? car.shop.currency;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccent : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.from,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: .55),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
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
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: .45),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],

                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.amountPerDay(
                            formatCurrency(
                              amount: car.finalPrice,
                              currencyCode: currency,
                              context: context,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: car.hasDiscount
                                ? Colors.red
                                : (isDark ? Colors.white : AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.car.availableUnits == 0
                          ? AppLocalizations.of(context)!.notAvailable
                          : AppLocalizations.of(context)!.bookNow,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    if (car.car.availableUnits > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GlassRuleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: .25),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
