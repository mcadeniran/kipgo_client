import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class DriverBookingDetails extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
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
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.maxFinite,
      // height: double.maxFinite,
      child: SingleChildScrollView(
        // padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: inputDecoration(
                context: context,
                hint: 'Full Name',
                prefixIcon: Ic.outline_person,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: inputDecoration(
                context: context,
                hint: 'Email',
                prefixIcon: Ic.outline_alternate_email,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: inputDecoration(
                context: context,
                hint: 'Contact',
                prefixIcon: Ic.outline_local_phone,
              ),
            ),
            SizedBox(height: 15),
            Text("Gender", style: Theme.of(context).textTheme.titleMedium),
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
                          gender,
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
