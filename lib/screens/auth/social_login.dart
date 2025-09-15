import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(AppLocalizations.of(context)!.orLoginWith),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 10),
        SignInButton(
          Buttons.google,
          text: AppLocalizations.of(context)!.signInWithGoogle,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        SignInButton(
          Buttons.apple,
          text: AppLocalizations.of(context)!.signInWithApple,
          onPressed: () {},
        ),
      ],
    );
  }
}
