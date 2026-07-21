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
  AppLocalizations loc = AppLocalizations.of(context)!;
  List<Widget> chips = [];

  if (provider.selectedCategory != null && provider.selectedCategory != "All") {
    chips.add(
      _chip(provider.selectedCategory!, () {
        provider.selectedCategory = null;
        provider.applyFilters();
      }, isDark),
    );
  }

  // if (provider.minPrice != null || provider.maxPrice != null) {
  //   chips.add(
  //     _chip("${provider.minPrice ?? 0} - ${provider.maxPrice ?? 0}", () {
  //       provider.minPrice = null;
  //       provider.maxPrice = null;
  //       provider.applyFilters();
  //     }, isDark),
  //   );
  // }

  if (provider.radiusKm != null) {
    chips.add(
      _chip(loc.distanceKM(provider.radiusKm!.round().toString()), () {
        provider.radiusKm = null;
        provider.applyFilters();
      }, isDark),
    );
  }

  if (provider.seats != null) {
    chips.add(
      _chip(loc.seats(provider.seats!), () {
        provider.seats = null;
        provider.applyFilters();
      }, isDark),
    );
  }

  if (provider.fuel != null) {
    chips.add(
      _chip(carPropertiesTranslations(context, provider.fuel!), () {
        provider.fuel = null;
        provider.applyFilters();
      }, isDark),
    );
  }

  if (provider.transmission != null) {
    chips.add(
      _chip(carPropertiesTranslations(context, provider.transmission!), () {
        provider.transmission = null;
        provider.applyFilters();
      }, isDark),
    );
  }

  if (chips.isEmpty) return const SizedBox();

  return Column(
    children: [
      Wrap(
        spacing: 8,
        children: [
          ...chips,
          TextButton(
            onPressed: () {
              provider.clearFilters();
            },

            child: Text(loc.clearAll),
          ),
        ],
      ),
      SizedBox(height: 12),
    ],
  );
}

Widget _chip(String label, VoidCallback onRemove, bool isDark) {
  return Chip(
    label: Text(label),
    backgroundColor: isDark ? AppColors.darkLayer : AppColors.lightAccent,
    deleteIcon: const Icon(Icons.close, size: 18),
    deleteIconColor: AppColors.tertiary,
    onDeleted: onRemove,
    elevation: 0,
    side: BorderSide(color: AppColors.border, width: 1),
  );
}
