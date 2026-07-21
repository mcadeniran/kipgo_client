import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:kipgo/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kipgo/l10n/l10n.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kipgo/controllers/auth_provider.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LocaleProvider() {
    _registerTimeagoLocales();
    _loadLocale(); // load saved locale when provider is created
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('localeCode');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      timeago.setDefaultLocale(languageCode);
      notifyListeners();
    }
  }

  // Future<void> _loadLocale() async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   final ctx = navigatorKey.currentState?.overlay?.context;

  //   final authProvider = Provider.of<AuthProvider>(ctx!, listen: false);

  //   if (user != null) {
  //     String? languageCode;

  //     if (authProvider.role == 'rental_admin') {
  //       languageCode = authProvider.rentalShop?.language;
  //     } else if (authProvider.role == 'rider' ||
  //         authProvider.role == 'driver') {
  //       languageCode = authProvider.profile?.language;
  //     }

  //     // final doc = await FirebaseFirestore.instance
  //     //     .collection('profiles')
  //     //     .doc(user.uid)
  //     //     .get();

  //     // final languageCode = doc.data()?['language'];

  //     if (languageCode != null) {
  //       _locale = Locale(languageCode);
  //       timeago.setDefaultLocale(languageCode);

  //       // Keep local cache in sync
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('localeCode', languageCode);

  //       notifyListeners();
  //       return;
  //     }
  //   }

  //   // Fallback to local storage
  //   final prefs = await SharedPreferences.getInstance();
  //   final languageCode = prefs.getString('localeCode');

  //   if (languageCode != null) {
  //     _locale = Locale(languageCode);
  //     timeago.setDefaultLocale(languageCode);
  //     notifyListeners();
  //   }
  // }

  Future<void> setLocale(Locale locale, BuildContext context) async {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    timeago.setDefaultLocale(_locale.languageCode);
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', locale.languageCode);

    final user = _auth.currentUser;
    if (user != null) {
      if (authProvider.role == 'rental_admin') {
        await _firestore.collection('rentalShops').doc(user.uid).set({
          'language': locale.languageCode,
        }, SetOptions(merge: true));
      } else if (authProvider.role == 'rider' ||
          authProvider.role == 'driver') {
        await _firestore.collection('profiles').doc(user.uid).set({
          'language': locale.languageCode,
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    timeago.setDefaultLocale('en');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('localeCode');
  }

  void _registerTimeagoLocales() {
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('ru', timeago.RuMessages());
  }
}
