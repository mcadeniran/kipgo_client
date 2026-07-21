import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/app_module_card.dart';
import 'package:kipgo/screens/rental/rental_bottom_navigation.dart';
import 'package:kipgo/screens/shuttle/shuttle_bottom_navigation.dart';
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
// import 'package:kipgo/services/role_based_auth_gate.dart';
import 'package:kipgo/utils/colors.dart';

class AppSelection extends StatelessWidget {
  const AppSelection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.kipgoApps,
        showLanguage: true,
      ),
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.howWouldYouLikeToTravel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loc.chooseAService,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 28),

              AppModuleCard(
                title: loc.shuttle,
                subtitle: loc.airportTransfersHotels,
                badge: loc.popular,
                image: "assets/images/bus.png",
                gradient: const [Color(0xff3563E9), Color(0xff1F4BD8)],
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShuttleBottomNavigation(),
                    ),
                    (_) => false,
                  );
                },
              ),

              const SizedBox(height: 22),

              AppModuleCard(
                title: loc.carRental,
                subtitle: loc.economySuLuxury,
                badge: loc.flexible,
                image: "assets/images/merc.webp",
                gradient: const [Color(0xffFF8A00), Color(0xffFF5E3A)],
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RentalBottomNavigation(),
                    ),
                    (_) => false,
                  );
                },
              ),

              const SizedBox(height: 32),

              AdsCarouselWidget(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
