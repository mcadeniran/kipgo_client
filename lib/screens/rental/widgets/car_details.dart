import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kipgo/screens/rental/widgets/car_booking_page.dart';
import 'package:kipgo/screens/rental/widgets/reviews_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';

class CarDetailsPage extends StatelessWidget {
  const CarDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;
    final paddingTop = MediaQuery.of(context).padding.top;

    List<String> features = [
      "Air Conditioning",
      "Bluetooth",
      "Reverse Camera",
      "GPS",
      "Airbags",
      "USB Charger",
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            //  🔥 TOP IMAGE SECTION
            SizedBox(
              height: size.height * 0.35,
              width: double.infinity,
              child: PageView(
                children: [
                  Image.asset("assets/images/ford.jpg", fit: BoxFit.fill),
                  Image.asset("assets/images/ford.jpeg", fit: BoxFit.fill),
                ],
              ),
            ),

            /// 🔙 BACK BUTTON
            Positioned(
              top: paddingTop + 10,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            /// 🔥 BOTTOM DETAILS SECTION
            Positioned(
              top: size.height * 0.32, // overlap
              left: 0,
              right: 0,
              bottom: 0, // fill remaining screen
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ford Focus 2014",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text("4.8 (124 reviews)"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkLayer
                              : AppColors.lightLayer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundColor: AppColors.primary,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.primary,
                                    backgroundImage: AssetImage(
                                      'assets/images/anadolu.jpg',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Anadolu Rentals",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "5.0",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(Icons.circle, size: 5),
                                        SizedBox(width: 2),
                                        Text(
                                          "14 reviews",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _showRentalRules(context, isDark),
                              label: Text(
                                "Rental rules",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              icon: Icon(Icons.chevron_right_outlined),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _SpecItem(icon: Icons.settings, label: "Automatic"),
                          _SpecItem(
                            icon: Icons.local_gas_station,
                            label: "Hybrid",
                          ),
                          _SpecItem(icon: Icons.event_seat, label: "5 Seats"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Features",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: features
                            .map(
                              (feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.lightLayer.withValues(
                                          alpha: 0.15,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ReviewsWidget(),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'from',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.5),
                                      letterSpacing: 0.2,
                                    ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₺1200 ",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "/ day",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CarBookingPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: size.height * 0.05), // padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showRentalRules(BuildContext context, bool isDark) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.85,
  //         decoration: BoxDecoration(
  //           color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
  //         ),
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 12),

  //             /// 🔘 Drag Handle
  //             Container(
  //               width: 50,
  //               height: 5,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade400,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),

  //             const SizedBox(height: 20),

  //             Expanded(
  //               child: SingleChildScrollView(
  //                 physics: const BouncingScrollPhysics(),
  //                 padding: const EdgeInsets.symmetric(horizontal: 20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: const [
  //                     _RuleItem(
  //                       title: "Security Deposit",
  //                       description:
  //                           "A refundable security deposit of ₺3,000 is required at pickup. The amount will be held on your card and released within 5–10 business days after return, subject to inspection.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Fuel Policy",
  //                       description:
  //                           "Vehicle must be returned with the same fuel level as provided. Missing fuel will be charged at market rate plus service fee.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Mileage Limit",
  //                       description:
  //                           "Daily limit of 250 km. Additional mileage will be charged at ₺5 per km.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Insurance Coverage",
  //                       description:
  //                           "Basic insurance is included. Excess liability applies in case of damage. Optional full coverage insurance can be purchased at checkout.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Late Return Policy",
  //                       description:
  //                           "A grace period of 60 minutes applies. After that, an additional full-day rental fee may be charged.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Cancellation Policy",
  //                       description:
  //                           "Free cancellation up to 24 hours before pickup. Late cancellations may incur a 1-day rental charge.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Taxes & Fees",
  //                       description:
  //                           "All prices include VAT. Additional charges may apply for airport delivery or optional add-ons.",
  //                     ),
  //                     _RuleItem(
  //                       title: "Driver Requirements",
  //                       description:
  //                           "Minimum age: 21 years. Minimum 2 years valid driving license required.",
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showRentalRules(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  /// 🔘 Drag Handle
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Rental Rules",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Rules Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: const [
                          _GlassRuleCard(
                            icon: Icons.lock_outline,
                            title: "Security Deposit",
                            description:
                                "₺3,000 refundable deposit required at pickup. Released within 5–10 business days after inspection.",
                          ),
                          _GlassRuleCard(
                            icon: Icons.local_gas_station,
                            title: "Fuel Policy",
                            description:
                                "Return with same fuel level. Missing fuel charged at market rate + service fee.",
                          ),
                          _GlassRuleCard(
                            icon: Icons.speed,
                            title: "Mileage Limit",
                            description:
                                "250 km/day included. Extra distance charged at ₺5 per km.",
                          ),
                          _GlassRuleCard(
                            icon: Icons.shield_outlined,
                            title: "Insurance",
                            description:
                                "Basic insurance included. Optional full coverage available at checkout.",
                          ),
                          _GlassRuleCard(
                            icon: Icons.access_time,
                            title: "Late Return",
                            description:
                                "60-minute grace period. After that, a full day may be charged.",
                          ),
                          _GlassRuleCard(
                            icon: Icons.cancel_outlined,
                            title: "Cancellation",
                            description:
                                "Free cancellation up to 24 hours before pickup.",
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  /// 🔹 Bottom Button
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: AppColors.primary,
                  //         padding: const EdgeInsets.symmetric(vertical: 16),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(18),
                  //         ),
                  //         elevation: 0,
                  //       ),
                  //       onPressed: () => Navigator.pop(context),
                  //       child: const Text(
                  //         "I Understand",
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🔹 Small Spec Widget
class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Icon(icon, size: 26), const SizedBox(height: 6), Text(label)],
    );
  }
}

// class _RuleItem extends StatelessWidget {
//   final String title;
//   final String description;

//   const _RuleItem({required this.title, required this.description});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             description,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.5,
//               color: Theme.of(
//                 context,
//               ).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _GlassRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GlassRuleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
