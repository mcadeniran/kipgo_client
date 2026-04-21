import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/widgets/car_card.dart';
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
    viewportFraction: 1,
    keepPage: true,
  );

  int _currentIndex = 0;
  Timer? _timer;

  void _startAutoScroll() {
    _timer?.cancel(); // prevent multiple timers

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;

      final cp = context.read<CarProvider>();

      if (cp.featuredCars.isEmpty) return;

      int nextPage = _currentIndex + 1;

      if (nextPage >= cp.featuredCars.length) {
        nextPage = 0;
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
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
    final shopLoading = context.watch<RentalShopProvider>().loading;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<CarProvider>(
      builder: (context, cp, _) {
        return cp.loading || shopLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : cp.featuredCars.isEmpty
            ? SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.featuredCars,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction != ScrollDirection.idle) {
                          _timer?.cancel();
                        } else {
                          Future.delayed(Duration(seconds: 2), () {
                            if (mounted) _startAutoScroll();
                          });
                        }
                        return true;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cp.featuredCars.length,
                        padEnds: false,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CarCard(
                              car: cp.featuredCars[index],
                              totalCars: cp.featuredCars.length,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: cp.featuredCars.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: isDark
                            ? AppColors.darkLayer
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
