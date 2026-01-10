import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/splash/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:truck_app/core/services/notification_service.dart';
import 'package:truck_app/firebase_options.dart';
import 'package:truck_app/features/notification/repo/notification_repository.dart';

import 'bloc/bloc_providers.dart';
import 'core/theme/app_theme.dart';
import 'di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Setup token update callback
  notificationService.setTokenUpdateCallback((token) async {
    try {
      final notificationRepo = locator<NotificationRepository>();
      await notificationRepo.updateFcmToken(token);
    } catch (e) {
      debugPrint("Error in token update callback: $e");
    }
  });

  // Send initial token to backend
  await notificationService.updateTokenOnBackend((token) async {
    try {
      final notificationRepo = locator<NotificationRepository>();
      await notificationRepo.updateFcmToken(token);
    } catch (e) {
      debugPrint("Error sending initial token: $e");
    }
  });

  // Setup notification tap handler for navigation
  notificationService.setOnNotificationTap((data) {
    debugPrint("Notification tapped with data: $data");
    // TODO: Implement navigation based on notification type
    // This will be called when user taps on a notification
    // You can use Navigator or your routing system here
    // Example:
    // if (data['type'] == 'TRIP' && data['tripId'] != null) {
    //   navigatorKey.currentState?.pushNamed('/trip-details', arguments: data['tripId']);
    // }
  });

  runApp(const GoodsApp());
}

class GoodsApp extends StatelessWidget {
  const GoodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: globalBlocProviders,
      child: MaterialApp(
        title: 'Return Cargo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: SplashScreen(),
      ),
    );
  }
}
