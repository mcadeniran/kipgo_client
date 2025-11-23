// lib/main.dart
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/driver_ride_provider.dart';
import 'package:kipgo/controllers/driver_status_provider.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/controllers/notification_service.dart';
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
import 'package:kipgo/services/auth_gate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

// @pragma('vm:entry-point')
// Future<void> backgroundHandler(RemoteMessage message) async {}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Initialize NotificationService manually (since no context is available)
  NotificationService().init(flutterLocalNotificationsPlugin);
  await NotificationService().initNotification();

  NotificationService().showNotification(
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? 'You have a new notification',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Only do essential init before runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().init(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => RideHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DriveHistoryProvider()),
        // ProfileProvider will initialize its auth listener lazily
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DriverStatusProvider()),
        ChangeNotifierProvider(create: (_) => DriverRideProvider()),
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
  // final notificationService = NotificationService(
  //   flutterLocalNotificationsPlugin,
  // );

  @override
  void initState() {
    super.initState();

    // ✅ Defer heavy work until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Setup notifications without blocking UI
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // await notificationService.initNotification();
      // NotificationService().init(flutterLocalNotificationsPlugin);

      await _ensureNotificationPermission();

      // Initialize push system
      await pushSystem.initializeCloudMessaging(context);
      await pushSystem.generateAndGetToken(context);

      // Initialize Profile auth listener only when user is ready
      context.read<ProfileProvider>().initAuthListener();
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

    return MaterialApp(
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
      home: const AuthGate(),
      routes: {
        '/customer_home': (_) => const CustomerHome(),
        '/driver_home': (_) => const DriverHome(),
      },
    );
  }
}
