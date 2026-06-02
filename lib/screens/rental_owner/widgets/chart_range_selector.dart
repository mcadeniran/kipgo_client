import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ChartRangeSelector extends StatelessWidget {
  final int selectedDays;
  final Function(int) onChanged;

  const ChartRangeSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        _button(context, loc.daysD(7), 7),
        const SizedBox(width: 8),
        _button(context, loc.daysD(30), 30),
      ],
    );
  }

  Widget _button(BuildContext context, String label, int days) {
    final isActive = selectedDays == days;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: () => onChanged(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : isDark
                ? Colors.white54
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
