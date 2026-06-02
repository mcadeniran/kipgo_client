import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/rental/bookings/widgets/booking_details_page.dart';
import 'package:provider/provider.dart';

class TimelineItem extends StatelessWidget {
  final String title;
  final DateTime? date;
  final BookingStepStatus status;
  final IconData icon;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.icon,
    required this.isLast,
  });

  Color getColor() {
    switch (status) {
      case BookingStepStatus.completed:
        return Colors.green;
      case BookingStepStatus.current:
        return Colors.blue;
      case BookingStepStatus.rejected:
        return Colors.red;
      case BookingStepStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT (ICON + LINE)
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: status == BookingStepStatus.current
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: Colors.grey.shade300),
          ],
        ),

        const SizedBox(width: 12),

        // RIGHT (TEXT)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null
                    ? DateFormat('dd MMM yyyy • HH:mm', '$locale').format(date!)
                    : AppLocalizations.of(context)!.pending,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
