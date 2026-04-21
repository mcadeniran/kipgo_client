import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class DriverBookingDetails extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final List<String> genders;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const DriverBookingDetails({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.dobController,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.maxFinite,
      // height: double.maxFinite,
      child: SingleChildScrollView(
        // padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.fullNameIsRequired;
                }
                if (value.trim().length < 3) {
                  return loc.nameIsTooShort;
                }
                return null;
              },
              decoration: inputDecoration(
                context: context,
                hint: loc.fullName,
                prefixIcon: Ic.outline_person,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.emailIsRequired;
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return loc.invalidEmail;
                }
                return null;
              },
              decoration: inputDecoration(
                context: context,
                hint: loc.email,
                prefixIcon: Ic.outline_alternate_email,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.phoneIsRequired;
                }
                if (value.length < 10) {
                  return loc.invalidPhoneNumber;
                }
                return null;
              },
              decoration: inputDecoration(
                context: context,
                hint: loc.phone,
                prefixIcon: Ic.outline_local_phone,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: dobController,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return loc.dateOfBirthIsRequired;
                }
                return null;
              },
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1995),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );

                if (date != null) {
                  dobController.text = "${date.day}/${date.month}/${date.year}";
                }
              },
              decoration: inputDecoration(
                context: context,
                hint: loc.dateOfBirth,
                prefixIcon: Ic.outline_calendar_today,
              ),
            ),
            SizedBox(height: 15),
            Text(loc.gender, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            Row(
              children: genders.map((gender) {
                final bool isSelected = selectedGender == gender;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onGenderChanged(gender);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                            ? AppColors.darkLayer.withValues(alpha: 0.15)
                            : AppColors.lightLayer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          gender == 'Male'
                              ? loc.male
                              : gender == 'Female'
                              ? loc.female
                              : loc.others,
                          // gender,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
