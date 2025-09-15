import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final changePasswordKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();

  bool loading = false;
  String? message;
  String? error;

  Future<void> changePassword() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    final (success, response) = await authService.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      context: context,
    );

    setState(() {
      loading = false;
      if (success) {
        message = response;
        error = null;
      } else {
        error = response;
        message = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarWidget(title: loc.changePasswordTitle.toUpperCase()),
      backgroundColor: AppColors.primary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Form(
            autovalidateMode: AutovalidateMode.onUnfocus,
            key: changePasswordKey,
            child: Column(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: inputDecoration(
                          context: context,
                          hint: loc.currentPassword,
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return loc.enterCurrentPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: inputDecoration(
                          context: context,
                          hint: loc.newPassword,
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return loc.enterNewPassword;
                          } else if (value.length < 8) {
                            return AppLocalizations.of(context)!.passwordLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: inputDecoration(
                          context: context,
                          hint: loc.confirmPassword,
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return loc.enterConfirmPassword;
                          } else if (value.length < 8) {
                            return AppLocalizations.of(
                              context,
                            )!.enterMinCharacters;
                          } else if (newPasswordController.text.trim() !=
                              confirmPasswordController.text.trim()) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordsDoNotMatch;
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      if (message != null) ...[
                        SuccessMessageWidget(successMessage: message!),
                        const SizedBox(height: 10),
                      ],
                      if (error != null) ...[
                        ErrorMessageWidget(localErrorMessage: error!),
                        const SizedBox(height: 10),
                      ],
                      ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                                final isValidForm = changePasswordKey
                                    .currentState!
                                    .validate();
                                if (isValidForm) {
                                  changePassword();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor: Colors.white54,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator()
                            : Text(loc.updatePassword),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
