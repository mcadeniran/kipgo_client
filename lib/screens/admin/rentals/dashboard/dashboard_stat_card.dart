import 'package:flutter/material.dart';
import 'package:kipgo/utils/colors.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkAccent
            : AppColors.lightAccent,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),

            const Spacer(),
          ],

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Text(title),
        ],
      ),
    );
  }
}
