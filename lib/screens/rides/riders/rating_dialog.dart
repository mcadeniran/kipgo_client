import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';

class RatingDialog extends StatefulWidget {
  final Future<void> Function(double rating, String? review) onSubmit;
  final VoidCallback? onCancel;

  const RatingDialog({super.key, required this.onSubmit, this.onCancel});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 2.5;

  final TextEditingController _reviewController = TextEditingController();

  static const int _maxReviewLength = 300;

  bool _isSubmitting = false;

  String _ratingLabel(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_rating >= 5) {
      return localizations.excellent;
    } else if (_rating >= 4) {
      return localizations.veryGood;
    } else if (_rating >= 3) {
      return localizations.good;
    } else if (_rating >= 2) {
      return localizations.fair;
    } else {
      return localizations.poor;
    }
  }

  IconData _ratingIcon() {
    if (_rating >= 4.5) {
      return Icons.sentiment_very_satisfied_rounded;
    } else if (_rating >= 3.5) {
      return Icons.sentiment_satisfied_rounded;
    } else if (_rating >= 2.5) {
      return Icons.sentiment_neutral_rounded;
    } else if (_rating >= 1.5) {
      return Icons.sentiment_dissatisfied_rounded;
    }

    return Icons.sentiment_very_dissatisfied_rounded;
  }

  Color _ratingColor(BuildContext context) {
    if (_rating >= 4) {
      return Colors.amber.shade700;
    } else if (_rating >= 3) {
      return AppColors.secondary;
    } else {
      return AppColors.tertiary;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final review = _reviewController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(_rating, review.isEmpty ? null : review);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _cancel() {
    if (_isSubmitting) return;

    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final ratingColor = _ratingColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            // color: theme.scaffoldBackgroundColor,
            color: isDark ? AppColors.darkAccent : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -------------------------------------------------------
                  // TOP HANDLE
                  // -------------------------------------------------------
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // -------------------------------------------------------
                  // HEADER
                  // -------------------------------------------------------
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.lightLayer.withValues(alpha: .08)
                              : AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.rateYourDriver,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              localizations.tellUsMore,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: _isSubmitting ? null : _cancel,
                        tooltip: localizations.cancel,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // -------------------------------------------------------
                  // RATING DISPLAY
                  // -------------------------------------------------------
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: ratingColor.withValues(
                        alpha: isDark ? 0.10 : 0.06,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: ratingColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            _ratingIcon(),
                            key: ValueKey(_rating),
                            size: 40,
                            color: ratingColor,
                          ),
                        ),

                        const SizedBox(height: 6),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _ratingLabel(context),
                            key: ValueKey(_ratingLabel(context)),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: ratingColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '${_rating.toStringAsFixed(1)} / 5.0',
                            key: ValueKey(_rating),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------------------------------------
                  // STAR RATING
                  // -------------------------------------------------------
                  Text(
                    localizations.tapToRate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  FittedBox(
                    child: StarRating(
                      mainAxisAlignment: MainAxisAlignment.center,
                      allowHalfRating: true,
                      color: Colors.amber,
                      rating: _rating,
                      size: 40,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  // -------------------------------------------------------
                  // REVIEW SECTION
                  // -------------------------------------------------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.tellUsMore,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.10 : 0.035,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _reviewController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: _maxReviewLength,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      decoration:
                          inputDecoration(
                            context: context,
                            hint: localizations.enterComment,
                          ).copyWith(
                            filled: true,
                            alignLabelWithHint: true,
                            fillColor: isDark
                                ? AppColors.darkAccent
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            counterStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.textTheme.labelSmall?.color
                                  ?.withValues(alpha: 0.55),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------------------------------------
                  // SUBMIT BUTTON
                  // -------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.65,
                        ),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.submit,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -------------------------------------------------------
                  // CANCEL
                  // -------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _cancel,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        localizations.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
