import 'package:flutter/material.dart';

class ShuttleSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const ShuttleSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 4),

                  Text(subtitle!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),

          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text("See all")),
        ],
      ),
    );
  }
}
