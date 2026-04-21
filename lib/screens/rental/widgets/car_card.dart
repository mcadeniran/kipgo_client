import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarCard extends StatelessWidget {
  final CarWithShop car;
  final int totalCars;
  const CarCard({super.key, required this.car, required this.totalCars});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        splashColor: Colors.red,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
        ),
        child: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Stack(
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeIn,
                            fadeInDuration: Duration(seconds: 2),
                            width: double.maxFinite,
                            height: 180,
                            fit: BoxFit.cover,
                            placeholder: "assets/images/image_spinner.gif",
                            image: car.car.images
                                .lastWhere((c) => c.isCover == true)
                                .url,
                            imageErrorBuilder: (c, e, s) => Image.asset(
                              "assets/images/placeholder.jpeg",
                              height: 180,
                              width: double.maxFinite,
                              fit: BoxFit.cover,
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                            "${car.car.brand} ${car.car.model} ${car.car.year}",
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              StarRating(
                                rating: car.car.rating,
                                size: 14,
                                color: Colors.amber,
                                mainAxisAlignment: MainAxisAlignment.start,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "(${car.car.totalRatings})",
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          if (car.hasDiscount) ...[
                            Text(
                              formatCurrency(
                                amount: car.basePrice,
                                currencyCode:
                                    car.car.currency ?? car.shop.currency,
                                context: context,
                              ),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.amountPerDay(
                                formatCurrency(
                                  amount: car.finalPrice,
                                  context: context,
                                  currencyCode:
                                      car.car.currency ?? car.shop.currency,
                                ),
                              ),
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: Colors.red),
                            ),
                          ],
                          if (!car.hasDiscount)
                            Text(
                              AppLocalizations.of(context)!.amountPerDay(
                                formatCurrency(
                                  amount: car.finalPrice,
                                  context: context,
                                  currencyCode:
                                      car.car.currency ?? car.shop.currency,
                                ),
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          SizedBox(height: 5),
                          Divider(thickness: 0, height: 1),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RentalCompanyDetailPage(company: car.shop),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                ),
                                SizedBox(width: 5),
                                Text(car.car.shop.name),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(thickness: 0, height: 1),
                          SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            runSpacing: 0,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_gas_station_outlined,
                                    size: 16,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    carPropertiesTranslations(
                                      context,
                                      car.car.fuel,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
