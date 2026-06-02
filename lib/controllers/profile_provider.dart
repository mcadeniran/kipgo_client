import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

// class ProfileProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();

//   Profile? _profile;
//   Profile? get profile => _profile;

//   bool _isLoading = true;
//   bool get isLoading => _isLoading;

//   bool _initialized = false;

//   StreamSubscription<Profile?>? _profileSubscription;

//   // Stream and update profile in real-time
//   void _listenToProfile(String uid) {
//     _isLoading = true;
//     notifyListeners();

//     _profileSubscription?.cancel();

//     _profileSubscription = _authService
//         .streamProfile(uid)
//         .listen(
//           (profile) {
//             _profile = profile;
//             _isLoading = false;
//             notifyListeners();
//           },
//           onError: (error) {
//             _profile = null;
//             _isLoading = false;
//             notifyListeners();
//           },
//         );
//   }

//   // void _listenToProfile(String uid) {
//   //   _isLoading = true;
//   //   notifyListeners();

//   //   _authService.streamProfile(uid).listen((profile) {
//   //     _profile = profile;
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   });
//   // }

//   Future<void> reloadProfile() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     _listenToProfile(user.uid);
//   }

//   // Listen to auth changes and load profile
//   // void initAuthListener() {
//   //   if (_initialized) return;
//   //   _initialized = true;
//   //   FirebaseAuth.instance.authStateChanges().listen((user) {
//   //     if (user != null) {
//   //       _listenToProfile(user.uid);
//   //     } else {
//   //       _profile = null;
//   //       notifyListeners();
//   //     }
//   //   });
//   // }

//   // Sign up
//   Future<void> signUp({
//     required String email,
//     required String password,
//     required String username,
//     required String role,
//   }) async {
//     _isLoading = true;
//     notifyListeners();
//     await _authService.signUp(
//       email: email,
//       password: password,
//       username: username,
//       role: role,
//     );
//     _isLoading = false;
//     notifyListeners();
//   }

//   // Login
//   Future<void> login({required String email, required String password}) async {
//     _isLoading = true;
//     notifyListeners();
//     await _authService.login(email: email, password: password);
//     _isLoading = false;
//     notifyListeners();
//   }

//   // Logout
//   Future<void> logout() async {
//     await _authService.logout();
//   }
// }

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _initialized = false;

  String? _currentUid;

  StreamSubscription<Profile?>? _profileSubscription;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  bool hasError = false;

  // void initAuthListener() {
  //   if (_initialized) return;
  //   _initialized = true;

  //   FirebaseAuth.instance.authStateChanges().listen((user) {
  //     if (user != null) {
  //       _listenToProfile(user.uid);
  //     } else {
  //       _profileSubscription?.cancel();

  //       _profile = null;
  //       _isLoading = false;
  //       _hasLoadedOnce = true; // ✅ IMPORTANT

  //       notifyListeners();
  //     }
  //   });
  // }

  // void _listenToProfile(String uid) {
  //   _profileSubscription?.cancel();

  //   _isLoading = true;
  //   notifyListeners();

  //   _profileSubscription = _authService
  //       .streamProfile(uid)
  //       .listen(
  //         (profile) {
  //           _profile = profile;
  //           hasError = false;
  //           _isLoading = false;
  //           _hasLoadedOnce = true; // ✅ IMPORTANT
  //           notifyListeners();
  //         },
  //         onError: (error) {
  //           hasError = true;
  //           _profile = null;
  //           _isLoading = false;
  //           _hasLoadedOnce = true; // ✅ IMPORTANT
  //           notifyListeners();
  //         },
  //       );
  // }

  /// 🔥 Start listening ONCE per user
  void startListening(String uid) {
    if (_currentUid == uid) return; // 🔥 prevents duplicate listeners

    _currentUid = uid;
    _initialized = true;

    _isLoading = true;
    notifyListeners();

    _profileSubscription?.cancel();

    _profileSubscription = _authService
        .streamProfile(uid)
        .listen(
          (profile) {
            // 🔥 Prevent unnecessary rebuilds
            if (_profile?.toMap().toString() == profile?.toMap().toString()) {
              return;
            }

            _profile = profile;
            _isLoading = false;
            _hasLoadedOnce = true;

            notifyListeners();
          },
          onError: (error) {
            _profile = null;
            _isLoading = false;
            _hasLoadedOnce = true;
            notifyListeners();
          },
        );
  }

  Future<void> reloadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _initialized = false; // allow restart
    startListening(user.uid);
  }

  void clear() {
    _profileSubscription?.cancel();
    _profile = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _authService.logout();
    clear(); // 🔥 important
  }
}
