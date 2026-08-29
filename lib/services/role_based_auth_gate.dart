import 'package:flutter/material.dart';
import 'package:kipgo/screens/auth/main_app_bottom_navigation.dart';
import 'package:kipgo/screens/auth/profile_error_screen.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';

class RoleBasedAuthGate extends StatelessWidget {
  const RoleBasedAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    if (profileProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // final profile = profileProvider.profile;

    if (profileProvider.profile == null) {
      return ProfileErrorScreen(); // NOT LoginScreen
    }

    // if (profile == null) {
    //   return const LoginScreen();
    // }

    return MainAppBottomNavigation();

    // return profileProvider.profile!.role == 'driver'
    //     ? const DriverHome()
    //     : const CustomerHome();
  }
}
