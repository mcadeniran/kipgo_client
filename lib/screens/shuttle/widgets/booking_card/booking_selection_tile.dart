import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class BookingSelectionTile extends StatelessWidget {
  final String title;
  final String? value;
  final String placeholder;
  final String? subtitle;
  final String? hint;
  final IconData icon;
  final VoidCallback onTap;

  const BookingSelectionTile({
    super.key,
    required this.title,
    this.value,
    this.subtitle,
    required this.icon,
    required this.onTap,
    required this.placeholder,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final display = value ?? placeholder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
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
                  icon,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelMedium),

                    const SizedBox(height: 4),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),

                    if (hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(hint!, style: theme.textTheme.bodySmall),
                      ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
