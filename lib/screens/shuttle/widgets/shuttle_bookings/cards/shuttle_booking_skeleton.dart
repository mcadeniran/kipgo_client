import 'package:flutter/material.dart';
import 'package:kipgo/utils/colors.dart';

class ShuttleBookingSkeleton extends StatelessWidget {
  const ShuttleBookingSkeleton({super.key});

  Widget _box({double? width, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightAccent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(width: 120, height: 18),
              const Spacer(),
              _box(width: 80, height: 28),
            ],
          ),

          const SizedBox(height: 20),

          _box(width: 180),

          const SizedBox(height: 12),

          _box(width: 230),

          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(4, (_) => _box(width: 130, height: 60)),
          ),
        ],
      ),
    );
  }
}
