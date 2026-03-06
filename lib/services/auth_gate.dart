import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipgo/screens/auth/app_selection.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:kipgo/screens/auth/verify_email_page.dart';
// import 'package:kipgo/services/role_based_auth_gate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return AuthScreen();
        }

        if (!user.emailVerified) {
          return VerifyEmailPage();
        }

        // return RoleBasedAuthGate();
        return AppSelection();
      },
    );
  }
}
