import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_date_formatter.dart';

class BookingDateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const BookingDateChip({
    super.key,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(BookingDateFormatter.format(context, date)),
          Text(
            DateFormat(
              "EEE, d MMM",
              Localizations.localeOf(context).languageCode,
            ).format(date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onSelected: (_) => onTap(),
    );
  }
}
