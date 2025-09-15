import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/login_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final deleteAccountKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool loading = false;
  String? message;
  String? error;

  Future<void> deleteAccount() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    final (success, response) = await authService.deleteAccount(
      password: passwordController.text.trim(),
      context: context,
    );

    setState(() {
      loading = false;
      if (success) {
        message = response;
        error = null;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const LoginScreen()),
            (route) => false,
          );
        });
      } else {
        error = response;
        message = null;
      }
    });
  }

  Future<void> _showConfirmDialog() async {
    final loc = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.confirmDeleteTitle),
        content: Text(loc.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarWidget(title: loc.deleteAccountTitle.toUpperCase()),
      backgroundColor: AppColors.primary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  key: deleteAccountKey,
                  child: Column(
                    children: [
                      Text(
                        loc.deleteWarning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: inputDecoration(
                          context: context,
                          hint: loc.enterPassword,
                        ),
                        validator: (value) {
                          if (value == null || value == '') {
                            return loc.enterPassword;
                          }
                          return null;
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
                                final isValidForm = deleteAccountKey
                                    .currentState!
                                    .validate();
                                if (isValidForm) {
                                  _showConfirmDialog();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(loc.confirmDelete),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
