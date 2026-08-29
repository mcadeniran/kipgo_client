import 'package:flutter/material.dart';
import 'package:kipgo/screens/auth/login_screen.dart';
import 'package:kipgo/screens/auth/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showSignup = false;

  void _authenticationSuccessful() {
    if (!mounted) return;

    // Return TRUE to RequireAuthenticationPage.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return showSignup
        ? SignupScreen(
            onBackToLogin: () {
              setState(() {
                showSignup = false;
              });
            },
            onAuthenticated: _authenticationSuccessful,
          )
        : LoginScreen(
            onSignupPressed: () {
              setState(() {
                showSignup = true;
              });
            },
            onAuthenticated: _authenticationSuccessful,
          );
  }
}
