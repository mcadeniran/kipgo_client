import 'package:flutter/material.dart';
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
    {"title": "SUV", "icon": Icons.directions_car},
    {"title": "Sedan", "icon": Icons.airport_shuttle},
    {"title": "Luxury", "icon": Icons.star},
    {"title": "Electric", "icon": Icons.electric_car},
    {"title": "Van", "icon": Icons.airport_shuttle_outlined},
    {"title": "Pickup", "icon": Icons.local_shipping},
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Browse by Category",
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

                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(category["title"]);
                  }
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
                        ? AppColors.darkAccent
                        : Colors.white,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
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
                              : AppColors.primary.withOpacity(0.08),
                        ),
                        child: Icon(
                          category["icon"],
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category["title"],
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
