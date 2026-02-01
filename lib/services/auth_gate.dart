import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipgo/screens/auth/login_screen.dart';
import 'package:kipgo/screens/auth/verify_email_page.dart';
// import 'package:kipgo/services/role_based_auth_gate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for Firebase to give initial user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // return const RoleBasedAuthGate();
          return const VerifyEmailPage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
