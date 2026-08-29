import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SearchBar(
      controller: widget.controller,
      onChanged: widget.onChanged,

      hintText: AppLocalizations.of(context)!.searchBrandOrModel,

      elevation: WidgetStateProperty.all<double>(0),

      onTap: widget.onTap,

      backgroundColor: WidgetStateProperty.all<Color>(
        isDark ? AppColors.darkAccent.withValues(alpha: 0.8) : theme.cardColor,
      ),

      // overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all<Color>(Colors.transparent),

      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 6),
      ),

      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),

      hintStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark
              ? Colors.white.withValues(alpha: .48)
              : Colors.grey.shade500,
        ),
      ),

      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.lightLayer.withValues(alpha: 0.45)
              : AppColors.primary.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          Icons.search_rounded,
          size: 21,
          color: isDark ? AppColors.lightLayer : AppColors.primary,
        ),
      ),

      trailing: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: widget.controller.text.isNotEmpty
              ? IconButton(
                  key: const ValueKey('clear'),
                  tooltip: 'Clear',
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: isDark
                        ? Colors.white.withValues(alpha: .55)
                        : Colors.grey.shade500,
                  ),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
      ],

      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(
            color: AppColors.primary.withValues(alpha: .35),
            width: 1.2,
          );
        }

        return BorderSide(
          color: isDark
              ? AppColors.border.withValues(alpha: .07)
              : AppColors.border.withValues(alpha: .75),
          width: 1,
        );
      }),

      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
