import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/cars_category_page.dart';
import 'package:kipgo/screens/rental/widgets/popular_car_card.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class PopularCars extends StatefulWidget {
  const PopularCars({super.key});

  @override
  State<PopularCars> createState() => _PopularCarsState();
}

class _PopularCarsState extends State<PopularCars> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.72);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final shopLoading = context.watch<RentalShopProvider>().loading;

    return Consumer<CarProvider>(
      builder: (context, cp, _) {
        if (cp.loading || shopLoading || cp.loadingPopularCars) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (cp.popularCars.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),

            _buildSectionHeader(context),

            const SizedBox(height: 14),

            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: cp.popularCars.length,
                padEnds: false,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: PopularCarCard(
                      car: cp.popularCars[index],
                      totalCars: cp.popularCars.length,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            _buildSwipeHint(context, isDark),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: isDark ? .18 : .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 21,
            color: AppColors.secondary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.popularCars,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.lovedByKipgoTravellers,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarsCategoryPage(category: 'All'),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.seeAll,
                style: TextStyle(
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeHint(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swipe_rounded,
          size: 15,
          color: isDark
              ? Colors.white.withValues(alpha: .35)
              : Colors.grey.shade400,
        ),
        const SizedBox(width: 5),
        Text(
          AppLocalizations.of(context)!.swipeToExplore,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? Colors.white.withValues(alpha: .35)
                : Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
