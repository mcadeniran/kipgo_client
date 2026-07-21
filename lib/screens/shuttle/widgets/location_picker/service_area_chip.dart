import 'package:flutter/material.dart';

class ServiceAreaChip extends StatelessWidget {
  final String? serviceArea;
  final bool loading;

  const ServiceAreaChip({
    super.key,
    required this.serviceArea,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox.shrink();
    }

    if (serviceArea == null || serviceArea!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),

          const SizedBox(width: 8),

          Text(
            serviceArea!,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
