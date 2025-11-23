import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';

// ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up new user and create profile
  Future<Profile?> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final profile = Profile(
        id: uid,
        email: email,
        username: username,
        role: role,
        drives: [],
        rides: [],
        token: '',
        newRideStatus: 'idle',
        personal: Personal(
          firstName: '',
          lastName: '',
          photoUrl: '',
          reviews: [],
          phone: '',
        ),
        vehicle: Vehicle(
          numberPlate: '',
          colour: '',
          licence: '',
          model: '',
          registrationUrl: '',
          selfieUrl: '',
          licenceUrl: '',
          registrationStatus: '',
          registrationText: '',
          licenceStatus: '',
          licenceText: '',
          selfieStatus: '',
          selfieText: '',
        ),
        account: Account(
          isOnline: true,
          isProfileCompleted: false,
          isApproved: role == 'driver' ? false : true,
          createdAt: DateTime.now(),
        ),
      );

      // Save profile to Firestore
      await _firestore.collection('profiles').doc(uid).set(profile.toMap());

      return profile;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists with that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('This sign-up method is disabled.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('The supplied credential is invalid or expired.');
      } else {
        throw Exception('Signup failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Login with email & password
  Future<Profile?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await getProfile(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No account found with that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current logged-in user's profile
  Future<Profile?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getProfile(user.uid);
  }

  /// Fetch profile from Firestore by user ID
  Future<Profile?> getProfile(String uid) async {
    final doc = await _firestore.collection('profiles').doc(uid).get();
    if (!doc.exists) return null;
    return Profile.fromFirestore(doc);
  }

  /// Stream profile for realtime updates
  Stream<Profile?> streamProfile(String uid) {
    return _firestore
        .collection('profiles')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Profile.fromFirestore(doc) : null);
  }

  Future<(bool, String)> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    final loc = AppLocalizations.of(context)!;

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return (
        true,
        loc.resetPasswordSuccess(email), // uses placeholder
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          return (false, loc.resetPasswordInvalidEmail);
        case "user-not-found":
          return (false, loc.resetPasswordUserNotFound);
        case "missing-email":
          return (false, loc.resetPasswordMissingEmail);
        default:
          return (false, "${loc.resetPasswordGenericError}\n${e.message}");
      }
    } catch (_) {
      return (false, loc.resetPasswordGenericError);
    }
  }

  Future<(bool, String)> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    final loc = AppLocalizations.of(context)!;

    final user = _auth.currentUser;

    try {
      //  Re-authenticate before updating password
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
      return (true, loc.passwordChangeSuccess);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return (false, loc.incorrectCurrentPassword);
        case "wrong-password":
          return (false, loc.incorrectCurrentPassword);
        case "weak-password":
          return (false, loc.weakPassword);
        default:
          return (false, loc.genericError);
      }
    }
  }

  Future<(bool, String)> deleteAccount({
    required String password,
    required BuildContext context,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final user = _auth.currentUser;

    if (user == null) {
      return (false, loc.genericError);
    }

    try {
      // 🔑 Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(cred);

      // Optional: delete Firestore/RealtimeDB data
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(user.uid)
          .delete();

      await user.delete();

      await _auth.signOut();
      return (true, loc.deleteSuccess);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return (false, loc.incorrectPassword);
        case "wrong-password":
          return (false, loc.incorrectPassword);
        case "requires-recent-login":
          return (false, loc.requiresRecentLogin);
        default:
          return (false, loc.genericError);
      }
    }
  }

  // Future<void> updateUsername({required String username}) async {
  //   await currentUser!.updateDisplayName(username);

  //   // Also update in Firestore
  //   await firestore.collection('profiles').doc(currentUser!.uid).update({
  //     'username': username,
  //   });
  // }

  // Future<void> deleteAccount({
  //   required String email,
  //   required String password,
  // }) async {
  //   AuthCredential credential = EmailAuthProvider.credential(
  //     email: email,
  //     password: password,
  //   );

  //   // Reauthenticate
  //   await currentUser!.reauthenticateWithCredential(credential);

  //   // Delete Firestore profile
  //   await firestore.collection('profiles').doc(currentUser!.uid).delete();

  //   // Delete Firebase Auth account
  //   await currentUser!.delete();

  //   // Sign out
  //   await firebaseAuth.signOut();
  // }
}
