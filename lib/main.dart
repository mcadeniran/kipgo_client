import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/driver_ride_provider.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/notification_service.dart';
import 'package:kipgo/controllers/rental_shop_provider.dart';
import 'package:kipgo/controllers/ride_history_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/firebase_options.dart';
import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/l10n/l10n.dart';
import 'package:kipgo/pushNotification/push_notification_system.dart';
import 'package:kipgo/screens/homes/customer_home.dart';
import 'package:kipgo/screens/homes/driver_home.dart';
import 'package:kipgo/services/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Only do essential init before runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().init(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await dotenv.load();

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch async errors that are not Flutter errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
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
        // ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => RentalShopProvider()),
        ChangeNotifierProxyProvider<RentalShopProvider, CarProvider>(
          create: (_) => CarProvider(),
          update: (_, shopProvider, carProvider) {
            carProvider!.setShopProvider(shopProvider);
            return carProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => CarRatingProvider()),
        ChangeNotifierProvider(create: (_) => CarBookingProvider()),
        ChangeNotifierProvider(create: (_) => InAppNotificationProvider()),
      ],
      child: const KipGo(),
    ),
  );
}

class KipGo extends StatefulWidget {
  const KipGo({super.key});

  @override
  State<KipGo> createState() => _KipGoState();
}

class _KipGoState extends State<KipGo> {
  final PushNotificationSystem pushSystem = PushNotificationSystem();

  @override
  void initState() {
    super.initState();

    // ✅ Defer heavy work until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AuthProvider>().initAuth();
      // Setup notifications without blocking UI
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      await _ensureNotificationPermission();

      // 🔔 Push notifications
      await pushSystem.initializeCloudMessaging(context);

      // 🔑 Initial token generation
      await pushSystem.generateAndGetToken(context);

      // 🔄 TOKEN REFRESH LISTENER (ADD THIS LINE)
      pushSystem.initTokenRefreshListener(context);

      // 👤 Auth listener
      // context.read<ProfileProvider>().initAuthListener();

      context.read<AppReviewProvider>().checkAndTriggerReview();

      context.read<CarProvider>().listenToCars();
      context.read<RentalShopProvider>().listenToRentalShops();
    });
  }

  Future<void> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.notification.request();
      debugPrint("Notification Permission Status: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return ToastificationWrapper(
      child: MaterialApp(
        title: 'KIPGO',
        supportedLocales: L10n.all,
        locale: localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        // home: const _AuthGateWrapper(),
        home: const AppRouter(),
        routes: {
          '/customer_home': (_) => const CustomerHome(),
          '/driver_home': (_) => const DriverHome(),
        },
      ),
    );
  }
}
