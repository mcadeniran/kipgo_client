import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/car_booking/car_booking_page.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingPaymentStep extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  final double rentalPrice;
  final double deliveryPrice;
  final double deposit;
  final double tax;
  final String currency;
  final DeliveryType deliveryType;

  const BookingPaymentStep({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    required this.rentalPrice,
    required this.deliveryPrice,
    required this.deposit,
    required this.tax,
    required this.currency,
    required this.deliveryType,
  });

  @override
  Widget build(BuildContext context) {
    final total = rentalPrice + deliveryPrice + deposit + tax;
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    // Calculate payments here

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.paymentMethod, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.only(top: 16, bottom: 8, right: 8, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          child: Column(
            children: [
              // _PaymentTile(
              //   title: "Credit / Debit Card",
              //   subtitle: "Visa, Mastercard, Verve",
              //   icon: Icons.credit_card,
              //   selected: selectedMethod == PaymentMethod.card,
              //   onTap: () => onChanged(PaymentMethod.card),
              //   isDark: isDark,
              // ),

              // _PaymentTile(
              //   title: "Bank Transfer",
              //   subtitle: "Transfer directly to shop account",
              //   icon: Icons.account_balance,
              //   selected: selectedMethod == PaymentMethod.bankTransfer,
              //   onTap: () => onChanged(PaymentMethod.bankTransfer),
              //   isDark: isDark,
              // ),
              _PaymentTile(
                title: loc.crypto,
                subtitle: loc.payUsingCrypto,
                icon: Icons.account_balance_wallet,
                selected: selectedMethod == PaymentMethod.crypto,
                onTap: () => onChanged(PaymentMethod.crypto),
                isDark: isDark,
              ),
              _PaymentTile(
                title: loc.payOnPickup,
                subtitle: loc.payPhysically,
                icon: Icons.payments_outlined,
                selected: selectedMethod == PaymentMethod.payOnPickup,
                onTap: () => onChanged(PaymentMethod.payOnPickup),
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          loc.paymentSummary,
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 12),

        Container(
          padding: EdgeInsets.only(top: 16, bottom: 8, right: 8, left: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          child: Column(
            children: [
              _AmountRow(
                title: loc.rental,
                amount: rentalPrice,
                currency: currency,
              ),

              _AmountRow(
                title: loc.delivery,
                amount: deliveryPrice,
                currency: currency,
              ),

              _AmountRow(
                title: loc.securityDeposit,
                amount: deposit,
                currency: currency,
              ),

              _AmountRow(title: loc.tax, amount: tax, currency: currency),

              const Divider(height: 32),

              _AmountRow(
                title: loc.total,
                amount: total,
                currency: currency,
                isTotal: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Container(
        //   padding: const EdgeInsets.all(14),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(12),
        //     color: Colors.green.withValues(alpha: 0.2),
        //   ),
        //   child: Row(
        //     children: [
        //       const Icon(
        //         Icons.lock_outline,
        //         color: Color.fromARGB(255, 16, 223, 23),
        //       ),

        //       const SizedBox(width: 12),

        //       Expanded(
        //         child: Text(
        //           "Your payment is encrypted and secure.",
        //           style: TextStyle(color: Color.fromARGB(255, 16, 223, 23)),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _PaymentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? isDark
                      ? AppColors.lightAccent
                      : AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            Radio<bool>(
              activeColor: isDark ? AppColors.lightAccent : AppColors.primary,
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final bool isTotal;

  const _AmountRow({
    required this.title,
    required this.amount,
    required this.currency,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),

          Text(
            formatCurrency(
              amount: amount,
              currencyCode: currency,
              context: context,
            ),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
