import 'dart:io';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // If you're using other packages (e.g. Hive), they might need initialization here too.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // 1. Initialize Firebase (if not done in main)
    // Assuming Firebase.initializeApp() is called in main.dart

    // 2. Request Permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 3. Setup Local Notifications (for Foreground display)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS, we rely on Firebase Messaging's presentation options usually,
    // but explicit setup is good for control.
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response.payload);
      },
    );

    // Create channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 4. Get FCM Token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $_fcmToken");

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint("FCM Token Refreshed: $_fcmToken");
      _updateTokenOnBackend(newToken);
    });

    // 5. Setup Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              icon: '@mipmap/ic_launcher',
              // other properties...
            ),
          ),
          payload: message.data.toString(), // Or precise ID for navigation
        );
      }
    });

    // 6. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Callback for navigation when notification is tapped
  Function(Map<String, dynamic>)? _onNotificationTap;

  void setOnNotificationTap(Function(Map<String, dynamic>) callback) {
    _onNotificationTap = callback;
  }

  void _handleNotificationTap(String? payload) {
    debugPrint("Notification Tapped with payload: $payload");

    if (payload != null && _onNotificationTap != null) {
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        _onNotificationTap!(data);
      } catch (e) {
        debugPrint("Error parsing notification payload: $e");
      }
    }
  }

  // Method to get token explicitly
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Callback for updating token on backend
  Function(String)? _tokenUpdateCallback;

  void setTokenUpdateCallback(Function(String) callback) {
    _tokenUpdateCallback = callback;
  }

  // Update FCM token on backend
  Future<void> _updateTokenOnBackend(String token) async {
    if (_tokenUpdateCallback != null) {
      try {
        await _tokenUpdateCallback!(token);
        debugPrint("FCM Token updated on backend successfully");
      } catch (e) {
        debugPrint("Error updating FCM token on backend: $e");
      }
    }
  }

  // Public method to update token on backend (called from app initialization)
  Future<void> updateTokenOnBackend(Function(String) updateCallback) async {
    if (_fcmToken != null) {
      try {
        await updateCallback(_fcmToken!);
        debugPrint("FCM Token sent to backend");
      } catch (e) {
        debugPrint("Error sending FCM token to backend: $e");
      }
    }
  }
}
