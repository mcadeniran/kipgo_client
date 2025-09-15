import 'package:animated_theme_switcher/animated_theme_switcher.dart'
    hide ThemeProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ThemeSwitcher(
      builder: (context) => Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(value, context);
          },
        ),
      ),
    );
  }
}
