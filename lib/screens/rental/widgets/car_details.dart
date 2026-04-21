import 'dart:ui';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_model.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:kipgo/screens/rental/widgets/reviews_widget.dart';
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
    final size = MediaQuery.of(context).size;
    final paddingTop = MediaQuery.of(context).padding.top;
    // final CarModel car = widget.car.car;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: false,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        elevation: 1,
        color: Theme.of(context).scaffoldBackgroundColor,
        notchMargin: 6,
        padding: EdgeInsets.zero,
        shape:
            const CircularNotchedRectangle(), // optional (for FAB support later)
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// 🔥 PRICE SECTION
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.from,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall!.color!.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(width: 4),
                      if (widget.car.hasDiscount)
                        Text(
                          formatCurrency(
                            amount: widget.car.basePrice,
                            currencyCode:
                                widget.car.car.currency ??
                                widget.car.shop.currency,
                            context: context,
                          ),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color!
                                    .withValues(alpha: 0.6),
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  widget.car.hasDiscount
                      ? Text(
                          AppLocalizations.of(context)!.amountPerDay(
                            formatCurrency(
                              amount: widget.car.finalPrice,
                              context: context,
                              currencyCode:
                                  widget.car.car.currency ??
                                  widget.car.shop.currency,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .amountPerDay(
                                      formatCurrency(
                                        amount: widget.car.finalPrice,
                                        context: context,
                                        currencyCode:
                                            widget.car.car.currency ??
                                            widget.car.shop.currency,
                                      ),
                                    ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),

              /// 🔥 CTA BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarBookingPage(car: widget.car),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.bookNow,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            //  🔥 TOP IMAGE SECTION
            SizedBox(
              height: size.height * 0.35,
              width: double.infinity,
              child: PageView(
                onPageChanged: (value) => setState(() {
                  currentPage = value.toDouble();
                }),
                children: widget.car.car.images.map((img) {
                  return FadeInImage.assetNetwork(
                    fadeInCurve: Curves.easeIn,
                    fadeInDuration: Duration(seconds: 2),
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    placeholder: "assets/images/image_spinner.gif",
                    image: img.url,
                    imageErrorBuilder: (c, e, s) => Image.asset(
                      "assets/images/placeholder.jpeg",
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),

            /// 🔙 BACK BUTTON
            Positioned(
              top: paddingTop + 10,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: .4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.29,
              left: 0,
              right: 0,
              child: DotsIndicator(
                dotsCount: widget.car.car.images.length,
                position: currentPage,
                animate: true,
                decorator: DotsDecorator(
                  color: Colors.white,
                  activeColor: AppColors.tertiary,
                  activeSize: Size(11, 11),
                  size: Size(10, 10),
                ),
              ),
            ),

            /// 🔥 BOTTOM DETAILS SECTION
            Positioned(
              top: size.height * 0.32, // overlap
              left: 0,
              right: 0,
              bottom: 0, // fill remaining screen
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.car.car.brand} ${widget.car.car.model} ${widget.car.car.year}",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "${widget.car.car.rating} (${widget.car.car.totalRatings == 1 ? AppLocalizations.of(context)!.singleReview(widget.car.car.totalRatings) : AppLocalizations.of(context)!.multiReviews(widget.car.car.totalRatings)})",
                              ),
                            ],
                          ),
                          if (widget.car.hasDiscount)
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                color: Colors.red.withValues(alpha: .8),
                                shape: BeveledRectangleBorder(
                                  side: BorderSide(color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                              ),
                              child: Text(
                                widget.car.shop.discount!.type == 'fixed'
                                    ? "-${formatCurrency(amount: widget.car.shop.discount!.value, currencyCode: widget.car.car.currency ?? widget.car.shop.currency, context: context)}"
                                    : widget.car.discountLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkLayer
                              : AppColors.lightLayer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RentalCompanyDetailPage(
                                    companyId: widget.car.car.shopId,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 27,
                                    backgroundColor: AppColors.primary,
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: AppColors.primary,
                                      backgroundImage: NetworkImage(
                                        widget.car.car.shop.logo,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.car.car.shop.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Consumer<RentalShopProvider>(
                                        builder: (context, provider, _) {
                                          final shop = provider.getShopById(
                                            widget.car.car.shopId,
                                          );

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                shop.rating.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(Icons.circle, size: 8),
                                              SizedBox(width: 2),
                                              Text(
                                                shop.totalRatings == 1
                                                    ? AppLocalizations.of(
                                                        context,
                                                      )!.singleReview(
                                                        shop.totalRatings,
                                                      )
                                                    : AppLocalizations.of(
                                                        context,
                                                      )!.multiReviews(
                                                        shop.totalRatings,
                                                      ),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showRentalRules(
                                context,
                                isDark,
                                widget.car.car.shop.rules,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.rentalRules,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              icon: Icon(Icons.chevron_right_outlined),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SpecItem(
                            icon: Icons.settings,
                            label: carPropertiesTranslations(
                              context,
                              widget.car.car.transmission,
                            ),
                          ),
                          _SpecItem(
                            icon: Icons.local_gas_station,
                            label: carPropertiesTranslations(
                              context,
                              widget.car.car.fuel,
                            ),
                          ),
                          _SpecItem(
                            icon: Icons.event_seat,
                            // label: "${car.seats} Seats",
                            label: AppLocalizations.of(
                              context,
                            )!.seats(widget.car.car.seats),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        AppLocalizations.of(context)!.features,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.car.car.features
                            .map(
                              (feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.lightLayer.withValues(
                                          alpha: 0.15,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ReviewsWidget(carId: widget.car.car.id),
                      const SizedBox(height: 20),

                      // SizedBox(height: size.height * 0.05), // padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

/// 🔹 Small Spec Widget
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Icon(icon, size: 26), const SizedBox(height: 6), Text(label)],
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
