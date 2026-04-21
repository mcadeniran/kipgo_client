import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_step.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class PremiumBookingStepper extends StatefulWidget {
  final List<BookingStep> steps;
  final Future<void> Function() onConfirmBooking;
  final bool isLoading;
  final GlobalKey<FormState> driverFormKey;
  final bool Function() validateDocuments;
  final bool Function() validateScheduleStep;

  const PremiumBookingStepper({
    super.key,
    required this.steps,
    required this.onConfirmBooking,
    required this.isLoading,
    required this.driverFormKey,
    required this.validateDocuments,
    required this.validateScheduleStep,
  });

  @override
  State<PremiumBookingStepper> createState() => _PremiumBookingStepperState();
}

class _PremiumBookingStepperState extends State<PremiumBookingStepper> {
  int currentStep = 0;

  bool validateDriverStep() {
    if (!widget.driverFormKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  Future<void> nextStep() async {
    // 🔹 STEP 0 → Driver
    if (currentStep == 0) {
      if (!validateDriverStep()) return;
    }

    // 🔹 STEP 1 → Documents
    if (currentStep == 1) {
      if (!widget.validateDocuments()) return;
    }

    // 🔹 STEP 2 → Schedule
    if (currentStep == 2) {
      if (!widget.validateScheduleStep()) return;
    }

    // 🔹 Move forward
    if (currentStep < widget.steps.length - 1) {
      setState(() => currentStep++);
    }
    // 🔹 Final step → Confirm booking
    else {
      await widget.onConfirmBooking();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20), // move up with keyboard
      child: Column(
        children: [
          _buildStepHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.steps[currentStep].content,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🔥 Connector line (background full width)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(height: 2, color: AppColors.lightLayer),
                  ),
                ),

                // 🔵 Active progress line
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: currentStep / (widget.steps.length - 1),
                      child: Container(
                        height: 2,
                        color: isDark ? AppColors.darkLayer : AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // 🔵 Circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(widget.steps.length, (index) {
                    final isActive = index == currentStep;
                    final isCompleted = index < currentStep;

                    return _buildStepCircle(
                      index,
                      isActive,
                      isCompleted,
                      isDark,
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 📝 Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.steps.length, (index) {
              final isActive = index == currentStep;

              return SizedBox(
                width: 80, // same as circle width
                child: Text(
                  widget.steps[index].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? isDark
                              ? AppColors.lightLayer
                              : AppColors.primary
                        : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    int index,
    bool isActive,
    bool isCompleted,
    bool isDark,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? isDark
                  ? AppColors.darkLayer
                  : AppColors.primary
            : isActive
            ? isDark
                  ? AppColors.darkLayer
                  : AppColors.primary
            : Colors.grey.shade300,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                "${index + 1}",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep == 0)
          SizedBox(width: (MediaQuery.of(context).size.width - 26) / 2),
        if (currentStep > 0)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                disabledForegroundColor: Colors.white54,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: previousStep,
              child: Text(AppLocalizations.of(context)!.back),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white54,
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: (widget.isLoading) ? null : nextStep,
            child: Text(
              currentStep == widget.steps.length - 1
                  ? AppLocalizations.of(context)!.confirmBooking
                  : AppLocalizations.of(context)!.continueAction,
            ),
          ),
        ),
      ],
    );
  }
}
