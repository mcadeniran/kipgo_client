import 'package:flutter/material.dart';
import 'package:kipgo/models/place_prediction.dart';
import 'package:kipgo/utils/colors.dart';

class PredictionTile extends StatelessWidget {
  final PlacePrediction prediction;
  final VoidCallback onTap;

  const PredictionTile({
    super.key,
    required this.prediction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),

      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withValues(alpha: .08),
        child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
      ),

      title: Text(
        prediction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        prediction.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: const Icon(Icons.chevron_right),

      onTap: onTap,
    );
  }
}
