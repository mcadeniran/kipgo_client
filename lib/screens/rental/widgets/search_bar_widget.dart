import 'package:flutter/material.dart';
import 'package:kipgo/utils/colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search cars, brands...',
      controller: controller,
      onChanged: onChanged,
      elevation: WidgetStateProperty.all<double?>(0.0),
      leading: const Icon(Icons.search),
      side: WidgetStateProperty.all<BorderSide>(
        BorderSide(color: AppColors.border),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
