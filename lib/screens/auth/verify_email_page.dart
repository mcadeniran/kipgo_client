import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/services/role_based_auth_gate.dart';
import 'package:kipgo/utils/colors.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  String? error;
  Timer? timer;
  late String email;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    email = FirebaseAuth.instance.currentUser!.email!;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 10));
      setState(() => canResendEmail = true);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? RoleBasedAuthGate()
      : Scaffold(
          appBar: AppBarWidget(
            title: AppLocalizations.of(context)!.verifyEmail,
          ),
          backgroundColor: AppColors.primary,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.verifyYourEmail,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.verificationEmailSent(email),
                        style: const TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.ifYouDontSee,
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.pleaseVerifyYourEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: canResendEmail
                            ? sendVerificationEmail
                            : null,
                        icon: Icon(Icons.email, size: 32),
                        label: Text(AppLocalizations.of(context)!.resendEmail),
                      ),
                      if (error != null) ...[
                        SizedBox(height: 10),
                        ErrorMessageWidget(localErrorMessage: error!),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(height: 8),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppColors.tertiary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
}
