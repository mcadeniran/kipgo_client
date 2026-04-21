import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "SUV", "Sedan", "Luxury"];
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: .08),
                      Colors.white.withValues(alpha: .02),
                    ]
                  : [
                      Colors.white.withValues(alpha: .6),
                      Colors.white.withValues(alpha: .3),
                    ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withValues(alpha: .2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Filter by Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: categories.map((category) {
                  final isSelected = category == selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.white.withValues(alpha: .3),
                    backgroundColor: Colors.white.withValues(alpha: .1),
                    // labelStyle: const TextStyle(color: Colors.white),
                    onSelected: (_) => onApply(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
