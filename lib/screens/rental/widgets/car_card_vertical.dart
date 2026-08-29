import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/require_authentication.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarCardVertical extends StatelessWidget {
  final CarWithShop car;

  const CarCardVertical({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final currency = car.car.currency ?? car.shop.currency;

    final coverImage =
        car.car.images
            .where((image) => image.isCover && image.url.trim().isNotEmpty)
            .map((image) => image.url)
            .firstOrNull ??
        car.car.images
            .where((image) => image.url.trim().isNotEmpty)
            .map((image) => image.url)
            .firstOrNull;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
          );
        },
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent.withValues(alpha: .96)
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .06)
                  : AppColors.border.withValues(alpha: .45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .20 : .07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------
              // IMAGE HERO
              // ---------------------------------------------------------
              SizedBox(
                height: 215,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (coverImage != null)
                      Image.network(
                        coverImage,
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
                      )
                    else
                      Image.asset(
                        'assets/images/placeholder.jpeg',
                        fit: BoxFit.cover,
                      ),

                    // ---------------------------------------------------
                    // IMAGE GRADIENT
                    // ---------------------------------------------------
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .28),
                              Colors.transparent,
                              Colors.black.withValues(alpha: .50),
                            ],
                            stops: const [0, .45, 1],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------
                    // TOP LEFT: DISCOUNT
                    // ---------------------------------------------------
                    if (car.hasDiscount)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: .25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            car.shop.discount!.type == 'fixed'
                                ? '-${formatCurrency(amount: car.shop.discount!.value, currencyCode: currency, context: context)}'
                                : car.discountLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                    // ---------------------------------------------------
                    // TOP RIGHT: RATING
                    // ---------------------------------------------------
                    Positioned(
                      top: 14,
                      right: 14,
                      child: _GlassBadge(
                        isDark: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              car.car.review.average.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${car.car.review.totalReviews})',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .75),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ---------------------------------------------------
                    // BOTTOM LEFT: PRICE
                    // ---------------------------------------------------
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: car.hasDiscount
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatCurrency(
                                      amount: car.basePrice,
                                      currencyCode: currency,
                                      context: context,
                                      decimalDigits: 0,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc.amountPerDay(
                                      formatCurrency(
                                        amount: car.finalPrice,
                                        currencyCode: currency,
                                        context: context,
                                        decimalDigits: 0,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    loc.amountPerDay(
                                      formatCurrency(
                                        amount: car.finalPrice,
                                        currencyCode: currency,
                                        context: context,
                                        decimalDigits: 0,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------
              // CONTENT
              // ---------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------
                    // TITLE + ARROW
                    // ---------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${car.car.brand} ${car.car.model}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.25,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${car.car.year} • ${carPropertiesTranslations(context, car.car.carType)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: .55),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.lightLayer.withValues(alpha: 0.08)
                                : AppColors.primary.withValues(alpha: .07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------
                    // SPECS
                    // ---------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumCarSpec(
                            icon: Icons.settings_rounded,
                            label: carPropertiesTranslations(
                              context,
                              car.car.transmission,
                            ),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PremiumCarSpec(
                            icon: Icons.local_gas_station_rounded,
                            label: carPropertiesTranslations(
                              context,
                              car.car.fuel,
                            ),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PremiumCarSpec(
                            icon: Icons.event_seat_rounded,
                            label: loc.seats(car.car.seats),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------
                    // SHOP
                    // ---------------------------------------------------
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: .08),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: car.shop.logo.trim().isNotEmpty
                              ? Image.network(
                                  car.shop.logo,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) {
                                    return const Icon(
                                      Icons.storefront_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.storefront_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            car.shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: .72),
                            ),
                          ),
                        ),
                        // if (car.car.availableUnits > 0)
                        //   _AvailabilityBadge(isDark: isDark),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------
                    // CTA
                    // ---------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.withValues(
                            alpha: .25,
                          ),
                          disabledForegroundColor: Colors.grey.withValues(
                            alpha: .65,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: car.car.availableUnits == 0
                            ? null
                            : () async {
                                final authenticated =
                                    await requireAuthentication(context);

                                if (!authenticated || !context.mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarBookingPage(car: car),
                                  ),
                                );
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              car.car.availableUnits == 0
                                  ? Icons.block_rounded
                                  : Icons.calendar_month_rounded,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              car.car.availableUnits == 0
                                  ? loc.notAvailable
                                  : loc.bookNow,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _GlassBadge({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: child,
    );
  }
}

class _PremiumCarSpec extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _PremiumCarSpec({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .055)
            : AppColors.lightLayer.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : AppColors.border.withValues(alpha: .35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: .78)
                    : Colors.black.withValues(alpha: .68),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
