import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';

class AppBottomSheets {
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    Color confirmColor = AppColors.primary,
  }) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ConfirmationSheet(
            title: title,
            message: message,
            confirmText: confirmText,
            confirmColor: confirmColor,
          ),
        ) ??
        false;
  }
}

class _ConfirmationSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;

  const _ConfirmationSheet({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(loc.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
