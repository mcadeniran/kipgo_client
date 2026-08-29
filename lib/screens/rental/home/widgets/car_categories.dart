import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/cars_category_page.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';

class CarCategories extends StatefulWidget {
  final Function(String category)? onCategorySelected;

  const CarCategories({super.key, this.onCategorySelected});

  @override
  State<CarCategories> createState() => _CarCategoriesState();
}

class _CarCategoriesState extends State<CarCategories> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> categories = [
    {"title": "All", "icon": Icons.apps_rounded},
    {"title": "Economy", "icon": Icons.savings_rounded},
    {"title": "Sedan", "icon": Icons.directions_car_rounded},
    {"title": "SUV", "icon": Icons.directions_car_filled_rounded},
    {"title": "Luxury", "icon": Icons.auto_awesome_rounded},
    {"title": "Sports", "icon": Icons.flash_on_rounded},
    {"title": "Pickup", "icon": Icons.local_shipping_rounded},
    {"title": "Van", "icon": Icons.airport_shuttle_rounded},
  ];

  int selectedIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),

        const SizedBox(height: 14),

        SizedBox(
          height: 104,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              final bool isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });

                  final selectedCategory = category["title"];

                  widget.onCategorySelected?.call(selectedCategory);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CarsCategoryPage(category: selectedCategory),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 84,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                        ? AppColors.darkLayer.withValues(alpha: .75)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.primary.withValues(alpha: .06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isSelected
                              ? .10
                              : isDark
                              ? .08
                              : .035,
                        ),
                        blurRadius: isSelected ? 16 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white.withValues(alpha: .95)
                              : AppColors.primary.withValues(alpha: .07),
                        ),
                        child: Icon(
                          category["icon"],
                          size: 20,
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        carPropertiesTranslations(context, category["title"]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white.withValues(alpha: .88)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.browseByCategory,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                AppLocalizations.of(context)!.findTheRightCar,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
