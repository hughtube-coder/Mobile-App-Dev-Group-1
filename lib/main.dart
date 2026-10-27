import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

// Marketing Vikings – Tabletop RPG Miniatures & Dice Swap
// Day 1 – App skeleton
// Widgets used: MaterialApp, Scaffold, AppBar, Column, Text, Placeholder

void main() {
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
