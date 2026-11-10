import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

// Marketing Vikings – Dual E-Commerce Mobile App
// 1) Digital Pattern & LUT Tester Market
// 2) Tabletop RPG Miniatures & Dice Swap

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive mode: Hides Android 3-button navigation bar (<, O, []) so they
  // go down and don't cover or block buttons inside the app.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MarketingVikingsApp());
}

/// Root widget: sets up the app name, theme and first screen.
class MarketingVikingsApp extends StatelessWidget {
  const MarketingVikingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketing Vikings',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
