import 'package:flutter/material.dart';
import 'package:truck_app/features/home/screens/home_screen_user.dart';
import 'package:truck_app/features/main/screen/main_screen_user.dart';
import 'package:truck_app/features/splash/screen/splash_screen.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const GoodsApp());
}

class GoodsApp extends StatelessWidget {
  const GoodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Return Cargo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: MainScreenUser(),
    );
  }
}
