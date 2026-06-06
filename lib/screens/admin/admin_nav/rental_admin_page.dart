import 'package:flutter/material.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/admin/rentals/admin_crypto_payment_verifications.dart';
import 'package:kipgo/screens/admin/rentals/admin_rental_bookings.dart';
import 'package:kipgo/screens/admin/rentals/admin_rental_dashboard.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalAdminPage extends StatefulWidget {
  const RentalAdminPage({super.key});
  @override
  State<RentalAdminPage> createState() => _RentalAdminPageState();
}

class _RentalAdminPageState extends State<RentalAdminPage> {
  int index = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().listenToAdminBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Container(
        color: AppColors.primary,
        child: Column(
          children: [
            TabBar(
              indicatorColor: isDark ? Colors.white : AppColors.lightLayer,
              dividerColor: index == 1
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              padding: EdgeInsets.all(0),
              onTap: (val) => setState(() {
                index = val;
              }),
              tabs: [
                Tab(text: loc.dashboard),
                Tab(text: loc.bookings),
                Tab(text: loc.payments),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AdminRentalDashboard(),
                  AdminRentalBookings(),
                  AdminCryptoPaymentVerifications(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
