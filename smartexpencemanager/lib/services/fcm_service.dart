import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartexpencemanager/services/navigation_service.dart';

class FirebaseFcmService {
  final _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'smart_expense_channel';
  static const String _channelName = 'Smart Expense Notifications';
  static const String _channelDescription =
      'Receive notifications about your expenses and insights';

  Future<String?> getToken() async {
    final token = await _fcm.getToken();
    return token;
  }

  Future<void> requestNotificationPermission() async {  
    // Request FCM permission
    await _fcm.requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Listen to foreground and background notifications
  void listenToMessages() {
    // Foreground message
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) async {
          print("⚡ Foreground message: ${message.notification?.title}");

          // Show both system notification and SnackBar
          await _showLocalNotification(
            message.notification?.title ?? 'Smart Expense',
            message.notification?.body ?? 'You have a new notification',
          );

          // Also show SnackBar in UI
          final context = NavigationService.navigatorKey.currentContext;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message.notification?.title ?? "New Notification",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        })
        .onError((error) {
          print("Error in foreground message: $error");
        });

    // When app is opened via tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 Notification opened: ${message.notification?.title}");
    });
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(''),
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
}
