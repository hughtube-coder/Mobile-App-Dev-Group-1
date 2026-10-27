import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A labelled [Placeholder] that marks where a future feature will be built.
/// Each box says which day of the project it will be replaced on.
class ComingSoonBox extends StatelessWidget {
  const ComingSoonBox({
    super.key,
    required this.day,
    required this.label,
    this.height = 100,
  });

  final int day;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      fallbackHeight: height,
      color: AppColors.goldFaded,
      strokeWidth: 1.5,
      child: Center(
        // Small dark label so the text is readable over the X lines.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppColors.dungeon,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DAY $day',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.gold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.parchment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
