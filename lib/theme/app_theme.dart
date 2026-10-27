import 'package:flutter/material.dart';

/// Colors used across the app (dark fantasy "tavern" theme).
class AppColors {
  AppColors._();

  static const Color dragonRed = Color(0xFF8B1E1E);
  static const Color gold = Color(0xFFD4A537);
  static const Color goldFaded = Color(0x80D4A537); // gold at 50% opacity
  static const Color parchment = Color(0xFFF3E5C0);
  static const Color parchmentFaded = Color(0xCCF3E5C0); // parchment at 80%
  static const Color dungeon = Color(0xFF15100E); // page background
  static const Color stone = Color(0xFF2A211D); // app bar / cards
  static const Color mutedText = Color(0xFF9E9289);
}

/// The app-wide theme, so every screen looks the same.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.dragonRed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.gold,
          secondary: AppColors.dragonRed,
          surface: AppColors.dungeon,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dungeon,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.stone,
        foregroundColor: AppColors.parchment,
        centerTitle: true,
        elevation: 2,
      ),
    );
  }
}
