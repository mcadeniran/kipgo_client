import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/models/rental_shop.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Profile? profile;
  RentalShop? rentalShop;

  /// customer / rider / driver / rental_admin
  String? role;

  bool isLoading = true;

  StreamSubscription<User?>? _authSub;

  User? firebaseUser;

  /// 🔥 Main authentication listener
  void initAuth() {
    isLoading = true;
    notifyListeners();

    _authSub?.cancel();

    _authSub = _auth.authStateChanges().listen((user) async {
      firebaseUser = user;

      // ------------------------------------------------------------
      // LOGGED OUT
      // ------------------------------------------------------------

      if (user == null) {
        profile = null;
        rentalShop = null;
        role = null;

        final context = navigatorKey.currentState?.context;

        if (context != null && context.mounted) {
          context.read<ProfileProvider>().clear();
        }

        isLoading = false;
        notifyListeners();

        return;
      }

      // ------------------------------------------------------------
      // LOGGED IN
      // ------------------------------------------------------------

      await _loadUser(user.uid);
    });
  }

  /// 🔍 Detect whether the authenticated user is a customer/driver
  /// or rental owner.
  Future<void> _loadUser(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestore.collection('profiles').doc(uid).get(),
        _firestore.collection('rentalShops').doc(uid).get(),
      ]);

      final profileDoc = results[0];
      final shopDoc = results[1];

      final context = navigatorKey.currentState?.context;

      // Reset previous identity before loading the new one.
      profile = null;
      rentalShop = null;
      role = null;

      // ------------------------------------------------------------
      // CUSTOMER / DRIVER
      // ------------------------------------------------------------

      if (profileDoc.exists) {
        profile = Profile.fromFirestore(profileDoc);
        role = profile!.role;

        if (context != null && context.mounted) {
          context.read<ProfileProvider>().startListening(uid);
        }
      }
      // ------------------------------------------------------------
      // RENTAL OWNER
      // ------------------------------------------------------------
      else if (shopDoc.exists) {
        rentalShop = RentalShop.fromFirestore(shopDoc.data()!, uid);

        role = 'rental_admin';
      }
      // ------------------------------------------------------------
      // UNKNOWN USER
      // ------------------------------------------------------------
      else {
        throw Exception('User profile not found');
      }
    } catch (e, stackTrace) {
      debugPrint('AuthProvider._loadUser error: $e');
      debugPrintStack(stackTrace: stackTrace);

      profile = null;
      rentalShop = null;
      role = null;
    }

    isLoading = false;
    notifyListeners();
  }

  // ==============================================================
  // LOGIN
  // ==============================================================

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // DO NOT manually navigate here.
      //
      // authStateChanges() will trigger _loadUser(),
      // which will notify AppRouter.
    } catch (e) {
      rethrow;
    }
  }

  // ==============================================================
  // LOGOUT
  // ==============================================================

  Future<void> logout(BuildContext context) async {
    await PushNotificationSystem().removeTokenOnLogout(context);

    await _auth.signOut();

    // authStateChanges() will clear the state.
  }

  Future<void> refreshProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      profile = null;
      rentalShop = null;
      role = null;
      notifyListeners();
      return;
    }

    try {
      final profileDoc = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileDoc.exists) {
        profile = Profile.fromFirestore(profileDoc);
        role = profile!.role;

        final context = navigatorKey.currentState?.context;

        if (context != null && context.mounted) {
          context.read<ProfileProvider>().startListening(user.uid);
        }
      } else {
        profile = null;
        role = null;
      }
    } catch (e, stackTrace) {
      debugPrint('AuthProvider.refreshProfile error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  bool get isLoggedIn => firebaseUser != null;
}
