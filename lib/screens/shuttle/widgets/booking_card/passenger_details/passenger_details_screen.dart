import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_passenger_draft.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/BookingReview/booking_review_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class PassengerDetailsScreen extends StatefulWidget {
  const PassengerDetailsScreen({super.key});

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _requestController;

  @override
  void initState() {
    super.initState();

    final booking = context.read<ShuttleBookingProvider>();
    final draft = booking.draft;

    final passenger = draft.passenger ?? const ShuttlePassengerDraft();

    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    final profileFullName = profile != null
        ? "${profile.personal.firstName} ${profile.personal.lastName}".trim()
        : "";

    final profilePhone = profile?.personal.phone ?? "";
    final profileEmail = profile?.email ?? "";

    final fullName = passenger.fullName.isNotEmpty == true
        ? passenger.fullName
        : profileFullName;

    final phone = passenger.phoneNumber.isNotEmpty == true
        ? passenger.phoneNumber
        : profilePhone;

    final email = passenger.email.isNotEmpty == true
        ? passenger.email
        : profileEmail;

    _nameController = TextEditingController(text: fullName);
    _phoneController = TextEditingController(text: phone);
    _emailController = TextEditingController(text: email);

    _requestController = TextEditingController(
      text: draft.specialRequest ?? "",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      booking.updatePassenger(
        fullName: fullName,
        phoneNumber: phone,
        email: email,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _requestController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Consumer<ShuttleBookingProvider>(
      builder: (_, booking, _) {
        return Scaffold(
          appBar: AppBarWidget(title: loc.contactDetails),
          backgroundColor: AppColors.primary,
          body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.all(12),
                        children: [
                          Text(
                            loc.whosTravelling,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            loc.pleaseProvideContact,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _PassengerTextField(
                            controller: _nameController,
                            label: loc.fullName,
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc.pleaseEnterContactName;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              booking.updatePassenger(fullName: value);
                            },
                          ),

                          _PassengerTextField(
                            controller: _phoneController,
                            label: loc.phoneNumber,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc.pleaseEnterAPhoneNumber;
                              }

                              if (value.trim().length < 8) {
                                return loc.invalidPhoneNumber;
                              }

                              return null;
                            },
                            onChanged: (value) {
                              booking.updatePassenger(phoneNumber: value);
                            },
                          ),

                          _PassengerTextField(
                            controller: _emailController,
                            label: loc.email,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              if (!value.contains("@")) {
                                return loc.invalidEmail;
                              }

                              return null;
                            },
                            onChanged: (value) {
                              booking.updatePassenger(email: value);
                            },
                          ),

                          const SizedBox(height: 10),

                          Text(
                            loc.specialRequest,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _PassengerTextField(
                            controller: _requestController,
                            label: loc.anythingElse,
                            icon: Icons.edit_note,
                            maxLines: 5,
                            onChanged: booking.setSpecialRequest,
                          ),
                        ],
                      ),
                    ),

                    _BottomContinueButton(
                      enabled: booking.canContinueToReview,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingReviewScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomContinueButton extends StatelessWidget {
  const _BottomContinueButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: enabled ? onPressed : null,
          child: Text(
            "${loc.continueAction} (3/5)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _PassengerTextField extends StatelessWidget {
  const _PassengerTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    // this.hintText,
  });

  final TextEditingController controller;
  final String label;
  // final String? hintText;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          // hintText: hintText,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: isDark ? AppColors.darkAccent : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.border.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
        ),
      ),
    );
  }
}
