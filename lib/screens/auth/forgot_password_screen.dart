import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final resetPasswordKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final authService = AuthService();
  bool loading = false;
  String? message;
  String? error;

  Future<void> submitEmail() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    final (success, response) = await authService.resetPassword(
      email: emailController.text.trim(),
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
    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.forgotPasswordTitle.toUpperCase(),
      ),
      backgroundColor: AppColors.primary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                autovalidateMode: AutovalidateMode.onUnfocus,
                key: resetPasswordKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: inputDecoration(
                        context: context,
                        hint: AppLocalizations.of(context)!.enterEmail,
                        useTheme: false,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) {
                        if (email == null) {
                          return AppLocalizations.of(context)!.enterAValidEmail;
                        } else if (!EmailValidator.validate(email)) {
                          return AppLocalizations.of(context)!.enterAValidEmail;
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
                              final isValidForm = resetPasswordKey.currentState!
                                  .validate();
                              if (isValidForm) {
                                submitEmail();
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
                          : Text(AppLocalizations.of(context)!.sendResetLink),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
