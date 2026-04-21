import 'package:flutter/material.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';

class FeaturedRentalCompaniesSection extends StatelessWidget {
  const FeaturedRentalCompaniesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<RentalShopProvider>(
      builder: (context, rs, _) {
        return rs.loading
            ? Center(child: CircularProgressIndicator.adaptive())
            : rs.featuredShops.isEmpty
            ? SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.featuredRentalCompanies,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: rs.featuredShops.length,
                      itemBuilder: (context, index) {
                        final company = rs.featuredShops[index];

                        return Container(
                          width: rs.featuredShops.length == 1
                              ? MediaQuery.of(context).size.width - 24
                              : MediaQuery.of(context).size.width * 0.7,
                          margin: rs.featuredShops.length == 1
                              ? EdgeInsets.zero
                              : EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: isDark ? AppColors.darkAccent : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RentalCompanyDetailPage(company: company),
                              ),
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
                                        child: FadeInImage.assetNetwork(
                                          fadeInCurve: Curves.easeIn,
                                          fadeInDuration: Duration(seconds: 2),
                                          fit: BoxFit.cover,
                                          placeholder:
                                              "assets/images/image_spinner.gif",
                                          image: company.logo,
                                          imageErrorBuilder: (c, e, s) =>
                                              Image.asset(
                                                "assets/images/placeholder.jpeg",
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  company.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                "${company.rating} (${company.totalRatings})",
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
                                  company.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    AppLocalizations.of(context)!.browseCars,
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
      },
    );
  }
}
