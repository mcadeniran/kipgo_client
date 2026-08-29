import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/screens/rental/widgets/car_details.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

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

  String? _getImageUrl() {
    if (car.car.images.isEmpty) {
      return null;
    }

    try {
      return car.car.images.lastWhere((image) => image.isCover == true).url;
    } catch (_) {
      return car.car.images.first.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = car.car.currency ?? car.shop.currency;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .05)
                  : Colors.black.withValues(alpha: .025),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .16 : .055),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 10, child: _buildImage(context)),

                Expanded(
                  flex: 9,
                  child: _buildDetails(context, currency, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = _getImageUrl();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDark
              ? AppColors.darkLayer.withValues(alpha: .25)
              : AppColors.primary.withValues(alpha: .025),
          child: imageUrl == null
              ? Image.asset('assets/images/placeholder.jpeg', fit: BoxFit.cover)
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return Center(
                      child: Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: isDark
                            ? AppColors.darkAccent
                            : AppColors.lightAccent,
                        highlightColor: isDark
                            ? AppColors.darkLayer.withValues(alpha: .3)
                            : AppColors.border,
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/images/placeholder.jpeg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
        ),

        // Bottom image gradient.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 65,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .45),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Rating.
        Positioned(
          top: 9,
          left: 9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .52),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                const SizedBox(width: 3),
                Text(
                  '${car.car.review.average}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '(${car.car.review.totalReviews})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Discount.
        if (car.hasDiscount)
          Positioned(
            top: 9,
            right: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                car.shop.discount!.type == 'fixed'
                    ? '-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context, decimalDigits: 0)}'
                    : car.discountLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        // Location.
        Positioned(
          left: 9,
          bottom: 9,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                car.car.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Arrow.
        Positioned(
          right: 9,
          bottom: 9,
          child: Container(
            height: 27,
            width: 27,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .92),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, String currency, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${car.car.brand} ${car.car.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -.15,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              Text(
                '${car.car.year}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Wrap(
            spacing: 7,
            runSpacing: 3,
            children: [
              _spec(
                context,
                Icons.settings_outlined,
                carPropertiesTranslations(context, car.car.transmission),
              ),
              _spec(
                context,
                Icons.local_gas_station_outlined,
                carPropertiesTranslations(context, car.car.fuel),
              ),
              _spec(context, Icons.people_outline_rounded, '${car.car.seats}'),
            ],
          ),

          const Spacer(),

          if (car.hasDiscount)
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                formatCurrency(
                  amount: car.basePrice,
                  currencyCode: currency,
                  context: context,
                  decimalDigits: 0,
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey.shade400,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.amountPerDay(
                    formatCurrency(
                      amount: car.finalPrice,
                      currencyCode: currency,
                      context: context,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: car.hasDiscount
                        ? Colors.red.shade600
                        : isDark
                        ? AppColors.lightLayer
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spec(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.blueGrey.shade400),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            color: isDark
                ? Colors.white.withValues(alpha: .60)
                : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// class CarGridCard extends StatelessWidget {
//   final CarWithShop car;
//   final bool isDark;
//   final Position? userPosition;

//   const CarGridCard({
//     super.key,
//     required this.car,
//     required this.isDark,
//     this.userPosition,
//   });

//   String _getImageUrl() {
//     if (car.car.images.isEmpty) {
//       return '';
//     }

//     final cover = car.car.images.where((image) => image.isCover == true);

//     if (cover.isNotEmpty) {
//       return cover.first.url;
//     }

//     return car.car.images.first.url;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currency = car.car.currency ?? car.shop.currency;

//     final imageUrl = _getImageUrl();

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
//           );
//         },
//         borderRadius: BorderRadius.circular(20),
//         child: Ink(
//           decoration: BoxDecoration(
//             color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: .055),
//                 blurRadius: 18,
//                 offset: const Offset(0, 7),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(flex: 11, child: _buildImage(context, imageUrl)),

//                 Expanded(flex: 9, child: _buildDetails(context, currency)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImage(BuildContext context, String imageUrl) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         imageUrl.isEmpty
//             ? Image.asset('assets/images/placeholder.jpeg', fit: BoxFit.cover)
//             : Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 gaplessPlayback: true,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) {
//                     return child;
//                   }

//                   return Container(
//                     color: isDark
//                         ? AppColors.darkAccent
//                         : AppColors.lightAccent,
//                     alignment: Alignment.center,
//                     child: Shimmer.fromColors(
//                       direction: ShimmerDirection.ltr,
//                       baseColor: isDark
//                           ? AppColors.darkAccent
//                           : AppColors.lightAccent,
//                       highlightColor: isDark
//                           ? AppColors.darkLayer.withValues(alpha: .35)
//                           : AppColors.border,
//                       child: Icon(
//                         Icons.directions_car_rounded,
//                         size: 62,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   );
//                 },
//                 errorBuilder: (_, __, ___) {
//                   return Image.asset(
//                     'assets/images/placeholder.jpeg',
//                     fit: BoxFit.cover,
//                   );
//                 },
//               ),

//         // Gradient for readability.
//         Positioned.fill(
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.black.withValues(alpha: .25),
//                   Colors.transparent,
//                   Colors.black.withValues(alpha: .25),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Rating.
//         Positioned(
//           top: 10,
//           left: 10,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: .55),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withValues(alpha: .15)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
//                 const SizedBox(width: 3),
//                 Text(
//                   car.car.rating.toStringAsFixed(1),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Discount.
//         if (car.hasDiscount)
//           Positioned(
//             top: 10,
//             right: 10,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.redAccent,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.redAccent.withValues(alpha: .3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 car.shop.discount!.type == 'fixed'
//                     ? '-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context, decimalDigits: 0)}'
//                     : car.discountLabel,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),

//         // Bottom image label.
//         Positioned(
//           left: 10,
//           bottom: 10,
//           right: 10,
//           child: Row(
//             children: [
//               _ImageTag(
//                 icon: Icons.settings_rounded,
//                 text: carPropertiesTranslations(context, car.car.transmission),
//               ),
//               const SizedBox(width: 5),
//               _ImageTag(
//                 icon: Icons.people_alt_outlined,
//                 text: '${car.car.seats}',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetails(BuildContext context, String currency) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${car.car.brand} ${car.car.model}',
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w700,
//               fontSize: 14,
//             ),
//           ),

//           const SizedBox(height: 3),

//           Row(
//             children: [
//               Icon(
//                 Icons.location_on_outlined,
//                 size: 13,
//                 color: AppColors.tertiary,
//               ),
//               const SizedBox(width: 2),
//               Expanded(
//                 child: Text(
//                   car.car.city,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: isDark ? Colors.white60 : Colors.black54,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const Spacer(),

//           if (car.hasDiscount)
//             Text(
//               formatCurrency(
//                 amount: car.basePrice,
//                 currencyCode: currency,
//                 context: context,
//                 decimalDigits: 0,
//               ),
//               style: TextStyle(
//                 fontSize: 10,
//                 decoration: TextDecoration.lineThrough,
//                 color: isDark ? Colors.white54 : Colors.black45,
//               ),
//             ),

//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Expanded(
//                 child: Text(
//                   AppLocalizations.of(context)!.amountPerDay(
//                     formatCurrency(
//                       amount: car.finalPrice,
//                       context: context,
//                       currencyCode: currency,
//                     ),
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w800,
//                     color: car.hasDiscount ? Colors.redAccent : null,
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 4),

//               Icon(
//                 Icons.arrow_forward_rounded,
//                 size: 17,
//                 color: AppColors.primary,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ImageTag extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const _ImageTag({required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: .55),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: Colors.white),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 9,
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CarGridCard extends StatelessWidget {
//   final CarWithShop car;
//   final bool isDark;
//   final Position? userPosition;
//   const CarGridCard({
//     super.key,
//     required this.car,
//     required this.isDark,
//     this.userPosition,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => CarDetailsPage(car: car)),
//       ),

//       child: Container(
//         clipBehavior: Clip.hardEdge,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   Image.network(
//                     car.car.images.firstWhere((img) => img.isCover == true).url,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     gaplessPlayback: true,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;

//                       return SizedBox(
//                         width: double.maxFinite,
//                         child: Center(
//                           child: Shimmer.fromColors(
//                             direction: ShimmerDirection.ltr,
//                             baseColor: isDark
//                                 ? AppColors.darkAccent
//                                 : AppColors.lightAccent,
//                             highlightColor: isDark
//                                 ? AppColors.darkLayer.withValues(alpha: 0.3)
//                                 : AppColors.border,
//                             child: Icon(
//                               Icons.directions_car_outlined,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     errorBuilder: (_, _, _) => Image.asset(
//                       "assets/images/placeholder.jpeg",
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                     ),
//                   ),

//                   Positioned(
//                     top: 4,
//                     left: 4,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withValues(alpha: 0.5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Icon(Icons.star, size: 14, color: Colors.amber),
//                           SizedBox(width: 4),
//                           Text(
//                             '${car.car.rating} (${car.car.totalRatings})',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   if (car.hasDiscount)
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: Container(
//                         padding: EdgeInsets.all(2),
//                         decoration: ShapeDecoration(
//                           color: Colors.red.withValues(alpha: .8),
//                           shape: BeveledRectangleBorder(
//                             side: BorderSide(color: Colors.red, width: 1),
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(8),
//                               bottomLeft: Radius.circular(8),
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           car.shop.discount!.type == 'fixed'
//                               ? "-${formatCurrency(amount: car.shop.discount!.value, currencyCode: car.car.currency ?? car.shop.currency, context: context)}"
//                               : car.discountLabel,
//                           style: TextStyle(fontSize: 12, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 6),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${car.car.year} ${car.car.brand} ${car.car.model}",
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                         letterSpacing: -1,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 2),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.location_on_outlined,
//                     size: 14,
//                     color: AppColors.tertiary,
//                   ),
//                   SizedBox(width: 2),
//                   Text(
//                     car.car.city,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(color: Colors.grey.withValues(alpha: .25), height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: Wrap(
//                 spacing: 5,
//                 runSpacing: 5,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.settings_outlined,
//                         size: 14,
//                         color: Colors.blueGrey,
//                       ),
//                       SizedBox(width: 2),
//                       Text(
//                         carPropertiesTranslations(
//                           context,
//                           car.car.transmission,
//                         ),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.local_gas_station_outlined,
//                         size: 14,
//                         color: Colors.blueGrey,
//                       ),
//                       SizedBox(width: 2),
//                       Text(
//                         carPropertiesTranslations(context, car.car.fuel),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.people_outline,
//                         size: 14,
//                         color: Colors.blueGrey,
//                       ),
//                       SizedBox(width: 2),
//                       Text(
//                         "${car.car.seats}",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Spacer(),
//             SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: car.hasDiscount
//                   ? Row(
//                       children: [
//                         Text(
//                           formatCurrency(
//                             amount: car.basePrice,
//                             currencyCode: car.car.currency ?? car.shop.currency,
//                             context: context,
//                             decimalDigits: 0,
//                           ),
//                           style: TextStyle(
//                             decoration: TextDecoration.lineThrough,
//                             fontSize: 12,
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           AppLocalizations.of(context)!.amountPerDay(
//                             formatCurrency(
//                               amount: car.finalPrice,
//                               context: context,
//                               currencyCode:
//                                   car.car.currency ?? car.shop.currency,
//                             ),
//                           ),
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     )
//                   : Text(
//                       AppLocalizations.of(context)!.amountPerDay(
//                         formatCurrency(
//                           amount: car.car.pricePerDay,
//                           currencyCode: car.car.currency ?? car.shop.currency,
//                           context: context,
//                         ),
//                       ),
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
