import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

class RentalBookingTimeline extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;

  const RentalBookingTimeline({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final steps = _buildSteps(booking, loc);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: indicator + line
            Column(
              children: [
                _buildCircle(step),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: step.isCompleted
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // RIGHT: content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildContent(step),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCircle(_TimelineStep step) {
    if (step.isCompleted) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }

    if (step.isCurrent) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      );
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildContent(_TimelineStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: step.isCompleted || step.isCurrent
                ? Colors.black
                : Colors.grey,
          ),
        ),
        if (step.date != null)
          Text(
            formatDate(step.date!),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  List<_TimelineStep> _buildSteps(BookingModel booking, AppLocalizations loc) {
    return [
      _TimelineStep(
        title: loc.pending,
        date: booking.createdAt,
        isCompleted: true,
        isCurrent: booking.status == "pending",
      ),
      _TimelineStep(
        title: loc.approved,
        date: booking.approvedAt,
        isCompleted: booking.status != "pending",
        isCurrent: booking.status == "approved",
      ),
      _TimelineStep(
        title: loc.ongoing,
        date: booking.startedAt,
        isCompleted:
            booking.status == "ongoing" || booking.status == "completed",
        isCurrent: booking.status == "ongoing",
      ),
      _TimelineStep(
        title: loc.completed,
        date: booking.completedAt,
        isCompleted: booking.status == "completed",
        isCurrent: false,
      ),
    ];
  }
}

class _TimelineStep {
  final String title;
  final DateTime? date;
  final bool isCompleted;
  final bool isCurrent;

  _TimelineStep({
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.isCurrent,
  });
}
