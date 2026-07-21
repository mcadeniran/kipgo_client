import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_booking/shuttle_payment_method.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/booking_completion/shuttle_booking_created_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CompleteBookingScreen extends StatelessWidget {
  const CompleteBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Consumer<ShuttleBookingProvider>(
      builder: (_, provider, _) {
        final draft = provider.draft;
        final payment = draft.payment;

        return Scaffold(
          appBar: AppBarWidget(title: loc.completeBooking),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: SizedBox(
                // height: 56,
                child: FilledButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      provider.canCompleteBooking && !provider.creatingBooking
                      ? () async {
                          final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );

                          final uid = profileProvider.profile!.id;

                          final booking = await provider.completeBooking(
                            userId: uid,
                          );

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShuttleBookingCreatedScreen(
                                  booking: booking,
                                ),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      : null,
                  child: Text(
                    provider.creatingBooking
                        ? loc.submittinBooking
                        : "${loc.completeBooking} (5/5)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                loc.choosePaymentMethod,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                loc.selectHowYoudLike,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              _PriceSummaryCard(
                currency: draft.selectedVehicle?.currency ?? "",
                amount: draft.totalPrice,
              ),

              const SizedBox(height: 24),

              _PaymentMethodCard(
                selected: payment.method == ShuttlePaymentMethod.crypto,
                icon: Icons.currency_bitcoin,
                title: loc.cryptoPayment,
                subtitle: loc.paySecurelyUsingCrypto,
                // badge: "Recommended",
                onTap: () {
                  provider.setPaymentMethod(ShuttlePaymentMethod.crypto);
                },
              ),

              const SizedBox(height: 16),

              _PaymentMethodCard(
                selected: payment.method == ShuttlePaymentMethod.payOnDelivery,
                icon: Icons.airport_shuttle,
                title: loc.payOnPickup,
                subtitle: loc.payYourDriver,
                onTap: () {
                  provider.setPaymentMethod(ShuttlePaymentMethod.payOnDelivery);
                },
              ),

              const SizedBox(height: 28),

              _BookingNoticeCard(),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                    ? AppColors.darkAccent
                    : AppColors.primary.withValues(alpha: .08))
              : (isDark
                    ? AppColors.darkAccent.withValues(alpha: 0.08)
                    : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? (isDark ? AppColors.lightLayer : AppColors.primary)
                : (isDark
                      ? AppColors.border.withValues(alpha: 0.4)
                      : AppColors.border),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(
                      Icons.check_circle,
                      key: ValueKey(1),
                      color: isDark ? AppColors.lightLayer : Colors.green,
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      key: ValueKey(2),
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({required this.currency, required this.amount});

  final String currency;
  final double amount;

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(loc.total, style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 10),

          Text(
            formatCurrency(
              amount: amount,
              currencyCode: currency,
              context: context,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingNoticeCard extends StatelessWidget {
  const _BookingNoticeCard();

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.lightLayer : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user,
            color: isDark ? AppColors.primary : Colors.blue,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              loc.yourBookingWillBeCreated,
              style: TextStyle(
                color: isDark ? AppColors.primary : Colors.blue.shade900,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
