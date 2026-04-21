import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/driver_profile.dart';

class DriverSelector extends StatelessWidget {
  final List<DriverProfile> drivers;
  final DriverProfile? selected;
  final Function(DriverProfile) onSelect;
  final VoidCallback onAddNew;

  const DriverSelector({
    super.key,
    required this.drivers,
    required this.selected,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...drivers.map((driver) {
          final isSelected = selected?.id == driver.id;

          return GestureDetector(
            onTap: () => onSelect(driver),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Expanded(child: Text(driver.name)),
                  if (isSelected) const Icon(Icons.check_circle),
                ],
              ),
            ),
          );
        }),

        if (drivers.isNotEmpty) ...[
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: onAddNew,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addNewDriver),
          ),
        ],
      ],
    );
  }
}
