import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/cars_category_page.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
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
    {"title": "All", "icon": Icons.apps},
    {"title": "Economy", "icon": Icons.attach_money},
    {"title": "Sedan", "icon": Icons.directions_car},
    {"title": "SUV", "icon": Icons.sports_motorsports},
    {"title": "Luxury", "icon": Icons.star},
    {"title": "Sports", "icon": Icons.flash_on},
    {"title": "Pickup", "icon": Icons.local_shipping},
    {"title": "Van", "icon": Icons.airport_shuttle},
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.browseByCategory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
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

                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(selectedCategory);
                  }

                  // Navigate to category page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CarsCategoryPage(category: selectedCategory),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 14),
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                        ? AppColors.darkLayer
                        // ? AppColors.darkAccent
                        : Colors.white,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primary.withValues(alpha: .08),
                        ),
                        child: Icon(
                          category["icon"],
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        carPropertiesTranslations(context, category["title"]),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : null,
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
}
