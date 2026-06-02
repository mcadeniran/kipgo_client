import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityCalendar extends StatefulWidget {
  final List<CarUnit> units;
  final List<BookingModel> bookings;

  final DateTime? initialPickup;
  final DateTime? initialDropoff;

  final int minimumRentalDays;

  final Function(DateTime pickup, DateTime dropoff, int chargeableDays)
  onRangeSelected;

  const AvailabilityCalendar({
    super.key,
    required this.units,
    required this.bookings,
    required this.onRangeSelected,
    this.initialPickup,
    this.initialDropoff,
    this.minimumRentalDays = 3,
  });

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  late AppLocalizations loc;
  DateTime? _pickupDate;
  DateTime? _dropoffDate;

  String? scheduleError;

  late final Set<DateTime> fullyBookedDates;

  late final DateTime _today;

  @override
  void initState() {
    super.initState();

    _today = normalizeDate(DateTime.now());

    _pickupDate = widget.initialPickup;
    _dropoffDate = widget.initialDropoff;

    fullyBookedDates = getFullyBookedDates(
      units: widget.units,
      bookings: widget.bookings,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  void didUpdateWidget(covariant AvailabilityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialPickup != widget.initialPickup ||
        oldWidget.initialDropoff != widget.initialDropoff) {
      setState(() {
        _pickupDate = widget.initialPickup;
        _dropoffDate = widget.initialDropoff;
      });
    }
  }

  /// --------------------------------------------------------
  /// FULLY BOOKED DATES
  /// --------------------------------------------------------

  Set<DateTime> getFullyBookedDates({
    required List<CarUnit> units,
    required List<BookingModel> bookings,
  }) {
    final Map<DateTime, int> bookingCountPerDay = {};

    for (final booking in bookings) {
      /// Ignore cancelled/rejected bookings
      if (booking.status == "rejected") continue;

      DateTime current = normalizeDate(booking.pickupDate);

      final dropoff = normalizeDate(booking.dropoffDate);

      while (!current.isAfter(dropoff)) {
        bookingCountPerDay[current] = (bookingCountPerDay[current] ?? 0) + 1;

        current = current.add(const Duration(days: 1));
      }
    }

    final totalAvailableUnits = units
        .where((e) => e.status == "available")
        .length;

    return bookingCountPerDay.entries
        .where((entry) => entry.value >= totalAvailableUnits)
        .map((entry) => normalizeDate(entry.key))
        .toSet();
  }

  /// --------------------------------------------------------
  /// HELPERS
  /// --------------------------------------------------------

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isDayBlocked(DateTime day) {
    return fullyBookedDates.contains(normalizeDate(day));
  }

  bool rangeContainsBlockedDate(DateTime start, DateTime end) {
    DateTime current = normalizeDate(start);

    while (!current.isAfter(end)) {
      if (isDayBlocked(current)) {
        return true;
      }

      current = current.add(const Duration(days: 1));
    }

    return false;
  }

  Future<void> _selectPickupTime() async {
    setState(() {
      scheduleError = null;
    });
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    final time = picked ?? const TimeOfDay(hour: 9, minute: 0);

    if (_pickupDate == null) return;

    setState(() {
      _pickupDate = DateTime(
        _pickupDate!.year,
        _pickupDate!.month,
        _pickupDate!.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectDropoffTime() async {
    setState(() {
      scheduleError = null;
    });
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    final time = picked ?? const TimeOfDay(hour: 9, minute: 0);

    if (_dropoffDate == null) return;

    setState(() {
      _dropoffDate = DateTime(
        _dropoffDate!.year,
        _dropoffDate!.month,
        _dropoffDate!.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _completeSelection() {
    if (_pickupDate == null || _dropoffDate == null) return;

    final duration = _dropoffDate!.difference(_pickupDate!);

    final totalDays = duration.inHours / 24;

    final chargeableDays = totalDays.ceil();

    if (chargeableDays < widget.minimumRentalDays) {
      setState(() {
        scheduleError = loc.minimumRentalDuration(widget.minimumRentalDays);
      });

      return;
    }

    widget.onRangeSelected(_pickupDate!, _dropoffDate!, chargeableDays);
  }

  /// --------------------------------------------------------
  /// DATE SELECTION
  /// --------------------------------------------------------

  Future<void> onDayTapped(DateTime selectedDay) async {
    setState(() {
      scheduleError = null;
    });
    final normalized = normalizeDate(selectedDay);

    if (isSameDay(normalized, _today)) {
      return; // or show error if you want
    }

    if (isDayBlocked(normalized)) return;

    /// START NEW SELECTION
    if (_pickupDate != null && _dropoffDate != null) {
      setState(() {
        _pickupDate = normalized;
        _dropoffDate = null;
        scheduleError = null;
      });

      return;
    }

    // /// FIRST PICKUP
    // if (_pickupDate == null || _dropoffDate != null) {
    //   setState(() {
    //     _pickupDate = normalized;
    //     _dropoffDate = null;
    //   });

    //   return;
    // }

    /// FIRST PICKUP
    if (_pickupDate == null) {
      setState(() {
        _pickupDate = normalized;
        scheduleError = null;
      });

      return;
    }

    /// INVALID RANGE
    if (normalized.isBefore(_pickupDate!)) {
      setState(() {
        _pickupDate = normalized;
      });

      return;
    }

    /// CHECK RANGE FOR BLOCKED DAYS
    final hasBlocked = rangeContainsBlockedDate(_pickupDate!, normalized);

    if (hasBlocked) {
      setState(() {
        scheduleError = loc.selectedRange;
        _pickupDate = normalized;
        _dropoffDate = null;
      });
      return;
    }

    setState(() {
      _dropoffDate = normalized;
    });

    /// ASK FOR TIMES
    await _selectPickupTime();

    if (!mounted) return;

    await _selectDropoffTime();

    if (!mounted) return;

    _completeSelection();
  }

  /// --------------------------------------------------------
  /// UI
  /// --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      children: [
        TableCalendar(
          firstDay: normalizeDate(DateTime.now().add(const Duration(days: 1))),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,

          selectedDayPredicate: (day) {
            if (_pickupDate == null) return false;

            return isSameDay(day, _pickupDate);
          },

          rangeStartDay: _pickupDate,
          rangeEndDay: _dropoffDate,

          calendarFormat: CalendarFormat.month,

          availableCalendarFormats: const {CalendarFormat.month: 'Month'},

          locale: locale.languageCode,

          enabledDayPredicate: (day) {
            final normalized = normalizeDate(day);

            /// Allow already selected dates to remain clickable
            final isSelectedPickup =
                _pickupDate != null && isSameDay(normalized, _pickupDate);

            final isSelectedDropoff =
                _dropoffDate != null && isSameDay(normalized, _dropoffDate);

            if (isSelectedPickup || isSelectedDropoff) {
              return true;
            }

            if (isSameDay(normalized, _today)) {
              return false;
            }

            return !isDayBlocked(normalized);
          },

          onDaySelected: (selectedDay, focusedDay) async {
            _focusedDay = focusedDay;

            await onDayTapped(selectedDay);
          },

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: isDark ? AppColors.darkLayer : AppColors.lightLayer,
              shape: BoxShape.circle,
            ),

            selectedDecoration: BoxDecoration(
              color: isDark ? AppColors.lightLayer : AppColors.primary,
              shape: BoxShape.circle,
            ),

            rangeStartDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),

            rangeEndDecoration: BoxDecoration(
              color: isDark ? AppColors.lightLayer : AppColors.primary,
              shape: BoxShape.circle,
            ),

            withinRangeDecoration: BoxDecoration(
              // color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              color: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),

            rangeHighlightColor: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.25),

            disabledTextStyle: const TextStyle(
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
            ),
          ),

          calendarBuilders: CalendarBuilders(
            disabledBuilder: (context, day, focusedDay) {
              final normalized = normalizeDate(day);

              final isToday = isSameDay(normalized, _today);

              // return Container(
              //   margin: const EdgeInsets.all(6),
              //   decoration: BoxDecoration(
              //     color: Colors.red.withValues(alpha: 0.15),
              //     shape: BoxShape.circle,
              //   ),
              //   child: Center(
              //     child: Text(
              //       "${day.day}",
              //       style: const TextStyle(
              //         color: Colors.red,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // );

              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      color: isToday ? Colors.orange : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (scheduleError != null) ...[
          const SizedBox(height: 16),
          ErrorMessageWidget(localErrorMessage: scheduleError!),
        ],
        const SizedBox(height: 16),

        if (_pickupDate != null)
          _InfoTile(
            title: AppLocalizations.of(context)!.pickupDate,
            value: DateFormat(
              'dd MMM yyyy • HH:mm',
              '$locale',
            ).format(_pickupDate!),
          ),

        if (_dropoffDate != null)
          _InfoTile(
            title: AppLocalizations.of(context)!.dropoffDate,
            value: DateFormat(
              'dd MMM yyyy • HH:mm',
              '$locale',
            ).format(_dropoffDate!),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
