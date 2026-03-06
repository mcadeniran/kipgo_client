import 'package:flutter/material.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';

class FeaturedRentalCompaniesSection extends StatelessWidget {
  const FeaturedRentalCompaniesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final List<Map<String, dynamic>> companies = [
      {
        "name": "Anadolu Drive",
        "rating": 4.8,
        "reviews": 124,
        "tagline": "Premium şehir içi araçlar",
        "image": "assets/images/anadolu.jpg",
      },
      {
        "name": "Bosphorus Rentals",
        "rating": 4.6,
        "reviews": 98,
        "tagline": "İstanbul’un güvenilir tercihi",
        "image": "assets/images/bosphorus.jpg",
      },
      {
        "name": "Kapadokya Cars",
        "rating": 4.9,
        "reviews": 201,
        "tagline": "Turistik ve lüks araçlar",
        "image": "assets/images/kapadokya.webp",
      },
      {
        "name": "Ege Auto Kiralama",
        "rating": 4.7,
        "reviews": 156,
        "tagline": "Uygun fiyatlı günlük kiralama",
        "image": "assets/images/ege.jpeg",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Featured Rental Companies",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];

              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: isDark ? AppColors.darkAccent : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RentalCompanyDetailPage(
                        companyName: "Anadolu Drive",
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Image.asset(company['image']),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        company["name"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${company["rating"]} (${company["reviews"]})",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        company["tagline"],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "View Cars →",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            // color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
