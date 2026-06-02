import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/location_utils.dart';

class CarGridCard extends StatelessWidget {
  final CarWithShop car;
  final bool isDark;
  final Position? userPosition;
  const CarGridCard({
    super.key,
    required this.car,
    required this.isDark,
    this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
      ),

      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  FadeInImage.assetNetwork(
                    fadeInCurve: Curves.easeIn,
                    fadeInDuration: Duration(seconds: 2),
                    width: double.maxFinite,
                    // height: 120,
                    fit: BoxFit.cover,
                    placeholder: "assets/images/image_spinner.gif",
                    image: car.car.images
                        .firstWhere((img) => img.isCover == true)
                        .url,
                    imageErrorBuilder: (c, e, s) => Image.asset(
                      "assets/images/placeholder.jpeg",
                      // height: 120,
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '${car.car.rating} (${car.car.totalRatings})',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${car.car.year} ${car.car.brand} ${car.car.model}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        // wordSpacing: -2.5,
                        letterSpacing: -1,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.tertiary,
                  ),
                  SizedBox(width: 2),
                  Text(
                    car.car.city,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (userPosition != null)
                    Expanded(
                      child: Text(
                        " (${calculateDistance(userPosition!.latitude, userPosition!.longitude, car.car.location.lat, car.car.location.lng).round()} km)",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: Colors.grey.withValues(alpha: .25), height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 14,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_gas_station_outlined,
                        size: 14,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
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
            // Spacer(),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: car.hasDiscount
                  ? Row(
                      children: [
                        Text(
                          formatCurrency(
                            amount: car.basePrice,
                            currencyCode: car.car.currency ?? car.shop.currency,
                            context: context,
                            decimalDigits: 0,
                          ),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      AppLocalizations.of(context)!.amountPerDay(
                        formatCurrency(
                          amount: car.car.pricePerDay,
                          currencyCode: car.car.currency ?? car.shop.currency,
                          context: context,
                        ),
                      ),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
