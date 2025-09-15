// lib/screens/rides/riders/widgets/rating_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';

class RatingDialog extends StatefulWidget {
  final void Function(double rating, String? review) onSubmit;

  const RatingDialog({super.key, required this.onSubmit});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Rate your driver"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StarRating(
                mainAxisAlignment: MainAxisAlignment.center,
                allowHalfRating: true,
                color: Colors.amber,
                rating: _rating,
                size: 32,
                onRatingChanged: (rating) => setState(() {
                  _rating = rating;
                }),
              ),
              SizedBox(width: 8),
              Text(
                "($_rating/5.0)",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.tellUsMore,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 10),
          TextField(
            minLines: 1,
            maxLines: 3,
            controller: _reviewController,
            decoration: inputDecoration(
              context: context,
              hint: AppLocalizations.of(context)!.enterComment,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.tertiary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white54,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        SizedBox(height: 8),
        Divider(height: 0, color: AppColors.border),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(
              _rating,
              _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white54,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
