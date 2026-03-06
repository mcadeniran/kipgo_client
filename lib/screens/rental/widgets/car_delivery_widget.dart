import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/rental/widgets/car_booking_page.dart'
    show DeliveryType;
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarDeliveryWidget extends StatelessWidget {
  final DeliveryType deliveryType;
  final ValueChanged<DeliveryType> onChanged;
  final TextEditingController deliveryAddress;
  final double deliveryFee;

  const CarDeliveryWidget({
    super.key,
    required this.deliveryType,
    required this.onChanged,
    required this.deliveryAddress,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeliverySelector(isDark),

        _buildDeliveryAddressField(context),

        const SizedBox(height: 10),

        if (deliveryType == DeliveryType.delivery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivery Fee",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                // "₺${deliveryFee.toStringAsFixed(0)}",
                NumberFormat.currency(
                  locale: 'en',
                  symbol: '₺',
                ).format(deliveryFee),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // color: primary,
                ),
              ),
            ],
          ),

        if (deliveryType == DeliveryType.delivery) SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDeliverySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkLayer.withValues(alpha: 0.15)
            : AppColors.lightLayer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildDeliverySegment(
            title: "Pickup",
            icon: Icons.store_mall_directory_outlined,
            type: DeliveryType.pickup,
            isDark: isDark,
          ),
          _buildDeliverySegment(
            title: "Delivery",
            icon: Icons.local_shipping_outlined,
            type: DeliveryType.delivery,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySegment({
    required String title,
    required IconData icon,
    required DeliveryType type,
    required bool isDark,
  }) {
    final bool isSelected = deliveryType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : !isDark
                    ? Colors.black87
                    : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : !isDark
                      ? Colors.black87
                      : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressField(BuildContext context) {
    if (deliveryType != DeliveryType.delivery) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Delivery Address",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: deliveryAddress,
          decoration: inputDecoration(
            context: context,
            hint: "Enter delivery address",
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
