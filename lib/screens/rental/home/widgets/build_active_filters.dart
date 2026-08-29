import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';

Widget buildActiveFilters(
  BuildContext context,
  CarProvider provider,
  bool isDark,
) {
  final AppLocalizations loc = AppLocalizations.of(context)!;

  final List<Widget> chips = [];

  if (provider.selectedCategory != null && provider.selectedCategory != 'All') {
    chips.add(
      _buildFilterChip(
        context: context,
        label: carPropertiesTranslations(context, provider.selectedCategory!),
        icon: Icons.directions_car_outlined,
        isDark: isDark,
        onRemove: () {
          provider.selectedCategory = null;
          provider.applyFilters();
        },
      ),
    );
  }

  if (provider.seats != null) {
    chips.add(
      _buildFilterChip(
        context: context,
        label: loc.seats(provider.seats!),
        icon: Icons.people_outline_rounded,
        isDark: isDark,
        onRemove: () {
          provider.seats = null;
          provider.applyFilters();
        },
      ),
    );
  }

  if (provider.fuel != null) {
    chips.add(
      _buildFilterChip(
        context: context,
        label: carPropertiesTranslations(context, provider.fuel!),
        icon: Icons.local_gas_station_outlined,
        isDark: isDark,
        onRemove: () {
          provider.fuel = null;
          provider.applyFilters();
        },
      ),
    );
  }

  if (provider.transmission != null) {
    chips.add(
      _buildFilterChip(
        context: context,
        label: carPropertiesTranslations(context, provider.transmission!),
        icon: Icons.settings_outlined,
        isDark: isDark,
        onRemove: () {
          provider.transmission = null;
          provider.applyFilters();
        },
      ),
    );
  }

  if (chips.isEmpty) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ...chips.map(
                  (chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 4),

        TextButton(
          onPressed: () {
            provider.clearFilters();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.tertiary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            loc.clearAll,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFilterChip({
  required BuildContext context,
  required String label,
  required IconData icon,
  required bool isDark,
  required VoidCallback onRemove,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isDark
          ? AppColors.darkLayer.withValues(alpha: .65)
          : AppColors.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onRemove,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),

              const SizedBox(width: 5),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),

              const SizedBox(width: 5),

              Icon(
                Icons.close_rounded,
                size: 15,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
