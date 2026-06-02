import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/screens/rental_owner/rental_booking_details/widgets/booking_action_helper.dart';
import 'package:kipgo/utils/colors.dart';

import '../rental_booking_details_page.dart';

class BookingActionsWidget extends StatelessWidget {
  final BookingModel booking;
  final bool isProcessing;
  final Function(BookingAction action) onAction;

  const BookingActionsWidget({
    super.key,
    required this.booking,
    required this.isProcessing,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final actions = BookingActionHelper.getActions(booking);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (actions.length == 2) {
      return IntrinsicHeight(
        child: Row(
          children: [
            // Left Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildButton(context, actions[0]),
              ),
            ),

            //  Vertical Divider
            const VerticalDivider(
              color: AppColors.border,
              thickness: 1,
              width: 1,
              indent: 4,
              endIndent: 4,
            ),

            // Right Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _buildButton(context, actions[1]),
              ),
            ),
          ],
        ),
      );
    }

    if (actions.length == 1) {
      return _buildButton(context, actions[0]);
    }

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildButton(context, action),
        );
      }).toList(),
    );
  }

  Widget _buildButton(BuildContext context, BookingAction action) {
    final config = _actionConfig(context, action);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(config.icon),
        label: isProcessing
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(config.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: config.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isProcessing ? null : () => onAction(action),
      ),
    );
  }

  _ActionConfig _actionConfig(BuildContext context, BookingAction action) {
    final loc = AppLocalizations.of(context)!;

    switch (action) {
      case BookingAction.approve:
        return _ActionConfig(
          label: loc.approveBooking,
          icon: Icons.check_circle,
          color: Colors.green,
        );

      case BookingAction.reject:
        return _ActionConfig(
          label: loc.rejectBooking,
          icon: Icons.cancel,
          color: Colors.red,
        );

      case BookingAction.start:
        return _ActionConfig(
          label: loc.startBooking,
          icon: Icons.play_arrow,
          color: AppColors.primary,
        );

      case BookingAction.complete:
        return _ActionConfig(
          label: loc.completeBooking,
          icon: Icons.flag,
          color: Colors.indigo,
        );
    }
  }
}

class _ActionConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _ActionConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
