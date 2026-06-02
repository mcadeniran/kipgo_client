import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';

class RejectBookingSheet {
  static Future<String?> show(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.rejectBooking),

              const SizedBox(height: 12),

              TextField(
                controller: controller,

                maxLines: 3,
                decoration: inputDecoration(
                  context: context,
                  hint: loc.enterReason,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(context, controller.text.trim());
                  },
                  child: Text(loc.reject),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
