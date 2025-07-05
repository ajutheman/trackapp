import 'package:flutter/material.dart';
import 'package:truck_app/features/main/screen/main_screen_driver.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const GoodsApp());
}

class GoodsApp extends StatelessWidget {
  const GoodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Goods App', theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme, themeMode: ThemeMode.light, home: MainScreenDriver());
  }
}
