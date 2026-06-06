import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class ReusableToast {
  static void success(BuildContext context, String title, String message) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text(title),
      description: Text(message),
      backgroundColor: isDark
          ? const Color(0xFF065F46)
          : const Color(0xFFECFDF5),
      foregroundColor: isDark ? Color(0xFFA7F3D0) : Color(0xFF065F46),
      borderSide: BorderSide(color: Colors.green.shade600),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  static void error(BuildContext context, String title, String message) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text(title),
      description: Text(message),
      backgroundColor: isDark
          ? const Color(0xFF991B1B)
          : const Color(0xFFFEF2F2),
      foregroundColor: isDark ? Color(0xffFCA5A5) : Color(0xFF991B1B),
      borderSide: BorderSide(color: Colors.red.shade700),
    );
  }

  static void warning(BuildContext context, String title, String message) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    toastification.show(
      context: context,
      type: ToastificationType.warning,
      title: Text(title),
      description: Text(message),
      backgroundColor: isDark
          ? const Color(0xFF92400E)
          : const Color(0xFFFFFBEB),
      foregroundColor: isDark
          ? const Color(0xFFFDE68A)
          : const Color(0xFF92400E),
      borderSide: BorderSide(color: Colors.orange),
    );
  }

  static void info(
    BuildContext context,
    String title,
    String message,
    VoidCallback? onTap,
  ) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    toastification.show(
      context: context,
      type: ToastificationType.info,
      alignment: Alignment.topCenter,
      title: Text(title),
      description: Text(message),
      backgroundColor: isDark
          ? AppColors.lightLayer.withValues(alpha: 0.98)
          : AppColors.darkLayer.withValues(alpha: 0.98),
      foregroundColor: isDark ? AppColors.primary : AppColors.lightAccent,
      borderSide: BorderSide(color: AppColors.primary),
      callbacks: ToastificationCallbacks(
        onTap: (_) {
          onTap?.call();
        },
      ),
    );
  }
}
