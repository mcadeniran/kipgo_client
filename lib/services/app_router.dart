import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:kipgo/screens/auth/profile_error_screen.dart';
import 'package:kipgo/screens/auth/verify_email_page.dart';
import 'package:kipgo/screens/rental/rental_bottom_navigation.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    // ⏳ FIRST LOAD ONLY
    if (!provider.hasLoadedOnce) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // 🔐 NOT LOGGED IN
    if (provider.profile == null) {
      return AuthScreen();
    }

    // 📧 EMAIL NOT VERIFIED
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      return VerifyEmailPage();
    }

    if (provider.hasError) {
      return const ProfileErrorScreen();
    }

    // ✅ MAIN APP (DO NOT REBUILD THIS)
    return const _StableHome();
  }
}

class _StableHome extends StatefulWidget {
  const _StableHome();

  @override
  State<_StableHome> createState() => _StableHomeState();
}

class _StableHomeState extends State<_StableHome> {
  late final Widget home;

  @override
  void initState() {
    super.initState();
    home = const RentalBottomNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return home;
  }
}
