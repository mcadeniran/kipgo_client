import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:provider/provider.dart';

class FilterSheet extends StatefulWidget {
  final String category;

  const FilterSheet({super.key, required this.category});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues priceRange = const RangeValues(500, 10000);
  int? seats;
  String? fuel;
  String? transmission;
  double radius = 10;
  late AppLocalizations loc;

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
  void initState() {
    super.initState();

    final provider = Provider.of<CarProvider>(context, listen: false);

    // priceRange = RangeValues(
    //   provider.minPrice ?? 500,
    //   provider.maxPrice ?? 10000,
    // );

    seats = provider.seats;
    fuel = provider.fuel;
    transmission = provider.transmission;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<CarProvider>(context, listen: false);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.filters,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            Text(loc.distanceInKM),

            Slider.adaptive(
              value: radius,
              min: 1,
              max: 50,
              divisions: 10,
              label: loc.distanceKM(radius.round()),
              onChanged: (value) {
                setState(() {
                  radius = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 🔥 Price Range
            // Text(loc.priceRange),
            // RangeSlider(
            //   values: priceRange,
            //   min: 500,
            //   max: 10000,
            //   divisions: 100,
            //   labels: RangeLabels(
            //     "₺${priceRange.start.round()}",
            //     "₺${priceRange.end.round()}",
            //   ),
            //   onChanged: (values) {
            //     setState(() {
            //       priceRange = values;
            //     });
            //   },
            // ),

            // 🔥 Seats
            DropdownButtonFormField<int>(
              hint: Text(loc.seatsLabel),
              value: seats,
              items: [2, 4, 5, 7]
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(loc.seats(e))),
                  )
                  .toList(),
              onChanged: (value) => setState(() => seats = value),
            ),

            const SizedBox(height: 10),

            // 🔥 Fuel
            DropdownButtonFormField<String>(
              hint: Text(loc.fuelType),
              value: fuel,
              items: ["Petrol", "Diesel", "Electric", "Hybrid"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(carPropertiesTranslations(context, e)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => fuel = value),
            ),

            const SizedBox(height: 10),

            // 🔥 Transmission
            DropdownButtonFormField<String>(
              hint: Text(loc.transmission),
              value: transmission,
              items: ["Automatic", "Manual"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(carPropertiesTranslations(context, e)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => transmission = value),
            ),

            const Spacer(),

            // 🔥 Apply Button
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<CarProvider>(
                  context,
                  listen: false,
                );

                final position = await getUserLocation();

                provider.userLat = position.latitude;
                provider.userLng = position.longitude;
                provider.radiusKm = radius;
                provider.applyFilters(
                  category: widget.category,
                  minPrice: priceRange.start,
                  maxPrice: priceRange.end,
                  seats: seats,
                  fuel: fuel,
                  transmission: transmission,
                );

                Navigator.pop(context);
              },
              child: Text(loc.applyFilters),
            ),
          ],
        ),
      ),
    );
  }
}
