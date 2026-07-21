import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingTripSelector extends StatelessWidget {
  final bool roundTrip;

  final ValueChanged<bool> onChanged;

  const BookingTripSelector({
    super.key,
    required this.roundTrip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _TripButton(
            title: "One Way",
            selected: !roundTrip,
            onTap: () => onChanged(false),
          ),

          _TripButton(
            title: "Round Trip",
            selected: roundTrip,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TripButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TripButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
