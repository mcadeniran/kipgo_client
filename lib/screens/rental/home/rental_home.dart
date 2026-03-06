import 'package:flutter/material.dart';
import 'package:kipgo/models/car_model.dart';
import 'package:kipgo/screens/rental/home/widgets/car_categories.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_cars.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_rental_companies_section.dart';
import 'package:kipgo/screens/rental/widgets/filter_bottom_sheet.dart';
import 'package:kipgo/screens/rental/widgets/search_bar_widget.dart';
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';

final List<CarModel> allCars = [
  CarModel(name: "BMW X5", brand: "BMW", pricePerDay: 2400, category: "SUV"),
  CarModel(
    name: "Toyota Camry",
    brand: "Toyota",
    pricePerDay: 1500,
    category: "Sedan",
  ),
  CarModel(
    name: "Mercedes C300",
    brand: "Mercedes",
    pricePerDay: 2800,
    category: "Luxury",
  ),
  CarModel(
    name: "Lexus RX",
    brand: "Lexus",
    pricePerDay: 2600,
    category: "SUV",
  ),
];

class RentalHome extends StatefulWidget {
  const RentalHome({super.key});

  @override
  State<RentalHome> createState() => _RentalHomeState();
}

class _RentalHomeState extends State<RentalHome> {
  final TextEditingController searchController = TextEditingController();

  List<CarModel> filteredCars = [];
  String selectedCategory = "All";

  bool showSearchOverlay = false;

  // void _filterCars() {
  //   setState(() {
  //     filteredCars = allCars.where((car) {
  //       final matchesSearch =
  //           car.name.toLowerCase().contains(
  //             searchController.text.toLowerCase(),
  //           ) ||
  //           car.brand.toLowerCase().contains(
  //             searchController.text.toLowerCase(),
  //           );

  //       final matchesCategory =
  //           selectedCategory == "All" || car.category == selectedCategory;

  //       return matchesSearch && matchesCategory;
  //     }).toList();
  //   });
  // }

  void _filterCars() {
    final query = searchController.text.toLowerCase();

    setState(() {
      showSearchOverlay = query.isNotEmpty;

      filteredCars = allCars.where((car) {
        return car.name.toLowerCase().contains(query) ||
            car.brand.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterBottomSheet(
          selectedCategory: selectedCategory,
          onApply: (category) {
            setState(() {
              selectedCategory = category;
            });
            _filterCars();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    filteredCars = allCars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'KIPGO RENTALS', showLanguage: false),
      backgroundColor: AppColors.primary,
      // body: Container(
      //   height: double.maxFinite,
      //   width: double.maxFinite,
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(20),
      //       topRight: Radius.circular(20),
      //     ),
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //   ),
      //   child: SingleChildScrollView(
      //     padding: EdgeInsets.all(12),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Expanded(
      //               child: SearchBarWidget(
      //                 controller: searchController,
      //                 onChanged: (_) => _filterCars(),
      //               ),
      //             ),
      //             const SizedBox(width: 8),
      //             IconButton.outlined(
      //               onPressed: _openFilterSheet,
      //               icon: const Icon(Icons.filter_alt_outlined),
      //             ),
      //           ],
      //         ),
      //         SizedBox(height: 22),
      //         // Expanded(
      //         //   child: ListView.builder(
      //         //     itemCount: filteredCars.length,
      //         //     itemBuilder: (context, index) {
      //         //       final car = filteredCars[index];
      //         //       return ListTile(
      //         //         title: Text(car.name),
      //         //         subtitle: Text("${car.brand} • ₦${car.pricePerDay}/day"),
      //         //       );
      //         //     },
      //         //   ),
      //         // ),
      //         SizedBox(height: 22),
      //         CarCategories(),
      //         SizedBox(height: 22),
      //         FeaturedCars(),
      //         SizedBox(height: 20),
      //         AdsCarouselWidget(),
      //         SizedBox(height: 20),
      //         FeaturedRentalCompaniesSection(),
      //         SizedBox(height: 20),
      //       ],
      //     ),
      //   ),
      // ),
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
            onChanged: (_) => _filterCars(),
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
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showSearchOverlay = false;
            searchController.clear();
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.25),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              padding: const EdgeInsets.all(16),
              height: 350,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                itemCount: filteredCars.length,
                itemBuilder: (context, index) {
                  final car = filteredCars[index];
                  return ListTile(
                    title: Text(car.name),
                    subtitle: Text("${car.brand} • ₦${car.pricePerDay}/day"),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
