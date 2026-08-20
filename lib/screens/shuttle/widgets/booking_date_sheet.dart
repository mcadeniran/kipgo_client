import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_date_formatter.dart';
import 'package:kipgo/utils/colors.dart';

class BookingDateSheet extends StatefulWidget {
  final DateTime? selectedDate;
  final bool allowToday;
  const BookingDateSheet({
    super.key,
    this.selectedDate,
    this.allowToday = false,
  });

  @override
  State<BookingDateSheet> createState() => _BookingDateSheetState();
}

class _BookingDateSheetState extends State<BookingDateSheet> {
  late DateTime selected;
  late TimeOfDay selectedTime;

  List<DateTime> get quickDates {
    final now = DateTime.now();

    final start = widget.allowToday ? 0 : 1;

    return List.generate(7, (index) {
      final date = now.add(Duration(days: start + index));

      return DateTime(date.year, date.month, date.day);
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();

    final tomorrow = DateTime.now().add(const Duration(days: 1));

    selected =
        widget.selectedDate ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    selectedTime = widget.selectedDate != null
        ? TimeOfDay.fromDateTime(widget.selectedDate!)
        : const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(loc.quickSelect, style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 20),

          Wrap(
            spacing: 12,

            runSpacing: 12,

            children: quickDates.map((date) {
              final selectedDate = isSameDay(selected, date);

              return ChoiceChip(
                label: Text(BookingDateFormatter.format(context, date)),

                selected: selectedDate,

                onSelected: (_) {
                  setState(() {
                    selected = date;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          ListTile(
            leading: const Icon(Icons.calendar_month),

            title: Text(loc.chooseAnotherDate),
            subtitle: Text(BookingDateFormatter.format(context, selected)),
            trailing: const Icon(Icons.chevron_right),

            onTap: () async {
              final picked = await showDatePicker(
                context: context,

                initialDate: selected,

                firstDate: widget.allowToday
                    ? DateTime.now()
                    : DateTime.now().add(const Duration(days: 1)),

                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (picked == null) return;

              setState(() {
                selected = picked;
              });
            },
          ),

          const SizedBox(height: 24),

          Text(
            loc.departureTime,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: Text(loc.selectDepartureTime),
            subtitle: Text(selectedTime.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );

              if (picked == null) return;

              setState(() {
                selectedTime = picked;
              });
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final result = DateTime(
                  selected.year,
                  selected.month,
                  selected.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                Navigator.pop(context, result);
              },

              child: Text(loc.continueAction),
            ),
          ),
        ],
      ),
    );
  }
}
