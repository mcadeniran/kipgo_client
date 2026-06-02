import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/rental_owner/widgets/revenue_chart_sector.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/screens/widgets/notification_icon_button.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalOwnerHome extends StatefulWidget {
  const RentalOwnerHome({super.key});

  @override
  State<RentalOwnerHome> createState() => _RentalOwnerHomeState();
}

class _RentalOwnerHomeState extends State<RentalOwnerHome> {
  late bool isDark;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializePushNotifications();
    });
  }

  Future<void> _initializePushNotifications() async {
    await PushNotificationSystem().generateAndGetToken(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = Provider.of<ThemeProvider>(context).isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = context.watch<CarProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final shopProvider = context.watch<AuthProvider>();

    AppLocalizations loc = AppLocalizations.of(context)!;

    final isActive = shopProvider.rentalShop?.isActive ?? false;

    return Scaffold(
      appBar: AppBarWidget(
        title: loc.home,
        showLanguage: false,
        actions: [NotificationIconButton()],
      ),
      backgroundColor: AppColors.primary,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${AppLocalizations.of(context)!.hi} ${shopProvider.rentalShop!.name}",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive ? Colors.green : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isActive
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      shopProvider.rentalShop!.isActive
                          ? loc.active
                          : loc.hidden,
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),
              const SizedBox(height: 12),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 140,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                children: [
                  statsCard(
                    title: loc.monthlyRevenue,
                    value: formatCurrency(
                      amount: bookingProvider.monthlyRevenue,
                      currencyCode: shopProvider.rentalShop!.currency,
                      context: context,
                    ),
                    subtitle: loc.thisMonth,
                  ),
                  statsCard(
                    title: loc.offlineRevenue,
                    value: formatCurrency(
                      amount: bookingProvider.offlineRevenue,
                      currencyCode: shopProvider.rentalShop!.currency,
                      context: context,
                    ),
                    subtitle: loc.bookedInShop,
                  ),
                  statsCard(
                    title: loc.onlineRevenue,
                    value: formatCurrency(
                      amount: bookingProvider.onlineRevenue,
                      currencyCode: shopProvider.rentalShop!.currency,
                      context: context,
                    ),
                    subtitle: loc.bookedInApp,
                  ),
                  statsCard(
                    title: loc.commission,
                    value: formatCurrency(
                      amount:
                          (bookingProvider.onlineRevenue *
                              shopProvider.rentalShop!.commissionPercentage) /
                          100,
                      currencyCode: shopProvider.rentalShop!.currency,
                      context: context,
                    ),
                    subtitle: loc.ongoingMonth,
                  ),
                  statsCard(
                    title: loc.activeBookings,
                    value: "${bookingProvider.activeBookings}",
                    subtitle: loc.currentlyOngoing,
                  ),
                  statsCard(
                    title: loc.pendingBookings,
                    value: "${bookingProvider.pending.length}",
                    subtitle: loc.waitingApproval,
                  ),
                  statsCard(
                    title: loc.totalCars,
                    value: "${carProvider.totalCars}",
                    subtitle: loc.carsInFleet,
                  ),
                  statsCard(
                    title: loc.unitsAvailable,
                    value: "${carProvider.availableUnits}",
                    subtitle: loc.readyToRent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
                child: const RevenueChartSection(),
              ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const TestScreen()),
              //     );
              //   },
              //   child: Text('TEST TOASTS'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Container statsCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
