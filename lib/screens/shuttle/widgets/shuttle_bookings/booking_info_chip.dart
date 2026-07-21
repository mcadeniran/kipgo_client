import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BookingInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkLayer.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightAccent : AppColors.darkAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
