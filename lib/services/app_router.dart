import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/screens/auth/app_selection.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:kipgo/screens/auth/verify_email_page.dart';
import 'package:kipgo/screens/rental_owner/rental_owner_bottom_navigation.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ⏳ Loading
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // 🔐 Not logged in
    if (!auth.isLoggedIn) {
      _hasInitialized = false;
      return AuthScreen();
    }

    // 🔥 INIT ONCE AFTER LOGIN / RESTORE
    if (!_hasInitialized) {
      _hasInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // final uid = FirebaseAuth.instance.currentUser!.uid;
        final uid = auth.firebaseUser!.uid;

        if (auth.role == 'rental_admin') {
          context.read<RentalShopProvider>().listenToMyShop(uid);
          context.read<BookingProvider>().listenToShopBookings(uid);
          context.read<CarProvider>().setCurrentShop(uid);
        }

        if (auth.role == 'rider' || auth.role == 'driver') {
          context.read<BookingProvider>().listenToUserBookings(uid);
        }
      });
    }

    // 📧 Email check
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified && auth.role != 'rental_admin') {
      return VerifyEmailPage();
    }

    final profileProvider = context.watch<ProfileProvider>();

    if ((auth.role == 'rider' || auth.role == 'driver') &&
        !profileProvider.hasLoadedOnce) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // 🚀 Role routing
    switch (auth.role) {
      // case 'driver':
      //   return const DriverHome();

      case 'rental_admin':
        return const RenterOwnerBottomNavigation();

      default:
        // return const CustomerHome();
        // return const RentalBottomNavigation();
        return const AppSelection();
    }
  }
}
