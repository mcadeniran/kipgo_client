import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/build_active_filters.dart';
import 'package:kipgo/screens/rental/home/widgets/car_grid_card.dart';
import 'package:kipgo/screens/rental/home/widgets/filter_sheet.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/theme_provider.dart';

class CarsCategoryPage extends StatefulWidget {
  final String category;
  const CarsCategoryPage({super.key, required this.category});

  @override
  State<CarsCategoryPage> createState() => _CarsCategoryPageState();
}

class _CarsCategoryPageState extends State<CarsCategoryPage> {
  Position? userPosition;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<CarProvider>(context, listen: false);

    searchController.text = provider.searchQuery ?? "";

    // Fetch cars when page loads
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      Provider.of<CarProvider>(
        context,
        listen: false,
      ).filterByCategory(widget.category);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getUserLocation()
          .then((position) {
            setState(() {
              userPosition = position;
            });
          })
          .catchError((error) {
            debugPrint("Error getting location: $error");
          });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(loc.locationServicesAreDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          carPropertiesTranslations(context, widget.category),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          LanguageWidget(),
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => FilterSheet(category: widget.category),
              );
            },
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        elevation: 8,
      ),

      floatingActionButton: SpeedDial(
        // animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        overlayOpacity: 0.4,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.white),
        icon: Icons.sort,
        backgroundColor: AppColors.primary,
        spaceBetweenChildren: 12,
        activeBackgroundColor: AppColors.tertiary,
        gradientBoxShape: BoxShape.circle,
        spacing: 12,
        children: [
          SpeedDialChild(
            label: loc.newest,
            onTap: () => Provider.of<CarProvider>(
              context,
              listen: false,
            ).setSortOption(SortOption.newest),
            shape: StadiumBorder(),
            labelBackgroundColor: isDark
                ? AppColors.darkAccent
                : AppColors.lightAccent,
            labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          SpeedDialChild(
            label: loc.nearest,
            onTap: () => Provider.of<CarProvider>(
              context,
              listen: false,
            ).setSortOption(SortOption.nearest),
            shape: StadiumBorder(),
            labelBackgroundColor: isDark
                ? AppColors.darkAccent
                : AppColors.lightAccent,
            labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          SpeedDialChild(
            label: loc.priceUp,
            shape: StadiumBorder(),
            onTap: () => Provider.of<CarProvider>(
              context,
              listen: false,
            ).setSortOption(SortOption.priceLowToHigh),
            labelBackgroundColor: isDark
                ? AppColors.darkAccent
                : AppColors.lightAccent,
            labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          SpeedDialChild(
            label: loc.priceDown,
            onTap: () => Provider.of<CarProvider>(
              context,
              listen: false,
            ).setSortOption(SortOption.priceHighToLow),
            shape: StadiumBorder(),
            labelBackgroundColor: isDark
                ? AppColors.darkAccent
                : AppColors.lightAccent,
            labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: loc.searchBrandOrModel,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController.clear();

                            final provider = Provider.of<CarProvider>(
                              context,
                              listen: false,
                            );

                            provider.searchQuery = null;
                            provider.applyFilters();

                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    Provider.of<CarProvider>(
                      context,
                      listen: false,
                    ).setSearchQuery(value);
                  });

                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 8),
            buildActiveFilters(
              context,
              Provider.of<CarProvider>(context),
              isDark,
            ),
            SizedBox(height: 8),

            Consumer<CarProvider>(
              builder: (context, cp, _) {
                return cp.loading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : cp.cars.isEmpty
                    ? Center(child: Text(loc.noCarsFound))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                mainAxisSpacing: 12.0,
                                crossAxisSpacing: 12.0,
                              ),
                          itemCount: cp.cars.length,
                          itemBuilder: (context, index) {
                            final car = cp.cars[index];
                            return CarGridCard(
                              car: car,
                              isDark: isDark,
                              userPosition: userPosition,
                            );
                          },
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
