import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/rental/home/widgets/build_active_filters.dart';
import 'package:kipgo/screens/rental/home/widgets/car_categories.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_cars.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_rental_companies_section.dart';
import 'package:kipgo/screens/rental/home/widgets/filter_sheet.dart';
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
      builder: (context) {
        return FilterSheet(category: "All");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // filteredCars = allCars;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializePushNotifications();
      if (!mounted) return;
      final provider = Provider.of<CarProvider>(context, listen: false);

      // await provider.fetchCars();
      // Provider.of<CarProvider>(context, listen: false).listenToCars();

      searchController.text = provider.searchQuery ?? "";

      // Provider.of<RentalShopProvider>(
      //   context,
      //   listen: false,
      // ).listenToRentalShops();

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
      // Optional: redirect user to app settings
      // await Geolocator.openAppSettings(); (if using geolocator >=9.0.0)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.kipgoRentals,
        showLanguage: false,
        actions: [NotificationIconButton()],
      ),
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          _buildHomeContent(),
          if (showSearchOverlay) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchRow(),
            const SizedBox(height: 22),
            CarCategories(),
            const SizedBox(height: 22),
            FeaturedCars(),
            const SizedBox(height: 20),
            AdsCarouselWidget(),
            const SizedBox(height: 20),
            FeaturedRentalCompaniesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            controller: searchController,
            onChanged: (value) {
              final provider = Provider.of<CarProvider>(context, listen: false);

              provider.setSearchQuery(value);

              setState(() {
                showSearchOverlay = value.isNotEmpty;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: _openFilterSheet,
          icon: const Icon(Icons.filter_alt_outlined),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    final provider = Provider.of<CarProvider>(context);
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Positioned.fill(
      child: Stack(
        children: [
          // background tap
          GestureDetector(
            onTap: () {
              setState(() {
                showSearchOverlay = false;
              });
            },
            child: Container(color: Colors.black.withValues(alpha: .25)),
          ),

          // actual overlay
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              padding: const EdgeInsets.all(16),
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: provider.cars.isEmpty
                  ? Column(
                      children: [
                        buildActiveFilters(
                          context,
                          provider,
                          isDark,
                        ), // reuse chips
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.noResultsFound,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        buildActiveFilters(
                          context,
                          provider,
                          isDark,
                        ), // reuse chips
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.cars.length,
                            itemBuilder: (context, index) {
                              final car = provider.cars[index];

                              return ListTile(
                                title: Text(
                                  "${car.car.brand} ${car.car.model}",
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!.amountPerDay(
                                    formatCurrency(
                                      amount: car.car.pricePerDay,
                                      currencyCode:
                                          car.car.currency ?? car.shop.currency,
                                      context: context,
                                    ),
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarDetailsPage(car: car),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
