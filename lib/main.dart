import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/core/app_router.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/settings/theme_section.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

Future<void> setupNotifications() async {
  // Android notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request permissions (Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  // Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': token});
  }
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': newToken});
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupNotifications();
  await saveFcmToken();
  runApp(const ProviderScope(child: CampusMarketApp()));
}

class CampusMarketApp extends ConsumerWidget {
  const CampusMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a FutureBuilder to handle Firebase initialization
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show splash/loading while initializing
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        } else if (snapshot.hasError) {
          // Show error UI if Firebase fails to initialize
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Failed to initialize Firebase: \n${snapshot.error}'),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        // Firebase initialized, proceed with app
        final router = ref.watch(appRouterProvider);
        final appThemeMode = ref.watch(themeModeProvider);
        ThemeMode themeMode;
        switch (appThemeMode) {
          case AppThemeMode.light:
            themeMode = ThemeMode.light;
            break;
          case AppThemeMode.dark:
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }
        return MaterialApp.router(
          title: 'CampusMarket',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
