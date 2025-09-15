// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/locale_provider.dart';
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
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Only do essential init before runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();

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
      // Setup notifications without blocking UI
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Initialize push system
      await pushSystem.initializeCloudMessaging(context);
      await pushSystem.generateAndGetToken(context);

      // Initialize Profile auth listener only when user is ready
      context.read<ProfileProvider>().initAuthListener();
    });
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
