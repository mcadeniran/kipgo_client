import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/screens/auth/profile_error_screen.dart';
import 'package:kipgo/screens/rental/rental_bottom_navigation.dart';
import 'package:provider/provider.dart';

class ProfileLoader extends StatefulWidget {
  const ProfileLoader({super.key});

  @override
  State<ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<ProfileLoader> {
  Widget? _child;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final profileProvider = context.watch<ProfileProvider>();

    if (profileProvider.isLoading) {
      _child = const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    } else if (profileProvider.profile == null) {
      _child = ProfileErrorScreen();
    } else {
      _child ??= const RentalBottomNavigation(); // 🔥 KEY LINE
    }
  }

  @override
  Widget build(BuildContext context) {
    return _child!;
  }
}
