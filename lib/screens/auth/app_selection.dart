import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_cars.dart';
import 'package:kipgo/screens/rental/home/widgets/featured_rental_companies_section.dart';
import 'package:kipgo/screens/rental/home/widgets/popular_cars.dart';
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/airport_transfer_card.dart';
import 'package:kipgo/screens/widgets/app_selection_card.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/screens/widgets/notification_icon_button.dart';
import 'package:kipgo/screens/widgets/why_us.dart';
import 'package:kipgo/services/app_services.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AppSelection extends StatelessWidget {
  const AppSelection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final services = AppServices.getServices(context: context, loc: loc);

    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Kipgo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primary,
            fontSize: 28,
          ),
        ),
        leading: LanguageWidget(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NotificationIconButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              loc.hello,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              loc.whereToNext,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            AirportTransferCard(),

            SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final service = services[index];

                return AppSelectionCard(
                  title: service.title,
                  icon: service.icon,
                  onTap: service.onTap,
                );
              },
            ),

            const SizedBox(height: 20),

            FeaturedCars(),

            const SizedBox(height: 22),

            FeaturedRentalCompaniesSection(),

            PopularCars(),

            const SizedBox(height: 22),

            WhyUs(),

            const SizedBox(height: 40),

            AdsCarouselWidget(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
