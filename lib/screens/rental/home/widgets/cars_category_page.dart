import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/build_active_filters.dart';
import 'package:kipgo/screens/rental/home/widgets/car_grid_card.dart';
import 'package:kipgo/screens/rental/home/widgets/filter_sheet.dart';
import 'package:kipgo/screens/rental/widgets/search_bar_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarsCategoryPage extends StatefulWidget {
  final String category;

  const CarsCategoryPage({super.key, required this.category});

  @override
  State<CarsCategoryPage> createState() => _CarsCategoryPageState();
}

class _CarsCategoryPageState extends State<CarsCategoryPage> {
  Position? userPosition;

  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;

  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<CarProvider>(context, listen: false);

    searchController.text = provider.searchQuery ?? '';

    Future.microtask(() {
      if (!mounted) return;

      Provider.of<CarProvider>(
        context,
        listen: false,
      ).filterByCategory(widget.category);
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   try {
    //     final position = await getUserLocation();

    //     if (!mounted) return;

    //     setState(() {
    //       userPosition = position;
    //     });
    //   } catch (error) {
    //     debugPrint('Error getting location: $error');
    //   }
    // });
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

  // Future<Position> getUserLocation() async {
  //   final serviceEnabled = await Geolocator.isLocationServiceEnabled();

  //   if (!serviceEnabled) {
  //     throw Exception(loc.locationServicesAreDisabled);
  //   }

  //   LocationPermission permission = await Geolocator.checkPermission();

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }

  //   return Geolocator.getCurrentPosition();
  // }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .45),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.78,
        child: FilterSheet(category: widget.category),
      ),
    );
  }

  void _clearSearch() {
    searchController.clear();

    final provider = Provider.of<CarProvider>(context, listen: false);

    provider.searchQuery = null;
    provider.applyFilters();

    setState(() {});
  }

  void _openSortSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.sortBy,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SortOption(
                    icon: Icons.auto_awesome_outlined,
                    title: loc.newest,
                    onTap: () {
                      Provider.of<CarProvider>(
                        context,
                        listen: false,
                      ).setSortOption(SortOption.newest);

                      Navigator.pop(sheetContext);
                    },
                  ),

                  _SortOption(
                    icon: Icons.arrow_upward_rounded,
                    title: loc.priceUp,
                    onTap: () {
                      Provider.of<CarProvider>(
                        context,
                        listen: false,
                      ).setSortOption(SortOption.priceLowToHigh);

                      Navigator.pop(sheetContext);
                    },
                  ),

                  _SortOption(
                    icon: Icons.arrow_downward_rounded,
                    title: loc.priceDown,
                    onTap: () {
                      Provider.of<CarProvider>(
                        context,
                        listen: false,
                      ).setSortOption(SortOption.priceHighToLow);

                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.primary,

      appBar: AppBarWidget(
        title: carPropertiesTranslations(
          context,
          Provider.of<CarProvider>(context, listen: false).selectedCategory ??
              'All',
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            _buildHeader(isDark),

            Expanded(
              child: Consumer<CarProvider>(
                builder: (context, cp, _) {
                  if (cp.loading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (cp.cars.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: .69,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: cp.cars.length,
                      itemBuilder: (context, index) {
                        final car = cp.cars[index];

                        return CarGridCard(
                          key: ValueKey(car.car.id),
                          car: car,
                          isDark: isDark,
                          userPosition: userPosition,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: SearchBarWidget(
              controller: searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(const Duration(milliseconds: 400), () {
                  if (!mounted) return;

                  Provider.of<CarProvider>(
                    context,
                    listen: false,
                  ).setSearchQuery(value);
                });

                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 14),

          Consumer<CarProvider>(
            builder: (context, cp, _) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.numOfCarsAvailable(cp.cars.length),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  _HeaderActionButton(
                    icon: Icons.tune_rounded,
                    label: loc.filters,
                    onTap: _openFilters,
                  ),

                  const SizedBox(width: 8),

                  _HeaderActionButton(
                    icon: Icons.swap_vert_rounded,
                    label: loc.sortBy,
                    onTap: () => _openSortSheet(isDark),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          Consumer<CarProvider>(
            builder: (context, cp, _) {
              return buildActiveFilters(context, cp, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: .08),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 42,
                color: AppColors.primary.withValues(alpha: .7),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              loc.noCarsFound,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              loc.tryChangingYourSearch,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _openFilters,
              icon: const Icon(Icons.filter_alt_outlined),
              label: Text(loc.filters),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: .45)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: .04)
                  : Colors.black.withValues(alpha: .025),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.lightLayer.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
