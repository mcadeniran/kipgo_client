import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/app_service_model.dart';
import 'package:kipgo/screens/admin/admin_bottom_navigation.dart';
import 'package:kipgo/screens/homes/customer_taxi_bottom_navigation.dart';
import 'package:kipgo/screens/homes/driver_taxi_bottom_navigation.dart';
import 'package:kipgo/screens/rental/rental_bottom_navigation.dart';
import 'package:kipgo/screens/shuttle/shuttle_bottom_navigation.dart';
import 'package:kipgo/screens/widgets/coming_soon_page.dart';
import 'package:provider/provider.dart';

class AppServices {
  static List<AppServiceModel> getServices({
    required BuildContext context,
    required AppLocalizations loc,
  }) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final services = <AppServiceModel>[
      AppServiceModel(
        title: loc.carRental,
        icon: Carbon.car_front,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RentalBottomNavigation()),
          );
        },
      ),

      AppServiceModel(
        title: loc.shuttleService,
        icon: Carbon.bus,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShuttleBottomNavigation()),
          );
        },
      ),

      AppServiceModel(
        title: loc.taxi,
        icon: Carbon.taxi,
        onTap: () {
          if (auth.role == 'driver') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DriverTaxiBottomNavigation(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerTaxiBottomNavigation(),
              ),
            );
          }
        },
      ),

      AppServiceModel(
        title: loc.hotels,
        icon: Carbon.hotel,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComingSoonPage(
                title: loc.hotels,
                subtitle: loc.staySomewhereExtra,
                description: loc.weArePreparingHotels,
                icon: Carbon.hotel,
              ),
            ),
          );
        },
      ),

      AppServiceModel(
        title: loc.toursAndActivities,
        icon: Carbon.camera_action,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComingSoonPage(
                title: loc.toursAndActivities,
                subtitle: loc.discoverMore,
                description: loc.fromUnforgettableAdventures,
                icon: Carbon.camera_action,
              ),
            ),
          );
        },
      ),
    ];

    // Admin-only application
    if (auth.profile?.isAdmin == true) {
      services.add(
        AppServiceModel(
          title: loc.admin,
          icon: MaterialSymbols.admin_panel_settings_outline_rounded,
          isAdmin: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminBottomNavigation()),
            );
          },
        ),
      );
    }

    return services;
  }
}
