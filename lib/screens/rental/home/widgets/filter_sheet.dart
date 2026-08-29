import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class FilterSheet extends StatefulWidget {
  final String category;

  const FilterSheet({super.key, required this.category});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? seats;
  String? fuel;
  String? transmission;

  late AppLocalizations loc;

  final List<int> seatOptions = [2, 4, 5, 6, 7];

  final List<String> fuelOptions = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  final List<String> transmissionOptions = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<CarProvider>(context, listen: false);

    seats = provider.seats;
    fuel = provider.fuel;
    transmission = provider.transmission;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loc = AppLocalizations.of(context)!;
  }

  int get activeFilterCount {
    int count = 0;

    if (seats != null) count++;
    if (fuel != null) count++;
    if (transmission != null) count++;

    return count;
  }

  void _resetFilters() {
    setState(() {
      seats = null;
      fuel = null;
      transmission = null;
    });
  }

  void _applyFilters() {
    final provider = Provider.of<CarProvider>(context, listen: false);

    provider.applyFilters(
      category: widget.category,
      seats: seats,
      fuel: fuel,
      transmission: transmission,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      title: loc.seatsLabel,
                      icon: Icons.people_outline_rounded,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    _buildSeatOptions(isDark),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      title: loc.fuelType,
                      icon: Icons.local_gas_station_outlined,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    _buildFuelOptions(isDark),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      title: loc.transmission,
                      icon: Icons.settings_outlined,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    _buildTransmissionOptions(isDark),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            _buildBottomActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 12),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.lightLayer.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.filters,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      activeFilterCount == 0
                          ? loc.refineYourCarSearch
                          : loc.numActiveFilters(activeFilterCount),
                      // : '$activeFilterCount active '
                      //       'filter${activeFilterCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              if (activeFilterCount > 0)
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: Text(
                    loc.clearAll,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: isDark ? Colors.white70 : AppColors.primary,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildSeatOptions(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: seatOptions.map((value) {
        final bool selected = seats == value;

        return _buildOptionChip(
          label: loc.seats(value),
          selected: selected,
          isDark: isDark,
          onTap: () {
            setState(() {
              seats = selected ? null : value;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFuelOptions(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: fuelOptions.map((value) {
        final bool selected = fuel == value;

        return _buildLargeOption(
          title: carPropertiesTranslations(context, value),
          icon: _fuelIcon(value),
          selected: selected,
          isDark: isDark,
          onTap: () {
            setState(() {
              fuel = selected ? null : value;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTransmissionOptions(bool isDark) {
    return Row(
      children: transmissionOptions.map((value) {
        final bool selected = transmission == value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: value == transmissionOptions.first ? 8 : 0,
            ),
            child: _buildLargeOption(
              title: carPropertiesTranslations(context, value),
              icon: value == 'Automatic'
                  ? Icons.auto_mode_rounded
                  : Icons.settings_rounded,
              selected: selected,
              isDark: isDark,
              onTap: () {
                setState(() {
                  transmission = selected ? null : value;
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : isDark
            ? AppColors.darkAccent
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 17,
                color: selected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : AppColors.primary,
              ),

              const SizedBox(width: 7),

              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),

              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeOption({
    required String title,
    required IconData icon,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: isDark ? .22 : .08)
            : isDark
            ? AppColors.darkAccent
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .08),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? Colors.white
                        : isDark
                        ? AppColors.lightLayer
                        : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 9),

                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (selected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: isDark ? AppColors.lightLayer : AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _fuelIcon(String value) {
    switch (value) {
      case 'Electric':
        return Icons.bolt_rounded;

      case 'Hybrid':
        return Icons.eco_rounded;

      case 'Diesel':
        return Icons.local_gas_station_rounded;

      case 'Petrol':
      default:
        return Icons.local_gas_station_outlined;
    }
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: .06),
          ),
        ),
      ),
      child: Row(
        children: [
          if (activeFilterCount > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: AppColors.border),
                ),
                child: const Icon(Icons.refresh_rounded),
              ),
            ),

          if (activeFilterCount > 0) const SizedBox(width: 10),

          Expanded(
            flex: activeFilterCount > 0 ? 3 : 1,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    loc.applyFilters,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  if (activeFilterCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$activeFilterCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
