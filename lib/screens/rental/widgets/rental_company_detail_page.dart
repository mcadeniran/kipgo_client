import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental/widgets/car_card_vertical.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}

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

    return Scaffold(
      body: (isLoading || company == null)
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                /// 🔥 Banner AppBar
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  collapsedHeight: 60,
                  iconTheme: IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      company!.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    expandedTitleScale: 1,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image.network(company!.bannerUrl, fit: BoxFit.cover),
                        isValidImageUrl(company?.bannerUrl)
                            ? FadeInImage.assetNetwork(
                                fadeInCurve: Curves.easeIn,
                                fadeInDuration: Duration(seconds: 2),
                                fit: BoxFit.cover,
                                placeholder: "assets/images/image_spinner.gif",
                                image: company!.bannerUrl,
                                imageErrorBuilder: (c, e, s) => Image.asset(
                                  "assets/images/placeholder.jpeg",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                "assets/images/placeholder.jpeg",
                                fit: BoxFit.cover,
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: .6),
                                Colors.transparent,
                              ],
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkAccent : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .08),
                                blurRadius: 20,
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
                                    clipBehavior: Clip.hardEdge,
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: .1),
                                      child: isValidImageUrl(company?.logo)
                                          ? FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeIn,
                                              fadeInDuration: Duration(
                                                seconds: 2,
                                              ),
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  "assets/images/image_spinner.gif",
                                              image: company!.logo,
                                              imageErrorBuilder: (c, e, s) =>
                                                  Image.asset(
                                                    "assets/images/placeholder.jpeg",
                                                    fit: BoxFit.cover,
                                                  ),
                                            )
                                          : Image.asset(
                                              "assets/images/avatar.png",
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "${company!.rating} (${company!.totalRatings} reviews)",
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.push_pin_outlined,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color!
                                                  .withValues(alpha: 0.65),
                                              size: 16,
                                              // color: Colors.red,
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                "${company!.address}, ${company!.district}, ${company!.city}",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "About Company",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                company!.description,
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _makePhoneCall(context, company!.phone),
                                    child: Row(
                                      children: [
                                        Icon(Icons.phone, size: 14),
                                        SizedBox(width: 2),
                                        Text(company!.phone),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Cars Title
                        Text(
                          "Available Cars",
                          style: Theme.of(context).textTheme.titleMedium,
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
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (carProvider.shopCars.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Text("No cars available")),
                        );
                      }

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final car = carProvider.shopCars[index];
                          return CarCardVertical(car: car);
                        }, childCount: carProvider.shopCars.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
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
