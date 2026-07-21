import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/models/shuttle_service_item.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleServiceCard extends StatelessWidget {
  final ShuttleServiceItem item;

  const ShuttleServiceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      width: 120,

      margin: const EdgeInsets.only(right: 16),

      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(22),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 28,

              backgroundColor: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: .08),

              child: Icon(
                item.icon,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(item.title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
