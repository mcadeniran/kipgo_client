import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingGroupCounter extends StatelessWidget {
  final int passengers;

  final VoidCallback increment;

  final VoidCallback decrement;

  const BookingGroupCounter({
    super.key,
    required this.passengers,
    required this.increment,
    required this.decrement,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      // height: 75,
      padding: EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.passengers,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                // const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: decrement,
                      icon: const Icon(Icons.remove),
                    ),
                    Center(
                      child: Text(
                        "$passengers",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),

                    IconButton(
                      onPressed: increment,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
