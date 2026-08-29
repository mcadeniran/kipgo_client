import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/rental/home/widgets/build_active_filters.dart';
import 'package:kipgo/screens/rental/home/widgets/car_categories.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_cars.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_rental_companies_section.dart';
import 'package:kipgo/screens/rental/home/widgets/filter_sheet.dart';
import 'package:kipgo/screens/rental/home/widgets/popular_cars.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/rental/widgets/search_bar_widget.dart';
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/screens/widgets/notification_icon_button.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalHome extends StatefulWidget {
  const RentalHome({super.key});

  @override
  State<RentalHome> createState() => _RentalHomeState();
}

class _RentalHomeState extends State<RentalHome> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool showSearchOverlay = false;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FilterSheet(category: "All");
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializePushNotifications();

      if (!mounted) return;

      final provider = Provider.of<CarProvider>(context, listen: false);

      searchController.text = provider.searchQuery ?? "";

      await _requestLocationPermission();
    });
  }

  Future<void> _initializePushNotifications() async {
    await PushNotificationSystem().generateAndGetToken(context);
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Optional:
      // await Geolocator.openAppSettings();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.kipgoRentals,
        subtitle: loc.findYourPerfectRide,
        showLanguage: false,
        actions: const [NotificationIconButton()],
      ),
      body: Stack(
        children: [
          _buildHomeContent(isDark),
          if (showSearchOverlay) _buildSearchOverlay(isDark),
        ],
      ),
    );
  }

  Widget _buildHomeContent(bool isDark) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(isDark),

            const SizedBox(height: 20),

            _buildSearchSection(isDark),

            const SizedBox(height: 28),

            const CarCategories(),

            const SizedBox(height: 30),

            const FeaturedCars(),

            const PopularCars(),

            const SizedBox(height: 28),

            const AdsCarouselWidget(),

            const SizedBox(height: 30),

            const FeaturedRentalCompaniesSection(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: .82),
            isDark ? AppColors.darkLayer : const Color(0xFF2929A5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),
          Positioned(
            right: 25,
            bottom: -60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_filled_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: .95),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.kipgoRentals,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .95),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                loc.findYourPerfectRide,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loc.discoverQualityCars,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .78),
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  _buildHeroStat(
                    icon: Icons.verified_rounded,
                    label: loc.verified,
                  ),
                  const SizedBox(width: 18),
                  _buildHeroStat(
                    icon: Icons.directions_car_rounded,
                    label: loc.wideSelection,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: .9)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? .18 : .06),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: SearchBarWidget(
              controller: searchController,
              onTap: () {
                setState(() {
                  showSearchOverlay = true;
                });
              },
              onChanged: (value) {
                final provider = Provider.of<CarProvider>(
                  context,
                  listen: false,
                );

                provider.setSearchQuery(value);

                if (!showSearchOverlay) {
                  setState(() {
                    showSearchOverlay = true;
                  });
                }
              },
            ),
          ),
        ),

        const SizedBox(width: 10),

        Material(
          color: isDark
              ? AppColors.lightLayer.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _openFilterSheet,
            child: Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .08),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                    size: 23,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay(bool isDark) {
    final provider = Provider.of<CarProvider>(context);
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Search header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(
                              alpha: isDark ? .18 : .08,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? .16 : .05,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SearchBarWidget(
                          controller: searchController,
                          onChanged: (value) {
                            final provider = Provider.of<CarProvider>(
                              context,
                              listen: false,
                            );

                            provider.setSearchQuery(value);

                            setState(() {
                              showSearchOverlay = value.trim().isNotEmpty;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          FocusScope.of(context).unfocus();

                          setState(() {
                            showSearchOverlay = false;
                          });
                        },
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search information
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.searchBrandOrModel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active filters
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: buildActiveFilters(context, provider, isDark),
              ),

              Divider(height: 1, color: Colors.grey.withValues(alpha: .12)),

              // Results
              Expanded(
                child: provider.cars.isEmpty
                    ? _buildNoSearchResults(isDark)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: provider.cars.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final car = provider.cars[index];

                          return _buildSearchResultTile(car, isDark);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: .08),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 32,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noResultsFound,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.trySearchingForAnotherCar,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultTile(dynamic car, bool isDark) {
    final currency = formatCurrency(
      amount: car.car.pricePerDay,
      currencyCode: car.car.currency ?? car.shop.currency,
      context: context,
    );

    return Material(
      color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 64,
                width: 76,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.lightLayer.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.car.brand} ${car.car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!.amountPerDay(currency),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 36,
                width: 36,
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
      ),
    );
  }
}
