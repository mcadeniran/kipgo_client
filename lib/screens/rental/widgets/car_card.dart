import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa_solid.dart' show FaSolid;
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/icons/la.dart';

class CarCard extends StatelessWidget {
  const CarCard({super.key});

  @override
  Widget build(BuildContext context) {
    List<bool> selected = [true, true];
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return InkWell(
      splashColor: Colors.red,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CarDetailsPage()),
      ),
      child: SizedBox(
        width: 380,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Image.asset('assets/images/ford.jpeg'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.verified, size: 18, color: Colors.green),
                        SizedBox(width: 5),
                        Text("Bariş Rentals"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ford Focus 2014",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          StarRating(
                            rating: 4.5,
                            size: 18,
                            color: Colors.amber,
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "(123)",
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                      Text(
                        "₺1200/day",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(12),
                        borderWidth: 0,
                        selectedColor: AppColors.primary,
                        fillColor: AppColors.primary,
                        color: AppColors.border,
                        isSelected: selected,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Iconify(
                                  La.cogs,
                                  size: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Automatic",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // child: Iconify(Ic.my_location),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Iconify(
                                  FaSolid.gas_pump,
                                  size: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Hybrid",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // child: Iconify(Ic.location_on),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
