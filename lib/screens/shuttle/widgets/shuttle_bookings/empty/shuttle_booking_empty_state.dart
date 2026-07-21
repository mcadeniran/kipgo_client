import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleBookingEmptyState extends StatelessWidget {
  final String title;

  final String subtitle;

  final IconData? icon;

  final VoidCallback? onPressed;

  final String? buttonText;

  final String? iconify;

  const ShuttleBookingEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.onPressed,
    this.buttonText,
    this.iconify,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: .08),
              child: icon != null
                  ? Icon(
                      icon,
                      size: 42,
                      color: isDark ? AppColors.lightLayer : AppColors.primary,
                    )
                  : Iconify(
                      iconify!,
                      size: 52,
                      color: isDark ? AppColors.lightLayer : AppColors.primary,
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),

            if (buttonText != null) ...[
              const SizedBox(height: 28),

              FilledButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
