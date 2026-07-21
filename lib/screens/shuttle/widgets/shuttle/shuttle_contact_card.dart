import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ShuttleContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isDark
                    ? AppColors.lightLayer.withValues(alpha: .08)
                    : AppColors.primary.withValues(alpha: .08),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
