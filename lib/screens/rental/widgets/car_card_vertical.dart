import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarCardVertical extends StatelessWidget {
  final CarWithShop car;
  const CarCardVertical({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? AppColors.darkAccent.withValues(alpha: 0.85)
            : AppColors.lightAccent.withValues(alpha: 0.85),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: car.hasDiscount
                  ? Row(
                      children: [
                        Text(
                          formatCurrency(
                            amount: car.basePrice,
                            currencyCode: car.car.currency ?? car.shop.currency,
                            context: context,
                          ),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.amountPerDay(
                            formatCurrency(
                              amount: car.finalPrice,
                              context: context,
                              currencyCode:
                                  car.car.currency ?? car.shop.currency,
                            ),
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(color: Colors.red),
                        ),
                      ],
                    )
                  : Text(
                      AppLocalizations.of(context)!.amountPerDay(
                        formatCurrency(
                          amount: car.finalPrice,
                          context: context,
                          currencyCode: car.car.currency ?? car.shop.currency,
                        ),
                      ),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    // height: 220,
                    child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeIn,
                      fadeInDuration: Duration(seconds: 2),
                      width: MediaQuery.of(context).size.width * 0.45,
                      fit: BoxFit.cover,
                      placeholder: "assets/images/image_spinner.gif",
                      image: car.car.images
                          .firstWhere((e) => e.isCover == true)
                          .url,
                      imageErrorBuilder: (c, e, s) => Image.asset(
                        "assets/images/placeholder.jpeg",
                        // height: 220,
                        width: MediaQuery.of(context).size.width * 0.45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.greenAccent, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.greenAccent.withValues(alpha: 0.6),
                      ),
                      child: Text(
                        "${car.car.availableUnits} Available",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (car.hasDiscount)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: ShapeDecoration(
                          color: Colors.red.withValues(alpha: .8),
                          shape: BeveledRectangleBorder(
                            side: BorderSide(color: Colors.red, width: 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        child: Text(
                          car.shop.discount!.type == 'fixed'
                              ? "-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context)}"
                              : car.discountLabel,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${car.car.brand} ${car.car.model} ${car.car.year}",
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text(
                          car.car.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '(${car.car.totalRatings})',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 2),
                      Text(
                        carPropertiesTranslations(
                          context,
                          car.car.transmission,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station_outlined,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 2),
                      Text(
                        carPropertiesTranslations(context, car.car.fuel),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 2),
                      Text(
                        "${car.car.seats}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CarBookingPage(car: car)),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
