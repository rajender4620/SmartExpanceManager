import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/blocs/expense/expense_bloc.dart';
import 'package:smartexpencemanager/blocs/theme/theme_bloc.dart';
import 'package:smartexpencemanager/blocs/theme/theme_state.dart';
import 'package:smartexpencemanager/blocs/auth/auth_bloc.dart';
import 'package:smartexpencemanager/services/fcm_service.dart';
import 'package:smartexpencemanager/theme/app_theme.dart';
import 'package:smartexpencemanager/services/navigation_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("✅ Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final fcmService = FirebaseFcmService();

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Ask permission right after login/home screen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fcmService.requestNotificationPermission();
      fcmService.listenToMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
        BlocProvider<ExpenseBloc>(create: (_) => ExpenseBloc()),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'SmartExpense Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: NavigationService.authWrapper,
            onGenerateRoute: NavigationService.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Future<void> _backgroundHandler(RemoteMessage message) async {
//   print("📩 Background: ${message.notification?.title}");
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final _fcm = FirebaseMessaging.instance;
//   final _local = FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     _initFCM();
//   }

//   Future<void> _initFCM() async {
//     // Request permission (needed on iOS + Android 13+)
//     await _fcm.requestPermission();

//     // Get FCM token
//     String? token = await _fcm.getToken();
//     print("🔥 Token: $token");

//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen((message) {
//       print("⚡ Foreground: ${message.notification?.title}");
//       _showLocalNotification(
//         message.notification?.title ?? "No title",
//         message.notification?.body ?? "No body",
//       );
//     });

//     // When app opened by tapping notification
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print("📲 Notification tapped: ${message.notification?.title}");
//     });
//   }

//   Future<void> _showLocalNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       "default_channel", "Default",
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//     const details = NotificationDetails(android: androidDetails);

//     await _local.show(0, title, body, details);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("FCM Demo")),
//         body: Center(child: Text("Waiting for notifications...")),
//       ),
//     );
//   }
// }
