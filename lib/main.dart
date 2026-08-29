import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kipgo/controllers/app_review_provider.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/booking_provider.dart';
import 'package:kipgo/controllers/bottom_nav_provider.dart';
import 'package:kipgo/controllers/car_booking_provider.dart';
import 'package:kipgo/controllers/car_provider.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/controllers/crypto_verification_provider.dart';
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/driver_ride_provider.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/notification_service.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/controllers/ride_history_provider.dart';
import 'package:kipgo/controllers/shuttle_booking_provider.dart';
import 'package:kipgo/controllers/shuttle_bookings_provider.dart';
import 'package:kipgo/controllers/shuttle_fleet_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/firebase_options.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/l10n/l10n.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/homes/customer_home.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
import 'package:kipgo/screens/splash/kipgo_splash_screen.dart';
import 'package:kipgo/services/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// ============================================================
// GLOBAL NOTIFICATION OBJECTS
// ============================================================

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel_v2',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification'),
);

// ============================================================
// FIREBASE BACKGROUND MESSAGE HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Background notification received: ${message.messageId}');
  } catch (e, stack) {
    debugPrint('Background Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stack);
  }
}

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  // ----------------------------------------------------------
  // Preserve native splash while Flutter initializes.
  // ----------------------------------------------------------

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ----------------------------------------------------------
  // System UI
  // ----------------------------------------------------------

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ----------------------------------------------------------
  // Image cache
  // ----------------------------------------------------------

  PaintingBinding.instance.imageCache.maximumSize = 1000;

  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20; // 300 MB

  // ----------------------------------------------------------
  // Firebase
  //
  // This is required before providers/services that depend
  // on Firebase are used.
  // ----------------------------------------------------------

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ----------------------------------------------------------
  // Crashlytics
  //
  // Set these before runApp so Flutter errors are captured
  // from the beginning of the application lifecycle.
  // ----------------------------------------------------------

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  };

  // ----------------------------------------------------------
  // Environment variables
  // ----------------------------------------------------------

  try {
    await dotenv.load();
  } catch (e) {
    // Do not prevent the application from launching if the
    // environment file is unavailable in a particular build.
    debugPrint('dotenv could not be loaded: $e');
  }

  // ----------------------------------------------------------
  // Local notifications
  // ----------------------------------------------------------

  NotificationService().init(flutterLocalNotificationsPlugin);

  // ----------------------------------------------------------
  // Firebase Messaging background handler
  // ----------------------------------------------------------

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ----------------------------------------------------------
  // Foreground notification presentation
  // ----------------------------------------------------------

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // ----------------------------------------------------------
  // Launch application
  // ----------------------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        // ======================================================
        // GENERAL APP PROVIDERS
        // ======================================================
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => AppInfo()),

        ChangeNotifierProvider(create: (_) => RideHistoryProvider()),

        ChangeNotifierProvider(create: (_) => DriveHistoryProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => DriverStatusProvider()),

        ChangeNotifierProvider(create: (_) => DriverRideProvider()),

        ChangeNotifierProvider(create: (_) => AppReviewProvider()),

        // ======================================================
        // RENTAL
        // ======================================================
        ChangeNotifierProvider(create: (_) => RentalShopProvider()),

        ChangeNotifierProxyProvider<RentalShopProvider, CarProvider>(
          create: (_) => CarProvider(),

          update: (_, shopProvider, carProvider) {
            carProvider!.setShopProvider(shopProvider);

            return carProvider;
          },
        ),

        ChangeNotifierProvider(create: (_) => BookingProvider()),

        ChangeNotifierProvider(create: (_) => CarRatingProvider()),

        ChangeNotifierProvider(create: (_) => CarBookingProvider()),

        // ======================================================
        // SHUTTLE
        // ======================================================
        ChangeNotifierProvider(create: (_) => ShuttleBookingsProvider()),

        ChangeNotifierProvider(create: (_) => ShuttleBookingProvider()),

        ChangeNotifierProvider(create: (_) => ShuttleFleetProvider()),

        // ======================================================
        // NAVIGATION / NOTIFICATIONS / PAYMENTS
        // ======================================================
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),

        ChangeNotifierProvider(create: (_) => InAppNotificationProvider()),

        ChangeNotifierProvider(create: (_) => CryptoVerificationProvider()),
      ],

      child: const KipGo(),
    ),
  );
}

// ============================================================
// KIPGO ROOT
// ============================================================

class KipGo extends StatefulWidget {
  const KipGo({super.key});

  @override
  State<KipGo> createState() => _KipGoState();
}

class _KipGoState extends State<KipGo> {
  final PushNotificationSystem pushSystem = PushNotificationSystem();

  bool _startupStarted = false;

  @override
  void initState() {
    super.initState();

    // --------------------------------------------------------
    // Wait until the first Flutter frame has been scheduled.
    //
    // This is important because we do not want Firebase
    // listeners, notification permissions, Firestore streams,
    // etc. to block the first visible Flutter frame.
    // --------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startApplication();
    });
  }

  // ==========================================================
  // START APPLICATION
  // ==========================================================

  Future<void> _startApplication() async {
    if (_startupStarted) return;

    _startupStarted = true;

    // --------------------------------------------------------
    // Remove native splash.
    //
    // The animated KipgoSplashScreen is now visible.
    // --------------------------------------------------------

    FlutterNativeSplash.remove();

    // --------------------------------------------------------
    // Auth initialization
    // --------------------------------------------------------

    context.read<AuthProvider>().initAuth();

    // --------------------------------------------------------
    // Notification channel
    // --------------------------------------------------------

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e, stack) {
      debugPrint('Notification channel creation failed: $e');

      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Notification channel creation failed',
      );
    }

    // --------------------------------------------------------
    // Notification permission
    // --------------------------------------------------------

    await _ensureNotificationPermission();

    // --------------------------------------------------------
    // Push notifications
    // --------------------------------------------------------

    try {
      await pushSystem.initializeCloudMessaging(context);

      await pushSystem.generateAndGetToken(context);

      pushSystem.initTokenRefreshListener(context);
    } catch (e, stack) {
      debugPrint('Push notification initialization failed: $e');

      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Push notification initialization failed',
      );
    }

    // --------------------------------------------------------
    // App review
    // --------------------------------------------------------

    try {
      context.read<AppReviewProvider>().checkAndTriggerReview();
    } catch (e) {
      debugPrint('App review initialization failed: $e');
    }

    // --------------------------------------------------------
    // Rental data
    //
    // Start both listeners.
    //
    // CarProvider receives RentalShopProvider through the
    // ProxyProvider, so the providers remain connected.
    // --------------------------------------------------------

    try {
      context.read<RentalShopProvider>().listenToRentalShops();

      context.read<CarProvider>().listenToCars();
    } catch (e, stack) {
      debugPrint('Rental data initialization failed: $e');

      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Rental data initialization failed',
      );
    }
  }

  // ==========================================================
  // NOTIFICATION PERMISSION
  // ==========================================================

  Future<void> _ensureNotificationPermission() async {
    try {
      final status = await Permission.notification.status;

      if (status.isDenied) {
        final result = await Permission.notification.request();

        debugPrint('Notification permission result: $result');
      } else if (status.isPermanentlyDenied) {
        debugPrint('Notification permission permanently denied.');
      }
    } catch (e, stack) {
      debugPrint('Notification permission request failed: $e');

      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Notification permission request failed',
      );
    }
  }

  // ==========================================================
  // MATERIAL APP
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final localeProvider = context.watch<LocaleProvider>();

    return ToastificationWrapper(
      child: MaterialApp(
        title: 'KIPGO',

        // ------------------------------------------------------
        // Localization
        // ------------------------------------------------------
        supportedLocales: L10n.all,

        locale: localeProvider.locale,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        // ------------------------------------------------------
        // Navigation
        // ------------------------------------------------------
        navigatorKey: navigatorKey,

        debugShowCheckedModeBanner: false,

        // ------------------------------------------------------
        // Theme
        // ------------------------------------------------------
        themeMode: themeProvider.themeMode,

        theme: MyThemes.lightTheme,

        darkTheme: MyThemes.darkTheme,

        // ------------------------------------------------------
        // Application entry
        //
        // Animated splash is the first Flutter screen.
        // After its animation completes, AppRouter is shown.
        // ------------------------------------------------------
        home: const KipgoSplashScreen(child: AppRouter()),

        // ------------------------------------------------------
        // Named routes
        // ------------------------------------------------------
        routes: {
          '/customer_home': (_) => const CustomerHome(),

          '/driver_home': (_) => const DriverHome(),
        },
      ),
    );
  }
}

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel_v2',
//   'High Importance Notifications',
//   description: 'This channel is used for important notifications.',
//   importance: Importance.max,
//   playSound: true,
//   sound: RawResourceAndroidNotificationSound('notification'),
// );

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//   PaintingBinding.instance.imageCache.maximumSize = 1000;
//   PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20; // 300 MB

//   // ✅ Only do essential init before runApp
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   NotificationService().init(flutterLocalNotificationsPlugin);
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   await dotenv.load();

//   // Pass all uncaught errors to Crashlytics.
//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

//   // Catch async errors that are not Flutter errors
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => LocaleProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => AppInfo()),
//         ChangeNotifierProvider(create: (_) => RideHistoryProvider()),
//         ChangeNotifierProvider(create: (_) => DriveHistoryProvider()),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()),
//         ChangeNotifierProvider(create: (_) => DriverStatusProvider()),
//         ChangeNotifierProvider(create: (_) => DriverRideProvider()),
//         ChangeNotifierProvider(create: (_) => AppReviewProvider()),
//         // ChangeNotifierProvider(create: (_) => CarProvider()),
//         ChangeNotifierProvider(create: (_) => RentalShopProvider()),
//         ChangeNotifierProxyProvider<RentalShopProvider, CarProvider>(
//           create: (_) => CarProvider(),
//           update: (_, shopProvider, carProvider) {
//             carProvider!.setShopProvider(shopProvider);
//             return carProvider;
//           },
//         ),
//         ChangeNotifierProvider(create: (_) => BookingProvider()),
//         ChangeNotifierProvider(create: (_) => ShuttleBookingsProvider()),
//         ChangeNotifierProvider(create: (_) => BottomNavProvider()),
//         ChangeNotifierProvider(create: (_) => CarRatingProvider()),
//         ChangeNotifierProvider(create: (_) => CarBookingProvider()),
//         ChangeNotifierProvider(create: (_) => ShuttleBookingProvider()),
//         ChangeNotifierProvider(create: (_) => ShuttleFleetProvider()),
//         ChangeNotifierProvider(create: (_) => InAppNotificationProvider()),
//         ChangeNotifierProvider(create: (_) => CryptoVerificationProvider()),
//       ],
//       child: const KipGo(),
//     ),
//   );
// }

// class KipGo extends StatefulWidget {
//   const KipGo({super.key});

//   @override
//   State<KipGo> createState() => _KipGoState();
// }

// class _KipGoState extends State<KipGo> {
//   final PushNotificationSystem pushSystem = PushNotificationSystem();

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Defer heavy work until after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       context.read<AuthProvider>().initAuth();
//       // Setup notifications without blocking UI
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(channel);

//       await _ensureNotificationPermission();

//       // 🔔 Push notifications
//       await pushSystem.initializeCloudMessaging(context);

//       // 🔑 Initial token generation
//       await pushSystem.generateAndGetToken(context);

//       // 🔄 TOKEN REFRESH LISTENER (ADD THIS LINE)
//       pushSystem.initTokenRefreshListener(context);

//       // 👤 Auth listener
//       // context.read<ProfileProvider>().initAuthListener();

//       context.read<AppReviewProvider>().checkAndTriggerReview();

//       context.read<CarProvider>().listenToCars();
//       context.read<RentalShopProvider>().listenToRentalShops();
//     });
//   }

//   Future<void> _ensureNotificationPermission() async {
//     final status = await Permission.notification.status;

//     if (status.isDenied || status.isPermanentlyDenied) {
//       final result = await Permission.notification.request();
//       debugPrint("Notification Permission Status: $result");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = context.watch<ThemeProvider>();
//     final localeProvider = context.watch<LocaleProvider>();

//     return ToastificationWrapper(
//       child: MaterialApp(
//         title: 'KIPGO',
//         supportedLocales: L10n.all,
//         locale: localeProvider.locale,
//         localizationsDelegates: const [
//           AppLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//         ],
//         navigatorKey: navigatorKey,
//         debugShowCheckedModeBanner: false,
//         themeMode: themeProvider.themeMode,
//         theme: MyThemes.lightTheme,
//         darkTheme: MyThemes.darkTheme,
//         // home: const _AuthGateWrapper(),
//         home: const AppRouter(),
//         routes: {
//           '/customer_home': (_) => const CustomerHome(),
//           '/driver_home': (_) => const DriverHome(),
//         },
//       ),
//     );
//   }
// }
