import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/models/rating_distribution.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental/widgets/car_card_vertical.dart';
import 'package:kipgo/screens/rental/widgets/rating_summary_card.dart';
import 'package:kipgo/screens/rental/widgets/recent_reviews_section.dart';
import 'package:kipgo/screens/rental/widgets/reviews_page.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
// import 'package:url_launcher/url_launcher.dart';

// Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   await launchUrl(launchUri);
// }

class RentalCompanyDetailPage extends StatefulWidget {
  final RentalShop? company;
  final String? companyId;

  const RentalCompanyDetailPage({super.key, this.company, this.companyId})
    : assert(
        company != null || companyId != null,
        "Either company or companyId must be provided",
      );

  @override
  State<RentalCompanyDetailPage> createState() =>
      _RentalCompanyDetailPageState();
}

class _RentalCompanyDetailPageState extends State<RentalCompanyDetailPage> {
  RentalShop? company;
  bool isLoading = true;
  bool isReviewLoading = true;
  List<CarRatingModel> companyReviews = [];

  bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;

    final uri = Uri.tryParse(url);

    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  void initState() {
    super.initState();

    if (widget.company != null) {
      company = widget.company;
      isLoading = false;

      Future.microtask(() {
        Provider.of<CarRatingProvider>(
          context,
          listen: false,
        ).fetchShopRatings(company!.id);
      });

      _fetchCars(company!.id);
    } else {
      fetchCompany();
    }
  }

  Future<void> fetchCompany() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rentalShops')
          .doc(widget.companyId)
          .get();

      if (doc.exists) {
        final fetchedCompany = RentalShop.fromFirestore(
          doc.data()!,
          widget.companyId!,
        );

        setState(() {
          company = fetchedCompany;
          isLoading = false;
        });

        Future.microtask(() {
          Provider.of<CarRatingProvider>(
            context,
            listen: false,
          ).fetchShopRatings(company!.id);
        });

        _fetchCars(fetchedCompany.id); // ✅ fetch AFTER company is ready
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _fetchCars(String shopId) {
    Future.microtask(() {
      Provider.of<CarProvider>(context, listen: false).fetchCarsByShop(shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: (isLoading || company == null)
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                /// 🔥 Banner AppBar
                SliverAppBar(
                  expandedHeight: 280,
                  collapsedHeight: 64,
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,

                  iconTheme: const IconThemeData(color: Colors.white),

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,

                    titlePadding: const EdgeInsets.only(
                      left: 56,
                      right: 20,
                      bottom: 14,
                    ),

                    title: Text(
                      company!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // =========================================================
                        // BANNER
                        // =========================================================
                        isValidImageUrl(company!.bannerUrl)
                            ? Image.network(
                                company!.bannerUrl,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,

                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return Image.asset(
                                    'assets/images/image_spinner.gif',
                                    fit: BoxFit.cover,
                                  );
                                },

                                errorBuilder: (_, __, ___) {
                                  return Image.asset(
                                    'assets/images/placeholder.jpeg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/placeholder.jpeg',
                                fit: BoxFit.cover,
                              ),

                        // =========================================================
                        // PREMIUM OVERLAY
                        // =========================================================
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.35, 0.72, 1.0],
                                colors: [
                                  Colors.black.withValues(alpha: .38),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: .18),
                                  Colors.black.withValues(alpha: .78),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // =========================================================
                        // VERIFIED BADGE
                        // =========================================================
                        Positioned(
                          left: 18,
                          top: 120,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    loc.verifiedRentalCompany,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🔥 Company Info Section
                SliverToBoxAdapter(
                  child: Container(
                    transform: Matrix4.translationValues(0, 0, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Company Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===========================================================
                              // COMPANY IDENTITY
                              // ===========================================================
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkAccent.withValues(
                                          alpha: .96,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),

                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .06)
                                        : AppColors.border.withValues(
                                            alpha: .35,
                                          ),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? .20 : .06,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // -------------------------------------------------------
                                    // LOGO + COMPANY NAME
                                    // -------------------------------------------------------
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Logo
                                        Container(
                                          width: 68,
                                          height: 68,
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.tertiary,
                                              ],
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDark
                                                  ? AppColors.darkAccent
                                                  : Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: ClipOval(
                                              child:
                                                  isValidImageUrl(company!.logo)
                                                  ? Image.network(
                                                      company!.logo,
                                                      fit: BoxFit.cover,
                                                      gaplessPlayback: true,

                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            progress,
                                                          ) {
                                                            if (progress ==
                                                                null) {
                                                              return child;
                                                            }

                                                            return Image.asset(
                                                              'assets/images/image_spinner.gif',
                                                              fit: BoxFit.cover,
                                                            );
                                                          },

                                                      errorBuilder: (_, __, ___) {
                                                        return Image.asset(
                                                          'assets/images/avatar.png',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/images/avatar.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        // Company information
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      company!.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 6),

                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withValues(
                                                            alpha: .10,
                                                          ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.verified_rounded,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 7),

                                              // Rating
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber
                                                          .withValues(
                                                            alpha: .12,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.star_rounded,
                                                          color: Colors.amber,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          company!
                                                              .review
                                                              .average
                                                              .toStringAsFixed(
                                                                1,
                                                              ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(width: 7),

                                                  Text(
                                                    company!
                                                                .review
                                                                .totalReviews ==
                                                            1
                                                        ? AppLocalizations.of(
                                                            context,
                                                          )!.singleReview(
                                                            company!
                                                                .review
                                                                .totalReviews,
                                                          )
                                                        : AppLocalizations.of(
                                                            context,
                                                          )!.multiReviews(
                                                            company!
                                                                .review
                                                                .totalReviews,
                                                          ),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color
                                                                  ?.withValues(
                                                                    alpha: .65,
                                                                  ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    // -------------------------------------------------------
                                    // LOCATION
                                    // -------------------------------------------------------
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: .04,
                                              )
                                            : AppColors.lightLayer.withValues(
                                                alpha: .10,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.lightLayer
                                                        .withValues(alpha: 0.08)
                                                  : AppColors.primary
                                                        .withValues(alpha: .10),
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                            ),
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              size: 18,
                                              color: isDark
                                                  ? AppColors.lightLayer
                                                  : AppColors.primary,
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.location,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.color
                                                            ?.withValues(
                                                              alpha: .55,
                                                            ),
                                                      ),
                                                ),

                                                const SizedBox(height: 2),

                                                Text(
                                                  '${company!.address}, '
                                                  '${company!.district}, '
                                                  '${company!.city}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.35,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // -------------------------------------------------------
                                    // CONTACT
                                    // -------------------------------------------------------
                                    // InkWell(
                                    //   onTap: () => _makePhoneCall(
                                    //     context,
                                    //     company!.phone,
                                    //   ),
                                    //   borderRadius: BorderRadius.circular(16),
                                    //   child: Container(
                                    //     padding: const EdgeInsets.all(12),
                                    //     decoration: BoxDecoration(
                                    //       color: isDark
                                    //           ? Colors.white.withValues(
                                    //               alpha: .04,
                                    //             )
                                    //           : AppColors.lightLayer.withValues(
                                    //               alpha: .10,
                                    //             ),
                                    //       borderRadius: BorderRadius.circular(
                                    //         16,
                                    //       ),
                                    //     ),
                                    //     child: Row(
                                    //       children: [
                                    //         Container(
                                    //           width: 36,
                                    //           height: 36,
                                    //           decoration: BoxDecoration(
                                    //             color: AppColors.tertiary
                                    //                 .withValues(alpha: .10),
                                    //             borderRadius:
                                    //                 BorderRadius.circular(11),
                                    //           ),
                                    //           child: const Icon(
                                    //             Icons.phone_rounded,
                                    //             size: 17,
                                    //             color: AppColors.tertiary,
                                    //           ),
                                    //         ),

                                    //         const SizedBox(width: 10),

                                    //         Expanded(
                                    //           child: Column(
                                    //             crossAxisAlignment:
                                    //                 CrossAxisAlignment.start,
                                    //             children: [
                                    //               Text(
                                    //                 'Contact company',
                                    //                 style: Theme.of(context)
                                    //                     .textTheme
                                    //                     .labelSmall
                                    //                     ?.copyWith(
                                    //                       color:
                                    //                           Theme.of(context)
                                    //                               .textTheme
                                    //                               .bodySmall
                                    //                               ?.color
                                    //                               ?.withValues(
                                    //                                 alpha: .55,
                                    //                               ),
                                    //                     ),
                                    //               ),

                                    //               const SizedBox(height: 2),

                                    //               Text(
                                    //                 company!.phone,
                                    //                 style: const TextStyle(
                                    //                   fontSize: 13,
                                    //                   fontWeight:
                                    //                       FontWeight.w600,
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),

                                    //         Icon(
                                    //           Icons.arrow_forward_ios_rounded,
                                    //           size: 14,
                                    //           color: Theme.of(context)
                                    //               .iconTheme
                                    //               .color
                                    //               ?.withValues(alpha: .45),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ===========================================================
                              // ABOUT COMPANY
                              // ===========================================================
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkAccent.withValues(
                                          alpha: .96,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),

                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .06)
                                        : AppColors.border.withValues(
                                            alpha: .35,
                                          ),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? .16 : .05,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.lightLayer
                                                      .withValues(alpha: 0.08)
                                                : AppColors.primary.withValues(
                                                    alpha: .10,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.business_rounded,
                                            size: 19,
                                            color: isDark
                                                ? AppColors.lightLayer
                                                : AppColors.primary,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Text(
                                          loc.aboutTheCompany,
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    Container(
                                      width: 36,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: AppColors.tertiary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      company!.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 13.5,
                                            height: 1.65,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withValues(alpha: .78),
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Consumer<CarRatingProvider>(
                          builder: (context, ratingProvider, child) {
                            if (ratingProvider.loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final reviews = ratingProvider.ratings;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.guestReviews,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  loc.seeWhatOthersTravellersCompany,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: .6),
                                      ),
                                ),

                                const SizedBox(height: 14),

                                RatingSummaryCard(
                                  type: RatingSummaryType.company,
                                  average: company!.review.average,
                                  totalReviews: company!.review.totalReviews,

                                  distribution: RatingDistribution(
                                    one: company!.review.distribution.one,
                                    two: company!.review.distribution.two,
                                    three: company!.review.distribution.three,
                                    four: company!.review.distribution.four,
                                    five: company!.review.distribution.five,
                                  ),

                                  communication: company!.review.communication,
                                  pickupExperience:
                                      company!.review.pickupExperience,
                                  professionalism:
                                      company!.review.professionalism,
                                  returnExperience:
                                      company!.review.returnExperience,
                                ),

                                const SizedBox(height: 20),

                                RecentReviewsSection(
                                  reviews: reviews.length > 2
                                      ? reviews.sublist(0, 2)
                                      : reviews,
                                  onSeeAll: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewsPage(
                                          title: loc.carNameReviews(
                                            company!.name,
                                          ),
                                          reviews: reviews,
                                          type: RatingSummaryType.car,
                                          isCompanyReview: false,
                                          shopReview: company!.review,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          loc.availableCars,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: Consumer<CarProvider>(
                    builder: (context, carProvider, child) {
                      if (carProvider.loading) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (carProvider.shopCars.isEmpty) {
                        return SliverToBoxAdapter(child: _EmptyCarsCard());
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final car = carProvider.shopCars[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: CarCardVertical(car: car),
                          );
                        }, childCount: carProvider.shopCars.length),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 10,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyCarsCard extends StatelessWidget {
  const _EmptyCarsCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            loc.noCarsAvailable,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.thisRentalCompany,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }
}
