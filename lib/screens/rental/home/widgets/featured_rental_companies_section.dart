import 'package:flutter/material.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/screens/rental/widgets/rental_company_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/utils/colors.dart';

class FeaturedRentalCompaniesSection extends StatelessWidget {
  const FeaturedRentalCompaniesSection({super.key});

  bool _isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(url);

    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Consumer<RentalShopProvider>(
      builder: (context, rs, _) {
        if (rs.loading) {
          return const SizedBox(
            height: 190,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (rs.featuredShops.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.featuredRentalCompanies,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loc.trustedPartnersForYourJourney,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: rs.featuredShops.length,
                itemBuilder: (context, index) {
                  final company = rs.featuredShops[index];

                  return _buildCompanyCard(
                    context,
                    company,
                    isDark,
                    rs.featuredShops.length == 1,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    RentalShop company,
    bool isDark,
    bool isSingle,
  ) {
    final width = isSingle
        ? MediaQuery.of(context).size.width - 32
        : MediaQuery.of(context).size.width * .78;

    return Container(
      width: width,
      margin: EdgeInsets.only(right: isSingle ? 0 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? AppColors.darkLayer.withValues(alpha: .58)
            : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : AppColors.primary.withValues(alpha: .05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .12 : .055),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RentalCompanyDetailPage(company: company),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildCompanyLogo(company),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  company.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.blue,
                                size: 17,
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: .10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      company.review.average.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 7),

                              Text(
                                '(${company.review.totalReviews})',
                                style: TextStyle(
                                  fontSize: 10,
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
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? Colors.white.withValues(alpha: .65)
                        : Colors.grey.shade600,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.lightLayer.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.verifiedPartner,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.lightLayer
                                  : AppColors.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.browseCars,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _buildCompanyLogo(dynamic company) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: .07),
        border: Border.all(color: AppColors.primary.withValues(alpha: .08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isValidImageUrl(company.logo)
          ? Image.network(
              company.logo,
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
          : Image.asset('assets/images/placeholder.jpeg', fit: BoxFit.cover),
    );
  }
}
