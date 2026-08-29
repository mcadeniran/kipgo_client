import 'package:flutter/material.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:provider/provider.dart';

Future<bool> requireAuthentication(BuildContext context) async {
  final auth = context.read<AuthProvider>();

  if (auth.isLoggedIn) {
    return true;
  }

  final authenticated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const AuthScreen()),
  );

  return authenticated == true;
}
